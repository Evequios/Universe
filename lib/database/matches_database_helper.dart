
import 'package:sqflite/sqflite.dart';
import 'package:wwe_universe/classes/match_record.dart';
import 'package:wwe_universe/classes/match_sides.dart';
import 'package:wwe_universe/classes/match_participants.dart';
import 'package:wwe_universe/database/database.dart';
import 'package:wwe_universe/database/match_formats_database_helper.dart';
import 'package:wwe_universe/database/stipulations_database_helper.dart';
import 'package:wwe_universe/database/shows_database_helper.dart';
import 'package:wwe_universe/database/titles_database_helper.dart';

class MatchesDatabaseHelper {
  static Future<void> _validateMatch(MatchRecord match) async {
    if (!MatchResultStatus.values.contains(match.resultStatus)) {
      throw ArgumentError('Statut de résultat invalide.');
    }

    if (match.sides.length < 2) {
      throw ArgumentError(
        'Un combat doit comporter au moins deux camps.',
      );
    }

    final sideOrders = match.sides.map((side) => side.sideOrder).toSet();

    if (sideOrders.length != match.sides.length) {
      throw ArgumentError(
        'Deux camps ne peuvent pas avoir le même ordre.',
      );
    }

    final superstarIds = <int>{};

    for (final side in match.sides) {
      if (side.name.trim().isEmpty) {
        throw ArgumentError('Chaque camp doit avoir un nom.');
      }

      if (side.participants.isEmpty) {
        throw ArgumentError(
          'Chaque camp doit contenir au moins un participant.',
        );
      }

      final positions =
          side.participants.map((participant) => participant.position).toSet();

      if (positions.length != side.participants.length) {
        throw ArgumentError(
          'Deux participants ne peuvent pas avoir la même position dans un camp.',
        );
      }

      for (final participant in side.participants) {
        if (participant.superstarName.trim().isEmpty) {
          throw ArgumentError(
            'Chaque participant doit avoir un nom historique.',
          );
        }

        final superstarId = participant.superstarId;

        if (superstarId != null && !superstarIds.add(superstarId)) {
          throw ArgumentError(
            'Une Superstar ne peut pas participer plusieurs fois au même combat.',
          );
        }
      }
    }

    if (match.resultStatus == MatchResultStatus.winner) {
      final hasSideWinner = match.winnerSideOrder != null;
      final hasIndividualWinner =
          match.winnerName != null && match.winnerName!.trim().isNotEmpty;

      if (hasSideWinner) {
        // Un vainqueur par camp ne doit avoir aucun champ de vainqueur individuel.
        if (hasIndividualWinner || match.winnerSuperstarId != null) {
          throw ArgumentError(
            'Un vainqueur par camp ne peut pas être une Superstar individuelle.',
          );
        }

        if (!sideOrders.contains(match.winnerSideOrder)) {
          throw ArgumentError('Le camp gagnant est introuvable.');
        }
      } else {
        // Une victoire individuelle doit obligatoirement avoir un nom.
        if (!hasIndividualWinner) {
          throw ArgumentError(
            'Une victoire individuelle doit désigner une Superstar.',
          );
        }

        final winnerName = match.winnerName!.trim();

        final isParticipant = match.sides.any(
          (side) => side.participants.any((participant) {
            if (match.winnerSuperstarId != null) {
              return participant.superstarId == match.winnerSuperstarId &&
                  participant.superstarName == winnerName;
            }

            // Superstar supprimée : on s'appuie sur son nom historique.
            return participant.superstarName == winnerName;
          }),
        );

        if (!isParticipant) {
          throw ArgumentError(
            'La Superstar gagnante doit participer au combat.',
          );
        }
      }
    } else if (match.winnerSideOrder != null ||
        match.winnerSuperstarId != null ||
        (match.winnerName != null && match.winnerName!.trim().isNotEmpty)) {
      throw ArgumentError(
        'Un match nul, en attente ou No Contest ne peut pas avoir de vainqueur.',
      );
    }
  }
  
  static Future<void> _insertSides(
    Transaction txn,
    int matchId,
    List<MatchSides> sides,
  ) async {
    for (final side in sides) {
      final sideId = await txn.insert(
        tableMatchSides,
        {
          MatchSidesFields.matchId: matchId,
          MatchSidesFields.sideOrder: side.sideOrder,
          MatchSidesFields.name: side.name,
          MatchSidesFields.teamId: side.teamId,
        },
      );

      for (final participant in side.participants) {
        final participantJson = participant.toJson(
          assignedSideId: sideId,
        );

        participantJson.remove(MatchParticipantsFields.id);
        participantJson[MatchParticipantsFields.matchId] = matchId;

        await txn.insert(
          tableMatchParticipants,
          participantJson,
        );
      }
    }
  }
  
