import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:wwe_universe/classes/match_record.dart';
import 'package:wwe_universe/classes/match_sides.dart';
import 'package:wwe_universe/classes/match_participants.dart';
import 'package:wwe_universe/database/database.dart';
import 'package:wwe_universe/database/match_formats_database_helper.dart';
import 'package:wwe_universe/database/match_types_database_helper.dart';
import 'package:wwe_universe/database/stipulations_database_helper.dart';
import 'package:wwe_universe/database/shows_database_helper.dart';
import 'package:wwe_universe/database/titles_database_helper.dart';

class MatchesDatabaseHelper {
  static List<MatchParticipants> _participantsOf(MatchRecord match) =>
      match.allParticipants;

  
  static Future<void> _validateMatch(MatchRecord match) async {
    if (!MatchResultStatus.values.contains(match.resultStatus)) {
      throw ArgumentError('Statut de résultat invalide.');
    }

    final usesSides = match.snapshotUsesSides;
    final sideCount = match.snapshotSideCount;
    final participantCount = match.snapshotParticipantCount;
    final participantsPerSide = match.snapshotParticipantsPerSide;
    final allParticipants = _participantsOf(match);

    if (allParticipants.isEmpty) {
      throw ArgumentError('Un combat doit contenir au moins un participant.');
    }

    if (usesSides) {
      if (match.specialParticipants.isNotEmpty) {
        throw ArgumentError(
          'Les participants doivent être associés à un camp pour ce format.',
        );
      }

      if (match.sides.length != sideCount) {
        throw ArgumentError(
          'Ce format nécessite exactement $sideCount camps.',
        );
      }

      final sideOrders = match.sides.map((side) => side.sideOrder).toSet();

      if (sideOrders.length != match.sides.length) {
        throw ArgumentError('Deux camps ne peuvent pas avoir le même ordre.');
      }

      for (final side in match.sides) {
        if (side.sideOrder < 0 || side.sideOrder >= sideCount) {
          throw ArgumentError('Ordre de camp invalide.');
        }

        if (side.name.trim().isEmpty) {
          throw ArgumentError('Chaque camp doit avoir un nom.');
        }

        if (side.participants.isEmpty) {
          throw ArgumentError(
            'Chaque camp doit contenir au moins un participant.',
          );
        }

        if (side.sideOrder >= participantsPerSide.length) {
          throw ArgumentError('Répartition des participants invalide.');
        }

        final expected = participantsPerSide[side.sideOrder];

        if (side.participants.length != expected) {
          throw ArgumentError(
            'Le camp ${side.sideOrder + 1} doit contenir $expected participant(s).',
          );
        }

        final positions = side.participants.map((p) => p.position).toSet();

        if (positions.length != side.participants.length) {
          throw ArgumentError(
            'Deux participants ne peuvent pas avoir la même position dans un camp.',
          );
        }
      }

      if (allParticipants.length != participantCount) {
        throw ArgumentError(
          'Ce format nécessite exactement $participantCount participants.',
        );
      }
    } else {
      if (match.sides.isNotEmpty) {
        throw ArgumentError(
          'Ce format spécial ne doit pas comporter de camps.',
        );
      }

      if (allParticipants.length != participantCount) {
        throw ArgumentError(
          'Ce format nécessite exactement $participantCount participants.',
        );
      }
    }

    final superstarIds = <int>{};

    for (final participant in allParticipants) {
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

    if (match.resultStatus == MatchResultStatus.winner) {
      final hasSideWinner = match.winnerSideOrder != null;
      final hasIndividualWinner =
          match.winnerName != null && match.winnerName!.trim().isNotEmpty;

      if (hasSideWinner) {
        if (!usesSides ||
            hasIndividualWinner ||
            match.winnerSuperstarId != null) {
          throw ArgumentError(
            'Le vainqueur par camp est incompatible avec ce format.',
          );
        }

        if (!match.sides.any(
          (side) => side.sideOrder == match.winnerSideOrder,
        )) {
          throw ArgumentError('Le camp gagnant est introuvable.');
        }
      } else {
        if (!hasIndividualWinner) {
          throw ArgumentError(
            'Une victoire individuelle doit désigner une Superstar.',
          );
        }

        final winnerName = match.winnerName!.trim();

        final isParticipant = allParticipants.any((participant) {
          if (match.winnerSuperstarId != null) {
            return participant.superstarId == match.winnerSuperstarId &&
                participant.superstarName == winnerName;
          }

          return participant.superstarName == winnerName;
        });

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


  static Future<void> _insertParticipants(
    Transaction txn,
    int matchId,
    List<MatchParticipants> participants, {
    int? sideId,
  }) async {
    for (final participant in participants) {
      await txn.insert(tableMatchParticipants, {
        MatchParticipantsFields.matchId: matchId,
        MatchParticipantsFields.sideId: sideId,
        MatchParticipantsFields.position: participant.position,
        MatchParticipantsFields.superstarId: participant.superstarId,
        MatchParticipantsFields.superstarName: participant.superstarName,
      });
    }
  }

  static Future<void> _insertStructure(Transaction txn, MatchRecord match, int matchId) async {
    for (final side in match.sides) {
      final sideId = await txn.insert(tableMatchSides, {
        MatchSidesFields.matchId: matchId,
        MatchSidesFields.sideOrder: side.sideOrder,
        MatchSidesFields.name: side.name,
        MatchSidesFields.teamId: side.teamId,
      });
      await _insertParticipants(txn, matchId, side.participants, sideId: sideId);
    }
    await _insertParticipants(txn, matchId, match.specialParticipants);
  }

  static MatchParticipants _participantFromRow(Map<String, Object?> row) => MatchParticipants(
        id: row[MatchParticipantsFields.id] as int?,
        matchId: row[MatchParticipantsFields.matchId] as int?,
        sideId: row[MatchParticipantsFields.sideId] as int?,
        position: row[MatchParticipantsFields.position] as int,
        superstarId: row[MatchParticipantsFields.superstarId] as int?,
        superstarName: row[MatchParticipantsFields.superstarName] as String,
      );

  static Future<MatchRecord> _fromMap(Map<String, Object?> json) async {
    final matchId = json[MatchRecordFields.id] as int;
    final db = await DatabaseService.instance.database;
    final sideRows = await db.query(tableMatchSides,
      where: '${MatchSidesFields.matchId} = ?', whereArgs: [matchId],
      orderBy: '${MatchSidesFields.sideOrder} ASC');
    final sides = <MatchSides>[];
    for (final sideRow in sideRows) {
      final sideId = sideRow[MatchSidesFields.id] as int;
      final rows = await db.query(tableMatchParticipants,
        where: '${MatchParticipantsFields.sideId} = ?', whereArgs: [sideId],
        orderBy: '${MatchParticipantsFields.position} ASC');
      sides.add(MatchSides(
        id: sideId,
        matchId: matchId,
        sideOrder: sideRow[MatchSidesFields.sideOrder] as int,
        name: sideRow[MatchSidesFields.name] as String,
        teamId: sideRow[MatchSidesFields.teamId] as int?,
        participants: rows.map(_participantFromRow).toList(),
      ));
    }
    final specialRows = await db.query(tableMatchParticipants,
      where: '${MatchParticipantsFields.matchId} = ? AND ${MatchParticipantsFields.sideId} IS NULL',
      whereArgs: [matchId], orderBy: '${MatchParticipantsFields.position} ASC');

      final rawParticipantsPerSide =
    json[MatchRecordFields.formatParticipantsPerSide] as String?;

    final snapshotParticipantsPerSide =
        rawParticipantsPerSide == null || rawParticipantsPerSide.isEmpty
            ? null
            : (jsonDecode(rawParticipantsPerSide) as List<dynamic>)
                .map((value) => value as int)
                .toList();

    final formatId = json[MatchRecordFields.formatId] as int?;
    final typeId = json[MatchRecordFields.matchTypeId] as int?;
    final stipulationId = json[MatchRecordFields.stipulationId] as int?;
    final titleId = json[MatchRecordFields.titleId] as int?;
    final showId = json[MatchRecordFields.showId] as int;
    return MatchRecord(
      id: matchId,
      format: await MatchFormatsDatabaseHelper.readFormatIfExists(formatId),
      formatName: json[MatchRecordFields.formatName] as String? ?? '',
      formatCategory:
          json[MatchRecordFields.formatCategory] as String?,

      formatParticipantCount:
          json[MatchRecordFields.formatParticipantCount] as int?,

      formatSideCount:
          json[MatchRecordFields.formatSideCount] as int?,

      formatParticipantsPerSide: snapshotParticipantsPerSide,
      matchType: await MatchTypesDatabaseHelper.readIfExists(typeId),
      matchTypeName: json[MatchRecordFields.matchTypeName] as String? ?? '',
      stipulation: await StipulationsDatabaseHelper.readStipulationIfExists(stipulationId),
      stipulationName: json[MatchRecordFields.stipulationName] as String? ?? '',
      sides: sides,
      specialParticipants: specialRows.map(_participantFromRow).toList(),
      resultStatus: json[MatchRecordFields.resultStatus] as String,
      winnerSideOrder: json[MatchRecordFields.winnerSideOrder] as int?,
      winnerSuperstarId: json[MatchRecordFields.winnerSuperstarId] as int?,
      matchOrder: json[MatchRecordFields.matchOrder] as int,
      show: await ShowsDatabaseHelper.readShow(showId),
      title: titleId == null ? null : await TitlesDatabaseHelper.readTitle(titleId),
      winnerName: json[MatchRecordFields.winnerName] as String?,
    );
  }

  static Future<MatchRecord> createMatch(MatchRecord match) async {
    await _validateMatch(match);
    final db = await DatabaseService.instance.database;
    final id = await db.transaction((txn) async {
      final values = match.toJson()..remove(MatchRecordFields.id);
      final matchId = await txn.insert(tableMatches, values);
      await _insertStructure(txn, match, matchId);
      return matchId;
    });
    return readMatch(id);
  }

  static Future<MatchRecord> readMatch(int id) async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query(tableMatches,
      where: '${MatchRecordFields.id} = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) throw Exception('Combat $id introuvable.');
    return _fromMap(rows.first);
  }

  static Future<List<MatchRecord>> readAllMatches(int showId) async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query(tableMatches,
      where: '${MatchRecordFields.showId} = ?', whereArgs: [showId],
      orderBy: '${MatchRecordFields.matchOrder} ASC');
    return Future.wait(rows.map(_fromMap));
  }

  static Future<List<MatchRecord>> readAllMatchesSuperstar(int superstarId) async {
    final db = await DatabaseService.instance.database;
    final rows = await db.rawQuery('''
      SELECT DISTINCT m.* FROM $tableMatches m
      INNER JOIN $tableMatchParticipants p
        ON p.${MatchParticipantsFields.matchId} = m.${MatchRecordFields.id}
      WHERE p.${MatchParticipantsFields.superstarId} = ?
      ORDER BY m.${MatchRecordFields.matchOrder} ASC
    ''', [superstarId]);
    return Future.wait(rows.map(_fromMap));
  }

  static Future<int> updateMatches(MatchRecord match) async {
    if (match.id == null) throw ArgumentError('Impossible de modifier un combat sans identifiant.');
    await _validateMatch(match);
    final db = await DatabaseService.instance.database;
    await db.transaction((txn) async {
      final values = match.toJson()..remove(MatchRecordFields.id);
      await txn.update(tableMatches, values,
        where: '${MatchRecordFields.id} = ?', whereArgs: [match.id]);
      await txn.delete(tableMatchSides,
        where: '${MatchSidesFields.matchId} = ?', whereArgs: [match.id]);
      // Les participants sans camp ne sont pas supprimés par la cascade des camps.
      await txn.delete(tableMatchParticipants,
        where: '${MatchParticipantsFields.matchId} = ?', whereArgs: [match.id]);
      await _insertStructure(txn, match, match.id!);
    });
    return 1;
  }

  static Future<int> deleteMatch(int id) async {
    final db = await DatabaseService.instance.database;
    return db.delete(tableMatches,
      where: '${MatchRecordFields.id} = ?', whereArgs: [id]);
  }

  static Future<void> reorderMatches(int showId, List<int> orderedMatchIds) async {
    final db = await DatabaseService.instance.database;
    await db.transaction((txn) async {
      for (var index = 0; index < orderedMatchIds.length; index++) {
        await txn.update(tableMatches, {MatchRecordFields.matchOrder: index},
          where: '${MatchRecordFields.id} = ? AND ${MatchRecordFields.showId} = ?',
          whereArgs: [orderedMatchIds[index], showId]);
      }
    });
  }
}
