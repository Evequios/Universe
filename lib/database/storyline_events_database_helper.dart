import 'package:sqflite/sqflite.dart';
import 'package:wwe_universe/classes/storyline_event.dart';
import 'package:wwe_universe/database/database.dart';

class StorylineEventsDatabaseHelper {
  static Future<List<StorylineEvent>> readAll(int storylineId) async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query(tableStorylineEvents,
      where: '${StorylineEventFields.storylineId} = ?', whereArgs: [storylineId],
      orderBy: '${StorylineEventFields.year} ASC, ${StorylineEventFields.week} ASC, ${StorylineEventFields.dayOfWeek} ASC, ${StorylineEventFields.position} ASC, ${StorylineEventFields.id} ASC');
    return rows.map((row) => StorylineEvent.fromJson(row)).toList();
  }

  static Future<StorylineEvent> create(StorylineEvent event) async {
    final db = await DatabaseService.instance.database;
    final id = await db.insert(tableStorylineEvents, event.toJson());
    return StorylineEvent.fromJson({...event.toJson(), StorylineEventFields.id: id});
  }

  static Future<int> update(StorylineEvent event) async {
    if (event.id == null) throw ArgumentError('The event must have an ID.');
    final db = await DatabaseService.instance.database;
    return db.update(tableStorylineEvents, event.toJson(), where: '${StorylineEventFields.id} = ?', whereArgs: [event.id]);
  }

  static Future<int> delete(int id) async {
    final db = await DatabaseService.instance.database;
    return db.transaction((txn) async {
      final rows = await txn.query(
        tableStorylineEvents,
        columns: [
          StorylineEventFields.storylineId,
          StorylineEventFields.type,
          StorylineEventFields.matchId,
          StorylineEventFields.newsId,
        ],
        where: '${StorylineEventFields.id} = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (rows.isEmpty) return 0;
      final row = rows.first;
      final storylineId = row[StorylineEventFields.storylineId] as int;
      final type = row[StorylineEventFields.type] as String;
      if (type == StorylineEventType.match && row[StorylineEventFields.matchId] != null) {
        await txn.delete(
          'storyline_matches',
          where: 'storyline_id = ? AND match_id = ?',
          whereArgs: [storylineId, row[StorylineEventFields.matchId]],
        );
      } else if (type == StorylineEventType.news && row[StorylineEventFields.newsId] != null) {
        await txn.delete(
          'storyline_news',
          where: 'storyline_id = ? AND news_id = ?',
          whereArgs: [storylineId, row[StorylineEventFields.newsId]],
        );
      }
      return txn.delete(
        tableStorylineEvents,
        where: '${StorylineEventFields.id} = ?',
        whereArgs: [id],
      );
    });
  }

  static Future<void> reorder(int storylineId, List<int> orderedIds) async {
    final db = await DatabaseService.instance.database;
    await db.transaction((txn) async {
      final batch = txn.batch();
      for (var i = 0; i < orderedIds.length; i++) {
        batch.update(tableStorylineEvents, {StorylineEventFields.position: i},
          where: '${StorylineEventFields.id} = ? AND ${StorylineEventFields.storylineId} = ?', whereArgs: [orderedIds[i], storylineId]);
      }
      await batch.commit(noResult: true);
    });
  }
}
