import 'package:wwe_universe/classes/show.dart';
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

    return db.update(
      tableShows,
      universeShows.toJson(),
      where: '${ShowFields.id} = ?',
      whereArgs: [universeShows.id],
    );
  }

  static Future<int> deleteShow(int id) async {
    final db = await DatabaseService.instance.database;

    return db.delete(
      tableShows,
      where: '${ShowFields.id} = ?',
      whereArgs: [id],
    );
  }
}