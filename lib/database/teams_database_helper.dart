import 'package:wwe_universe/classes/teams.dart';
import 'package:wwe_universe/database/database.dart';

class TeamsDatabaseHelper {
  static Future<Teams> createTeam(Teams team) async {
    final db = await DatabaseService.instance.database;

    final id = await db.insert(tableTeams, team.toJson());
    return team.copy(id: id);
  }

  static Future<Teams> readTeam(int id) async {
    final db = await DatabaseService.instance.database;

    final maps = await db.query(
      tableTeams,
      columns: TeamsFields.values,
      where: '${TeamsFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Teams.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  static Future<List<Teams>> readAllTeams() async {
    final db = await DatabaseService.instance.database;
    const orderBy = '${TeamsFields.name} ASC';

    final result = await db.query(
      tableTeams,
      orderBy: orderBy
    );

    return result.map((json) => Teams.fromJson(json)).toList();
  }

  static Future<List<Teams>> readAllTeamsSearch(String n) async {
    final db = await DatabaseService.instance.database;
    const orderBy = '${TeamsFields.name} ASC';

    final result = await db.query(
      tableTeams, 
      where: '${TeamsFields.name} LIKE ?',
      whereArgs: ['%$n%'],
      orderBy: orderBy
    );

    return result.map((json) => Teams.fromJson(json)).toList();
  }

  static Future<int> updateTeam(Teams team) async {
    final db = await DatabaseService.instance.database;

    return db.update(
      tableTeams,
      team.toJson(),
      where: '${TeamsFields.id} = ?',
      whereArgs: [team.id],
    );
  }

  static Future<int> deleteTeam(int id) async {
    final db = await DatabaseService.instance.database;

    return await db.delete(
      tableTeams,
      where: '${TeamsFields.id} = ?',
      whereArgs: [id],
    );
  }
}