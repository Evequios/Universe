import 'package:sqflite/sqflite.dart';
import 'package:wwe_universe/database/database.dart';

/// Manages the optional many-to-many links between a storyline and its
/// fictional news items / matches. A news item or match remains independent
/// when it is not linked to a storyline.
class StorylineRelationsDatabaseHelper {
  static const String _storylineNewsTable = 'storyline_news';
  static const String _storylineMatchesTable = 'storyline_matches';

  static Future<void> linkNews({
    required int storylineId,
    required int newsId,
    int position = 0,
  }) async {
    final db = await DatabaseService.instance.database;
    await db.insert(
      _storylineNewsTable,
      {'storyline_id': storylineId, 'news_id': newsId, 'position': position},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> unlinkNews({
    required int storylineId,
    required int newsId,
  }) async {
    final db = await DatabaseService.instance.database;
    await db.delete(
      _storylineNewsTable,
      where: 'storyline_id = ? AND news_id = ?',
      whereArgs: [storylineId, newsId],
    );
  }

  static Future<void> linkMatch({
    required int storylineId,
    required int matchId,
    int position = 0,
  }) async {
    final db = await DatabaseService.instance.database;
    await db.insert(
      _storylineMatchesTable,
      {'storyline_id': storylineId, 'match_id': matchId, 'position': position},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> unlinkMatch({
    required int storylineId,
    required int matchId,
  }) async {
    final db = await DatabaseService.instance.database;
    await db.delete(
      _storylineMatchesTable,
      where: 'storyline_id = ? AND match_id = ?',
      whereArgs: [storylineId, matchId],
    );
  }

  static Future<List<int>> readNewsIds(int storylineId) async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query(
      _storylineNewsTable,
      columns: ['news_id'],
      where: 'storyline_id = ?',
      whereArgs: [storylineId],
      orderBy: 'position ASC, news_id ASC',
    );
    return rows.map((row) => row['news_id'] as int).toList();
  }

  static Future<List<int>> readMatchIds(int storylineId) async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query(
      _storylineMatchesTable,
      columns: ['match_id'],
      where: 'storyline_id = ?',
      whereArgs: [storylineId],
      orderBy: 'position ASC, match_id ASC',
    );
    return rows.map((row) => row['match_id'] as int).toList();
  }

  static Future<List<int>> readStorylineIdsForNews(int newsId) async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query(
      _storylineNewsTable,
      columns: ['storyline_id'],
      where: 'news_id = ?',
      whereArgs: [newsId],
      orderBy: 'position ASC, storyline_id ASC',
    );
    return rows.map((row) => row['storyline_id'] as int).toList();
  }

  static Future<List<int>> readStorylineIdsForMatch(int matchId) async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query(
      _storylineMatchesTable,
      columns: ['storyline_id'],
      where: 'match_id = ?',
      whereArgs: [matchId],
      orderBy: 'position ASC, storyline_id ASC',
    );
    return rows.map((row) => row['storyline_id'] as int).toList();
  }
}
