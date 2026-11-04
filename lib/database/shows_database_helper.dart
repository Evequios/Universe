import 'package:wwe_universe/classes/show.dart';
import 'package:wwe_universe/classes/match_record.dart';
import 'package:wwe_universe/classes/reigns.dart';
import 'package:wwe_universe/classes/titles.dart';
import 'package:wwe_universe/database/reings_database_helper.dart';
import 'package:wwe_universe/database/database.dart';

class ShowsDatabaseHelper {
  static Future<Show> createShow(Show universeShows) async {
    final db = await DatabaseService.instance.database;

    final id = await db.insert(tableShows, universeShows.toJson());
    return universeShows.copy(id: id);
  }

  static Future<Show> readShow(int id) async {
    final db = await DatabaseService.instance.database;

    final maps = await db.query(
      tableShows,
      columns: ShowFields.values,
      where: '${ShowFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Show.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  static Future<List<Show>> readAllShows() async {
    final db = await DatabaseService.instance.database;

    final result = await db.query(
      tableShows,
      orderBy:
        '${ShowFields.year} ASC, '
        '${ShowFields.week} ASC, '
        '${ShowFields.dayOfWeek} ASC',
    );

    return result.map((json) => Show.fromJson(json)).toList();
  }

  static Future<int> updateShow(Show universeShows) async {
    final db = await DatabaseService.instance.database;
    return db.transaction((txn) async {
      final matchRows = await txn.query(tableMatches,
        columns: [MatchRecordFields.id, MatchRecordFields.titleId, MatchRecordFields.matchOrder],
        where: '${MatchRecordFields.showId} = ?', whereArgs: [universeShows.id]);
      final count = await txn.update(tableShows, universeShows.toJson(),
        where: '${ShowFields.id} = ?', whereArgs: [universeShows.id]);
      final affectedTitles = <int>{};
      for (final row in matchRows) {
        final matchId = row[MatchRecordFields.id] as int;
        final titleId = row[MatchRecordFields.titleId] as int?;
        if (titleId == null) continue;
        final eventRows = await txn.query(tableTitleReignEvents,
          where: '${TitleReignEventFields.matchId} = ?', whereArgs: [matchId], limit: 1);
        if (eventRows.isEmpty) continue;
        await txn.update(tableTitleReignEvents, {
          TitleReignEventFields.year: universeShows.year,
          TitleReignEventFields.week: universeShows.week,
          TitleReignEventFields.dayOfWeek: universeShows.dayOfWeek,
          TitleReignEventFields.matchOrder: row[MatchRecordFields.matchOrder],
        }, where: '${TitleReignEventFields.matchId} = ?', whereArgs: [matchId]);
        affectedTitles.add(titleId);
      }
      for (final titleId in affectedTitles) {
        await ReignsDatabaseHelper.rebuildAfterMatchDeletion(txn, titleId);
      }
      return count;
    });
  }


  static Future<int> setShowCompleted({
    required int showId,
    required bool isCompleted,
  }) async {
    final db = await DatabaseService.instance.database;
    return db.update(
      tableShows,
      {ShowFields.isCompleted: isCompleted ? 1 : 0},
      where: '${ShowFields.id} = ?',
      whereArgs: [showId],
    );
  }

  static Future<int> deleteShow(int id) async {
    final db = await DatabaseService.instance.database;
    return db.transaction((txn) async {
      final matches = await txn.query(tableMatches,
        columns: [MatchRecordFields.titleId],
        where: '${MatchRecordFields.showId} = ?', whereArgs: [id]);
      final affectedTitles = matches
          .map((row) => row[MatchRecordFields.titleId] as int?)
          .where((titleId) => titleId != null)
          .cast<int>()
          .toSet();
      final count = await txn.delete(tableShows,
        where: '${ShowFields.id} = ?', whereArgs: [id]);
      for (final titleId in affectedTitles) {
        await ReignsDatabaseHelper.rebuildAfterMatchDeletion(txn, titleId);
      }
      return count;
    });
  }
}