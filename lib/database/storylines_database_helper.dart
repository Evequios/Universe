import 'package:wwe_universe/classes/storylines.dart';
import 'package:wwe_universe/database/database.dart';

class StorylinesDatabaseHelper {
  static Future<Storylines> createStoryline(Storylines universeStorylines) async {
    final db = await DatabaseService.instance.database;

    final id = await db.insert(tableStorylines, universeStorylines.toJson());
    return universeStorylines.copy(id: id);
  }

  static Future<Storylines> readStoryline(int id) async {
    final db = await DatabaseService.instance.database;

    final maps = await db.query(
      tableStorylines,
      columns: StorylinesFields.values,
      where: '${StorylinesFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Storylines.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  static Future<List<Storylines>> readAllStorylines() async {
    final db = await DatabaseService.instance.database;
    const orderBy = '${StorylinesFields.id} DESC';

    final result = await db.query(
      tableStorylines,
      orderBy: orderBy
    );

    return result.map((json) => Storylines.fromJson(json)).toList();
  }

  static Future<List<Storylines>> readAllStorylinesSearch(String n) async {
    final db = await DatabaseService.instance.database;
    const orderBy = '${StorylinesFields.id} DESC';

    final result = await db.query(
      tableStorylines, 
      where: '${StorylinesFields.title} LIKE ? OR ${StorylinesFields.text} LIKE ?',
      whereArgs: ['%$n%', '%$n%'],
      orderBy: orderBy
    );

    return result.map((json) => Storylines.fromJson(json)).toList();
  }

  static Future<int> updateStoryline(Storylines storyline) async {
    final db = await DatabaseService.instance.database;

    return db.update(
      tableStorylines,
      storyline.toJson(),
      where: '${StorylinesFields.id} = ?',
      whereArgs: [storyline.id],
    );
  }

  static Future<int> deleteStoryline(int id) async {
    final db = await DatabaseService.instance.database;

    return await db.delete(
      tableStorylines,
      where: '${StorylinesFields.id} = ?',
      whereArgs: [id],
    );
  }
}