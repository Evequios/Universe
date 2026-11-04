import 'package:sqflite/sqflite.dart';
import 'package:wwe_universe/classes/match_record.dart';
import 'package:wwe_universe/classes/match_sides.dart';
import 'package:wwe_universe/classes/match_participants.dart';
import 'package:wwe_universe/classes/reigns.dart';
import 'package:wwe_universe/classes/titles.dart';
import 'package:wwe_universe/classes/teams.dart';
import 'package:wwe_universe/database/database.dart';

class ReignsDatabaseHelper {
  static const String eventChange = 'change';
  static const String eventVacated = 'vacated';

  // Records a champion assignment made directly from the title form.
  // Manual events are ordered before matches on the selected day.
  static Future<void> recordManualChange({
    required int titleId,
    required int year,
    required int week,
    required int dayOfWeek,
    required int holder1Id,
    required String holder1Name,
    int? holder2Id,
    String? holder2Name,
    int? teamId,
    String? teamName,
  }) async {
    if (week < 1 || week > 48) throw ArgumentError('The week must be between 1 and 48.');
    if (dayOfWeek < 1 || dayOfWeek > 7) throw ArgumentError('The day must be between 1 and 7.');
    final db = await DatabaseService.instance.database;
    await db.transaction((txn) async {
      final titleRows = await txn.query(tableTitles,
        columns: [TitlesFields.tag], where: '${TitlesFields.id} = ?', whereArgs: [titleId], limit: 1);
      if (titleRows.isEmpty) throw StateError('Title not found.');
      final isTag = titleRows.first[TitlesFields.tag] == 1;
      if (isTag && (holder2Id == null || holder2Name == null || holder2Name.isEmpty)) {
        throw ArgumentError('A tag team title requires two champions.');
      }
      if (!isTag && holder2Id != null) {
        throw ArgumentError('A singles title can have only one champion.');
      }
      await txn.insert(tableTitleReignEvents, {
        TitleReignEventFields.titleId: titleId,
        TitleReignEventFields.eventType: eventChange,
        TitleReignEventFields.year: year,
        TitleReignEventFields.week: week,
        TitleReignEventFields.dayOfWeek: dayOfWeek,
        TitleReignEventFields.matchOrder: -1,
        TitleReignEventFields.holder1Id: holder1Id,
        TitleReignEventFields.holder1Name: holder1Name,
        TitleReignEventFields.holder2Id: isTag ? holder2Id : null,
        TitleReignEventFields.holder2Name: isTag ? holder2Name : null,
        TitleReignEventFields.teamId: isTag ? teamId : null,
        TitleReignEventFields.teamName: isTag ? teamName : null,
      });
      await _rebuildTitle(txn, titleId);
    });
  }

  static Future<void> updateManualReignDate({
    required Reigns reign,
    required int year,
    required int week,
    required int dayOfWeek,
  }) async {
    if (reign.startMatchId != null) {
      throw StateError('This reign is linked to a match. Update the match instead.');
    }
    if (week < 1 || week > 48 || dayOfWeek < 1 || dayOfWeek > 7) {
      throw ArgumentError('Invalid WWE date.');
    }
    final db = await DatabaseService.instance.database;
    await db.transaction((txn) async {
      final rows = await txn.query(tableTitleReignEvents,
        columns: [TitleReignEventFields.id],
        where: '${TitleReignEventFields.titleId} = ? AND ${TitleReignEventFields.eventType} = ? AND ${TitleReignEventFields.matchId} IS NULL AND ${TitleReignEventFields.year} = ? AND ${TitleReignEventFields.week} = ? AND ${TitleReignEventFields.dayOfWeek} = ? AND ${TitleReignEventFields.holder1Id} = ?',
        whereArgs: [reign.titleId, eventChange, reign.yearStart, reign.weekStart, reign.dayStart, reign.holder1Id],
        limit: 1);
      if (rows.isEmpty) throw StateError('Manual reign event not found.');
      await txn.update(tableTitleReignEvents, {
        TitleReignEventFields.year: year,
        TitleReignEventFields.week: week,
        TitleReignEventFields.dayOfWeek: dayOfWeek,
      }, where: '${TitleReignEventFields.id} = ?', whereArgs: [rows.first[TitleReignEventFields.id]]);
      await _rebuildTitle(txn, reign.titleId);
    });
  }

