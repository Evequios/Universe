import 'package:wwe_universe/classes/teams.dart';
import 'package:wwe_universe/database/database.dart';
import 'package:wwe_universe/database/superstars_database_helper.dart';

class TeamsDatabaseHelper {

  static Future<Teams> _fromMap(
    Map<String, Object?> json,
  ) async {
    final member1Id = json[TeamsFields.member1] as int;
    final member2Id = json[TeamsFields.member2] as int;
    final member3Id = json[TeamsFields.member3] as int?;
    final member4Id = json[TeamsFields.member4] as int?;
    final member5Id = json[TeamsFields.member5] as int?;

    final member1 = await SuperstarsDatabaseHelper.readSuperstar(member1Id);
    final member2 = await SuperstarsDatabaseHelper.readSuperstar(member2Id);
    final member3 = member3Id == null
        ? null
        : await SuperstarsDatabaseHelper.readSuperstar(member3Id);
    final member4 = member4Id == null
        ? null
        : await SuperstarsDatabaseHelper.readSuperstar(member4Id);
    final member5 = member5Id == null
        ? null
        : await SuperstarsDatabaseHelper.readSuperstar(member5Id);

    return Teams(
      id: json[TeamsFields.id] as int?,
      name: json[TeamsFields.name] as String,
      member1: member1,
      member2: member2,
      member3: member3,
      member4: member4,
      member5: member5,
    );
  }

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
      return await _fromMap(maps.first);
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

    return Future.wait(result.map((json) => _fromMap(json)).toList());
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

    return Future.wait(result.map((json) => _fromMap(json)).toList());
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