import 'package:sqflite/sqflite.dart';
import 'package:wwe_universe/database/database.dart';
import 'package:wwe_universe/classes/superstars.dart';
import 'package:wwe_universe/classes/teams.dart';
import 'package:wwe_universe/database/superstars_database_helper.dart';
import 'package:wwe_universe/database/teams_database_helper.dart';

class StorylineParticipants {
  final List<Superstars> superstars;
  final List<Teams> teams;
  const StorylineParticipants({this.superstars = const [], this.teams = const []});
}

class StorylineParticipantsDatabaseHelper {
  static const _superstarsTable = 'storyline_superstars';
  static const _teamsTable = 'storyline_teams';

  static Future<void> replace({required int storylineId, required List<int> superstarIds, required List<int> teamIds}) async {
    final db = await DatabaseService.instance.database;
    await db.transaction((txn) async {
      await txn.delete(_superstarsTable, where: 'storyline_id = ?', whereArgs: [storylineId]);
      await txn.delete(_teamsTable, where: 'storyline_id = ?', whereArgs: [storylineId]);
      for (final id in superstarIds.toSet()) {
        await txn.insert(_superstarsTable, {'storyline_id': storylineId, 'superstar_id': id});
      }
      for (final id in teamIds.toSet()) {
        await txn.insert(_teamsTable, {'storyline_id': storylineId, 'team_id': id});
      }
    });
  }

  static Future<StorylineParticipants> read(int storylineId) async {
    final db = await DatabaseService.instance.database;
    final superstarRows = await db.query(_superstarsTable, columns: ['superstar_id'], where: 'storyline_id = ?', whereArgs: [storylineId]);
    final teamRows = await db.query(_teamsTable, columns: ['team_id'], where: 'storyline_id = ?', whereArgs: [storylineId]);
    final superstars = await Future.wait(superstarRows.map((r) => SuperstarsDatabaseHelper.readSuperstar(r['superstar_id'] as int)));
    final teams = await Future.wait(teamRows.map((r) => TeamsDatabaseHelper.readTeam(r['team_id'] as int)));
    return StorylineParticipants(superstars: superstars, teams: teams);
  }
}

