import 'package:wwe_universe/classes/matches.dart';
import 'package:wwe_universe/database/database.dart';

class MatchesDatabaseHelper {
  static Future<Matches> createMatch(Matches universeMatches) async {
    final db = await DatabaseService.instance.database;

    final id = await db.insert(tableMatches, universeMatches.toJson());
    return universeMatches.copy(id: id);
  }

  static Future<Matches> readMatch(int id) async {
    final db = await DatabaseService.instance.database;

    final maps = await db.query(
      tableMatches,
      columns: MatchesFields.values,
      where: '${MatchesFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Matches.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  static Future<List<Matches>> readAllMatches(int showId) async {
    final db = await DatabaseService.instance.database;

    final result = await db.query(tableMatches,
    where: 'showId = ?',
    whereArgs: [showId],
    orderBy: MatchesFields.matchOrder);

    return result.map((json) => Matches.fromJson(json)).toList();
  }

  static Future<List<Matches>> readAllMatchesSuperstar(int id) async {
    final db = await DatabaseService.instance.database;

    final result = await db.query(tableMatches,
    where: 's1 = $id OR s2 = $id OR s3 = $id OR s4 = $id OR s5 = $id OR s6 = $id OR s7 = $id OR s8 = $id');

    return result.map((json) => Matches.fromJson(json)).toList();
  }

  static Future<int> updateMatches(Matches universeMatches) async {
    final db = await DatabaseService.instance.database;

    return db.update(
      tableMatches,
      universeMatches.toJson(),
      where: '${MatchesFields.id} = ?',
      whereArgs: [universeMatches.id],
    );
  }

  static Future<int> deleteMatch(int id) async {
    final db = await DatabaseService.instance.database;

    return await db.delete(
      tableMatches,
      where: '${MatchesFields.id} = ?',
      whereArgs: [id],
    );
  }
}