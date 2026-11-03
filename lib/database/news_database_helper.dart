import 'package:wwe_universe/classes/news.dart';
import 'package:wwe_universe/database/database.dart';
import 'package:wwe_universe/classes/storyline_event.dart';

class NewsDatabaseHelper {
  static Future<News> createNews(News news) async {
    final db = await DatabaseService.instance.database;

    final id = await db.insert(tableNews, news.toJson());
    return news.copy(id: id);
  }

  static Future<News> readNews(int id) async {
    final db = await DatabaseService.instance.database;

    final maps = await db.query(
      tableNews,
      columns: NewsFields.values,
      where: '${NewsFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return News.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  static Future<List<News>> readAllNews() async {
    final db = await DatabaseService.instance.database;
    const orderBy = '${NewsFields.year} DESC, ${NewsFields.week} DESC, ${NewsFields.dayOfWeek} DESC, ${NewsFields.createdTime} DESC';
    final result = await db.query(
      tableNews,
      orderBy: orderBy);

    return result.map((json) => News.fromJson(json)).toList();
  }

  static Future<List<News>> readAllNewsSearch(String n) async {
    final db = await DatabaseService.instance.database;
    const orderBy = '${NewsFields.year} DESC, ${NewsFields.week} DESC, ${NewsFields.dayOfWeek} DESC, ${NewsFields.createdTime} DESC';

    final result = await db.query(
      tableNews, 
      where: '${NewsFields.title} LIKE ? OR ${NewsFields.text} LIKE ?',
      whereArgs: ['%$n%', '%$n%'],
      orderBy: orderBy
    );

    return result.map((json) => News.fromJson(json)).toList();
  }

  static Future<int> updateNews(News news) async {
    final db = await DatabaseService.instance.database;

    return db.update(
      tableNews,
      news.toJson(),
      where: '${NewsFields.id} = ?',
      whereArgs: [news.id],
    );
  }

  /// Synchronise the optional storyline association and its timeline entry.
  /// A news item remains valid when storylineId is null.
  static Future<void> syncStoryline({
    required News news,
    required int? storylineId,
  }) async {
    if (news.id == null) throw ArgumentError('News must be saved first.');
    final db = await DatabaseService.instance.database;
    await db.transaction((txn) async {
      await txn.delete('storyline_news', where: 'news_id = ?', whereArgs: [news.id]);
      await txn.delete(tableStorylineEvents,
          where: '${StorylineEventFields.newsId} = ?', whereArgs: [news.id]);
      if (storylineId == null) return;
      await txn.insert('storyline_news', {
        'storyline_id': storylineId,
        'news_id': news.id,
        'position': 0,
      });
      await txn.insert(tableStorylineEvents, {
        StorylineEventFields.storylineId: storylineId,
        StorylineEventFields.type: StorylineEventType.news,
        StorylineEventFields.title: news.title,
        StorylineEventFields.description: news.text,
        StorylineEventFields.year: news.year ?? DateTime.now().year,
        StorylineEventFields.week: news.week ?? 1,
        StorylineEventFields.dayOfWeek: news.dayOfWeek ?? 1,
        StorylineEventFields.position: 0,
        StorylineEventFields.newsId: news.id,
      });
    });
  }

  static Future<int?> readLinkedStorylineId(int newsId) async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query('storyline_news', columns: ['storyline_id'],
        where: 'news_id = ?', whereArgs: [newsId], limit: 1);
    return rows.isEmpty ? null : rows.first['storyline_id'] as int;
  }

  static Future<int> deleteNews(int id) async {
    final db = await DatabaseService.instance.database;

    return db.transaction((txn) async {
      await txn.delete(tableStorylineEvents,
          where: '${StorylineEventFields.newsId} = ?', whereArgs: [id]);
      await txn.delete('storyline_news', where: 'news_id = ?', whereArgs: [id]);
      return txn.delete(tableNews, where: '${NewsFields.id} = ?', whereArgs: [id]);
    });
  }
}