import 'package:wwe_universe/classes/matches.dart';
import 'package:wwe_universe/classes/shows.dart';
import 'package:wwe_universe/database/database.dart';

class ShowsDatabaseHelper {
  static Future<Shows> createShow(Shows universeShows) async {
    final db = await DatabaseService.instance.database;

    final id = await db.insert(tableShows, universeShows.toJson());
    return universeShows.copy(id: id);
  }

  static Future<Shows> readShow(int id) async {
    final db = await DatabaseService.instance.database;

    final maps = await db.query(
      tableShows,
      columns: ShowFields.values,
      where: '${ShowFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Shows.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  static Future<List<Shows>> readAllShows() async {
    final db = await DatabaseService.instance.database;
    const orderBy = '${ShowFields.year} DESC, ${ShowFields.week} DESC';

    final result = await db.query(
      tableShows,
      orderBy: orderBy);

    return result.map((json) => Shows.fromJson(json)).toList();
  }

  static Future<int> updateShow(Shows universeShows) async {
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

    await db.delete(
      tableMatches,
      where: '${MatchesFields.showId} = ?',
      whereArgs: [id]
    );

    return await db.delete(
      tableShows,
      where: '${ShowFields.id} = ?',
      whereArgs: [id],
    );
  }
}