  static Future<List<Reigns>> readReigns(int titleId) async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query(tableReigns,
      where: '${ReignsFields.titleId} = ?', whereArgs: [titleId],
      orderBy: '${ReignsFields.yearStart} DESC, ${ReignsFields.weekStart} DESC, ${ReignsFields.id} DESC');
    return rows.map((row) => Reigns.fromMap(row)).toList();
  }

  static Future<Reigns?> readCurrentReign(int titleId) async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query(tableReigns,
      where: '${ReignsFields.titleId} = ? AND ${ReignsFields.yearEnd} IS NULL',
      whereArgs: [titleId], limit: 1);
    return rows.isEmpty ? null : Reigns.fromMap(rows.first);
  }

  static Future<void> vacateTitle({required int titleId, required int year, required int week, required int dayOfWeek}) async {
    if (week < 1 || week > 48) throw ArgumentError('The week must be between 1 and 48.');
    if (dayOfWeek < 1 || dayOfWeek > 7) throw ArgumentError('The day must be between 1 and 7.');
    final db = await DatabaseService.instance.database;
    await db.transaction((txn) async {
      final current = await txn.query(tableReigns,
        where: '${ReignsFields.titleId} = ? AND ${ReignsFields.yearEnd} IS NULL',
        whereArgs: [titleId], limit: 1);
      if (current.isEmpty) throw StateError('This title is already vacant.');
      final startYear = current.first[ReignsFields.yearStart] as int;
      final startWeek = current.first[ReignsFields.weekStart] as int;
      final startDay = current.first[ReignsFields.dayStart] as int? ?? 1;
      if (year < startYear || (year == startYear && (week < startWeek || (week == startWeek && dayOfWeek < startDay)))) {
        throw ArgumentError('The vacancy date cannot be before the start of the reign.');
      }
      await txn.insert(tableTitleReignEvents, {
        TitleReignEventFields.titleId: titleId,
        TitleReignEventFields.eventType: eventVacated,
        TitleReignEventFields.year: year,
        TitleReignEventFields.week: week,
        TitleReignEventFields.dayOfWeek: dayOfWeek,
        // A manual vacancy takes effect at the beginning of the selected day.
        // Matches later that day can therefore legitimately award the title again.
        TitleReignEventFields.matchOrder: -1,
      });
      await _rebuildTitle(txn, titleId);
    });
  }

  // Replaces the event attached to a match, then reconstructs the title history.
  // This makes editing/deleting a match deterministic and prevents stale reigns.
  static Future<void> syncMatch(DatabaseExecutor txn, MatchRecord match, int matchId) async {
    final oldEvents = await txn.query(tableTitleReignEvents,
      columns: [TitleReignEventFields.titleId],
      where: '${TitleReignEventFields.matchId} = ?', whereArgs: [matchId]);
    final oldTitleIds = oldEvents.map((e) => e[TitleReignEventFields.titleId] as int).toSet();
    await txn.delete(tableTitleReignEvents,
      where: '${TitleReignEventFields.matchId} = ?', whereArgs: [matchId]);

    final titleId = match.title?.id;
    if (match.titleChange && titleId != null && match.resultStatus == MatchResultStatus.winner) {
      final winner = _winnerParticipants(match);
      final title = await txn.query(tableTitles, columns: [TitlesFields.tag, TitlesFields.holder1, TitlesFields.holder2], where: '${TitlesFields.id} = ?', whereArgs: [titleId], limit: 1);
      if (title.isEmpty) throw StateError('The title linked to the match could not be found.');
      final isTag = title.first['tag'] == 1;
      if (winner.isEmpty || (isTag && winner.length != 2) || (!isTag && winner.length != 1)) {
        throw ArgumentError(isTag
          ? 'A tag team title change requires exactly two winners.'
          : 'A singles title change requires exactly one winner.');
      }
      final winningSide = _winningTeam(match);
      String? winningTeamName;
      if (winningSide?.teamId != null) {
        final teamRows = await txn.query(tableTeams,
          columns: [TeamsFields.name],
          where: '${TeamsFields.id} = ?', whereArgs: [winningSide!.teamId], limit: 1);
        if (teamRows.isNotEmpty) winningTeamName = teamRows.first[TeamsFields.name] as String;
      }
      await txn.insert(tableTitleReignEvents, {
        TitleReignEventFields.titleId: titleId,
        TitleReignEventFields.eventType: eventChange,
        TitleReignEventFields.year: match.show.year,
        TitleReignEventFields.week: match.show.week,
        TitleReignEventFields.dayOfWeek: match.show.dayOfWeek,
        TitleReignEventFields.matchOrder: match.matchOrder,
        TitleReignEventFields.matchId: matchId,
        TitleReignEventFields.holder1Id: winner[0]['id'],
        TitleReignEventFields.holder1Name: winner[0]['name'],
        TitleReignEventFields.holder2Id: isTag ? winner[1]['id'] : null,
        TitleReignEventFields.holder2Name: isTag ? winner[1]['name'] : null,
        TitleReignEventFields.teamId: isTag ? winningSide?.teamId : null,
        TitleReignEventFields.teamName: isTag ? winningTeamName : null,
      });
      oldTitleIds.add(titleId);
    }

    for (final id in oldTitleIds) {
      await _rebuildTitle(txn, id);
    }
  }

  static MatchSides? _winningTeam(MatchRecord match) {
    if (match.winnerSideOrder == null) return null;
    for (final side in match.sides) {
      if (side.sideOrder == match.winnerSideOrder && side.teamId != null) {
        return side;
      }
    }
    return null;
  }

  static List<Map<String, Object?>> _winnerParticipants(MatchRecord match) {
    if (match.winnerSideOrder != null) {
      MatchSides? side;
      for (final candidate in match.sides) {
        if (candidate.sideOrder == match.winnerSideOrder) { side = candidate; break; }
      }
      if (side == null) return [];
      return side.participants.map((p) => <String, Object?>{
        'id': p.superstarId, 'name': p.superstarName,
      }).toList();
    }
    // Depending on the match format/UI, the selected winner may be stored
    // primarily by superstar ID or by the historical display name. Resolve
    // by ID first when available, then fall back to the name snapshot.
    MatchParticipants? participant;
    for (final candidate in match.allParticipants) {
      final idMatches = match.winnerSuperstarId != null &&
          candidate.superstarId == match.winnerSuperstarId;
      final nameMatches = match.winnerName != null &&
          candidate.superstarName == match.winnerName;
      if (idMatches || (match.winnerSuperstarId == null && nameMatches)) {
        participant = candidate;
        break;
      }
    }
    if (participant == null) return [];
    return [<String, Object?>{
      'id': participant.superstarId,
      'name': participant.superstarName,
    }];
  }

  static Future<void> rebuildAfterMatchDeletion(DatabaseExecutor txn, int titleId) =>
      _rebuildTitle(txn, titleId);

  static Future<void> _rebuildTitle(DatabaseExecutor txn, int titleId) async {
    final events = await txn.query(tableTitleReignEvents,
      where: '${TitleReignEventFields.titleId} = ?', whereArgs: [titleId],
      orderBy: '${TitleReignEventFields.year} ASC, ${TitleReignEventFields.week} ASC, ${TitleReignEventFields.dayOfWeek} ASC, ${TitleReignEventFields.matchOrder} ASC, ${TitleReignEventFields.id} ASC');
    await txn.delete(tableReigns, where: '${ReignsFields.titleId} = ?', whereArgs: [titleId]);

    Map<String, Object?>? active;
    for (final event in events) {
      final type = event[TitleReignEventFields.eventType] as String;
      final year = event[TitleReignEventFields.year] as int;
      final week = event[TitleReignEventFields.week] as int;
      if (active != null) {
        await txn.insert(tableReigns, {
          ...active,
          ReignsFields.yearEnd: year,
          ReignsFields.weekEnd: week,
          ReignsFields.dayEnd: event[TitleReignEventFields.dayOfWeek],
          ReignsFields.endReason: type == eventVacated ? 'vacated' : 'titleChange',
          ReignsFields.endMatchId: type == eventChange ? event[TitleReignEventFields.matchId] : null,
        });
        active = null;
      }
      if (type == eventChange) {
        active = {
          ReignsFields.titleId: titleId,
          ReignsFields.holder1Id: event[TitleReignEventFields.holder1Id],
          ReignsFields.holder1Name: event[TitleReignEventFields.holder1Name],
          ReignsFields.holder2Id: event[TitleReignEventFields.holder2Id],
          ReignsFields.holder2Name: event[TitleReignEventFields.holder2Name],
          ReignsFields.teamId: event[TitleReignEventFields.teamId],
          ReignsFields.teamName: event[TitleReignEventFields.teamName],
          ReignsFields.yearStart: year,
          ReignsFields.weekStart: week,
          ReignsFields.dayStart: event[TitleReignEventFields.dayOfWeek],
          ReignsFields.yearEnd: null,
          ReignsFields.weekEnd: null,
          ReignsFields.dayEnd: null,
          ReignsFields.endReason: null,
          ReignsFields.startMatchId: event[TitleReignEventFields.matchId],
          ReignsFields.endMatchId: null,
        };
      }
    }
    if (active != null) await txn.insert(tableReigns, active);

    final current = active;
    await txn.update('titles', {
      'holder1': current == null ? null : current[ReignsFields.holder1Id],
      'holder2': current == null ? null : current[ReignsFields.holder2Id],
    }, where: '_id = ?', whereArgs: [titleId]);
  }
}