  static Future<MatchRecord> _fromMap(
    Map<String, Object?> json,
  ) async {
    final matchId = json[MatchRecordFields.id] as int;
    final db = await DatabaseService.instance.database;

    final sideRows = await db.query(
      tableMatchSides,
      where: '${MatchSidesFields.matchId} = ?',
      whereArgs: [matchId],
      orderBy: '${MatchSidesFields.sideOrder} ASC',
    );

    final sides = <MatchSides>[];

    for (final sideRow in sideRows) {
      final sideId = sideRow[MatchSidesFields.id] as int;

      final participantRows = await db.query(
        tableMatchParticipants,
        where: '${MatchParticipantsFields.sideId} = ?',
        whereArgs: [sideId],
        orderBy: '${MatchParticipantsFields.position} ASC',
      );

      final participants = participantRows.map((row) {
        return MatchParticipants(
          id: row[MatchParticipantsFields.id] as int?,
          matchId: row[MatchParticipantsFields.matchId] as int,
          sideId: row[MatchParticipantsFields.sideId] as int,
          position: row[MatchParticipantsFields.position] as int,
          superstarId: row[MatchParticipantsFields.superstarId] as int?,
          superstarName:
              row[MatchParticipantsFields.superstarName] as String,
        );
      }).toList();

      sides.add(
        MatchSides(
          id: sideId,
          matchId: matchId,
          sideOrder: sideRow[MatchSidesFields.sideOrder] as int,
          name: sideRow[MatchSidesFields.name] as String,
          teamId: sideRow[MatchSidesFields.teamId] as int?,
          participants: participants,
        ),
      );
    }

    final formatId = json[MatchRecordFields.formatId] as int?;
    final stipulationId =
        json[MatchRecordFields.stipulationId] as int?;
    final titleId = json[MatchRecordFields.titleId] as int?;
    final showId = json[MatchRecordFields.showId] as int;

    return MatchRecord(
      id: matchId,
      format: await MatchFormatsDatabaseHelper.readFormatIfExists(
        formatId,
      ),
      formatName: json[MatchRecordFields.formatName] as String,
      stipulation:
          await StipulationsDatabaseHelper.readStipulationIfExists(
        stipulationId,
      ),
      stipulationName:
          json[MatchRecordFields.stipulationName] as String,
      sides: sides,
      resultStatus: json[MatchRecordFields.resultStatus] as String,
      winnerSideOrder:
          json[MatchRecordFields.winnerSideOrder] as int?,
      winnerSuperstarId:
          json[MatchRecordFields.winnerSuperstarId] as int?,
      matchOrder: json[MatchRecordFields.matchOrder] as int,
      show: await ShowsDatabaseHelper.readShow(showId),
      title: titleId == null
          ? null
          : await TitlesDatabaseHelper.readTitle(titleId),
      winnerName: json[MatchRecordFields.winnerName] as String?,
    );
  }

  static Future<MatchRecord> createMatch(MatchRecord match) async {
    await _validateMatch(match);

    final db = await DatabaseService.instance.database;

    final id = await db.transaction((txn) async {
      final values = match.toJson()
        ..remove(MatchRecordFields.id);

      final matchId = await txn.insert(tableMatches, values);

      await _insertSides(txn, matchId, match.sides);

      return matchId;
    });

    return readMatch(id);
  }

  static Future<MatchRecord> readMatch(int id) async {
    final db = await DatabaseService.instance.database;

    final result = await db.query(
      tableMatches,
      where: '${MatchRecordFields.id} = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) {
      throw Exception('Combat $id introuvable.');
    }

    return _fromMap(result.first);
  }

  static Future<List<MatchRecord>> readAllMatches(int showId) async {
    final db = await DatabaseService.instance.database;

    final result = await db.query(
      tableMatches,
      where: '${MatchRecordFields.showId} = ?',
      whereArgs: [showId],
      orderBy: '${MatchRecordFields.matchOrder} ASC',
    );

    return Future.wait(result.map(_fromMap));
  }

  static Future<List<MatchRecord>> readAllMatchesSuperstar(
    int superstarId,
  ) async {
    final db = await DatabaseService.instance.database;

    final result = await db.rawQuery('''
      SELECT DISTINCT m.*
      FROM $tableMatches m
      INNER JOIN $tableMatchParticipants p
        ON p.${MatchParticipantsFields.matchId} =
           m.${MatchRecordFields.id}
      WHERE p.${MatchParticipantsFields.superstarId} = ?
      ORDER BY m.${MatchRecordFields.matchOrder} ASC
    ''', [superstarId]);

    return Future.wait(result.map(_fromMap));
  }

  static Future<int> updateMatches(MatchRecord match) async {
    if (match.id == null) {
      throw ArgumentError(
        'Impossible de modifier un combat sans identifiant.',
      );
    }

    await _validateMatch(match);

    final db = await DatabaseService.instance.database;

    await db.transaction((txn) async {
      final values = match.toJson()
        ..remove(MatchRecordFields.id);

      await txn.update(
        tableMatches,
        values,
        where: '${MatchRecordFields.id} = ?',
        whereArgs: [match.id],
      );

      // La suppression des camps entraîne celle des participants.
      await txn.delete(
        tableMatchSides,
        where: '${MatchSidesFields.matchId} = ?',
        whereArgs: [match.id],
      );

      await _insertSides(txn, match.id!, match.sides);
    });

    return 1;
  }

  static Future<int> deleteMatch(int id) async {
    final db = await DatabaseService.instance.database;

    return db.delete(
      tableMatches,
      where: '${MatchRecordFields.id} = ?',
      whereArgs: [id],
    );
  }

  static Future<void> reorderMatches(
    int showId,
    List<int> orderedMatchIds,
  ) async {
    final db = await DatabaseService.instance.database;

    await db.transaction((txn) async {
      for (var index = 0; index < orderedMatchIds.length; index++) {
        await txn.update(
          tableMatches,
          {MatchRecordFields.matchOrder: index},
          where: '''
            ${MatchRecordFields.id} = ?
            AND ${MatchRecordFields.showId} = ?
          ''',
          whereArgs: [orderedMatchIds[index], showId],
        );
      }
    });
  }
}
