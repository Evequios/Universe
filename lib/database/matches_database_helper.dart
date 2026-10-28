import 'package:wwe_universe/classes/matches.dart';
import 'package:wwe_universe/database/database.dart';
import 'package:wwe_universe/database/shows_database_helper.dart';
import 'package:wwe_universe/database/stipulations_database_helper.dart';
import 'package:wwe_universe/database/superstars_database_helper.dart';
import 'package:wwe_universe/database/titles_database_helper.dart';

class MatchesDatabaseHelper {

  static Future<Matches> _fromMap(
    Map<String, Object?> json,
  ) async {

    final stipulationId =
        json[MatchesFields.stipulation] as int;

    final s1Id = json[MatchesFields.s1] as int;
    final s2Id = json[MatchesFields.s2] as int;
    final winnerId = json[MatchesFields.winner] as int?;

    final s3Id = json[MatchesFields.s3] as int?;
    final s4Id = json[MatchesFields.s4] as int?;
    final s5Id = json[MatchesFields.s5] as int?;
    final s6Id = json[MatchesFields.s6] as int?;
    final s7Id = json[MatchesFields.s7] as int?;
    final s8Id = json[MatchesFields.s8] as int?;

    final showId = json[MatchesFields.showId] as int?;
    final titleId = json[MatchesFields.titleId] as int?;

    return Matches(
      id: json[MatchesFields.id] as int?,
      stipulation:
          await StipulationsDatabaseHelper.readStipulation(stipulationId),
      s1: await SuperstarsDatabaseHelper.readSuperstar(s1Id),
      s2: await SuperstarsDatabaseHelper.readSuperstar(s2Id),
      s3: s3Id == null
          ? null
          : await SuperstarsDatabaseHelper.readSuperstar(s3Id),
      s4: s4Id == null
          ? null
          : await SuperstarsDatabaseHelper.readSuperstar(s4Id),
      s5: s5Id == null
          ? null
          : await SuperstarsDatabaseHelper.readSuperstar(s5Id),
      s6: s6Id == null
          ? null
          : await SuperstarsDatabaseHelper.readSuperstar(s6Id),
      s7: s7Id == null
          ? null
          : await SuperstarsDatabaseHelper.readSuperstar(s7Id),
      s8: s8Id == null
          ? null
          : await SuperstarsDatabaseHelper.readSuperstar(s8Id),
      winner: winnerId == null
          ? null
          : await SuperstarsDatabaseHelper.readSuperstar(winnerId),
      matchOrder: json[MatchesFields.matchOrder] as int,
      show: showId == null
          ? null
          : await ShowsDatabaseHelper.readShow(showId),
      title: titleId == null
          ? null
          : await TitlesDatabaseHelper.readTitle(titleId),
    );
  }

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
      return _fromMap(maps.first);
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

    return Future.wait(result.map(_fromMap));
  }

  static Future<List<Matches>> readAllMatchesSuperstar(int id) async {
    final db = await DatabaseService.instance.database;

    final result = await db.query(tableMatches,
    where: 's1 = $id OR s2 = $id OR s3 = $id OR s4 = $id OR s5 = $id OR s6 = $id OR s7 = $id OR s8 = $id');

    return Future.wait(result.map(_fromMap));
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