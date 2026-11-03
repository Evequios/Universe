import 'package:wwe_universe/classes/teams.dart';
import 'package:wwe_universe/classes/match_record.dart';
import 'package:wwe_universe/classes/match_sides.dart';
import 'package:wwe_universe/classes/show.dart';
import 'package:wwe_universe/database/database.dart';
import 'package:wwe_universe/database/superstars_database_helper.dart';
import 'package:wwe_universe/database/matches_database_helper.dart';

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


  /// Returns only matches where this team was explicitly assigned to a side.
  /// The team is never inferred from its current roster.
  static Future<List<MatchRecord>> readTeamMatches(int teamId) async {
    final db = await DatabaseService.instance.database;
    final rows = await db.rawQuery('''
      SELECT DISTINCT
        m.${MatchRecordFields.id},
        s.${ShowFields.year},
        s.${ShowFields.week},
        s.${ShowFields.dayOfWeek},
        m.${MatchRecordFields.matchOrder}
      FROM $tableMatches m
      INNER JOIN $tableMatchSides ms
        ON ms.${MatchSidesFields.matchId} = m.${MatchRecordFields.id}
      INNER JOIN $tableShows s
        ON s.${ShowFields.id} = m.${MatchRecordFields.showId}
      WHERE ms.${MatchSidesFields.teamId} = ?
      ORDER BY s.${ShowFields.year} DESC,
               s.${ShowFields.week} DESC,
               s.${ShowFields.dayOfWeek} DESC,
               m.${MatchRecordFields.matchOrder} DESC
    ''', [teamId]);

    return Future.wait(rows.map((row) {
      final matchId = row[MatchRecordFields.id] as int;
      return MatchesDatabaseHelper.readMatch(matchId);
    }).toList());
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