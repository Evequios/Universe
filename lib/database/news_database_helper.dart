import 'package:wwe_universe/classes/news.dart';
import 'package:wwe_universe/database/database.dart';

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
    const orderBy = '${NewsFields.createdTime} DESC';
    final result = await db.query(
      tableNews,
      orderBy: orderBy);

    return result.map((json) => News.fromJson(json)).toList();
  }

  static Future<List<News>> readAllNewsSearch(String n) async {
    final db = await DatabaseService.instance.database;
    const orderBy = '${NewsFields.createdTime} DESC';

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

  static Future<int> deleteNews(int id) async {
    final db = await DatabaseService.instance.database;

    return await db.delete(
      tableNews,
      where: '${NewsFields.id} = ?',
      whereArgs: [id],
    );
  }
}