import 'dart:collection';

import 'package:wwe_universe/classes/matches.dart';
import 'package:wwe_universe/classes/superstars.dart';
import 'package:wwe_universe/classes/teams.dart';
import 'package:wwe_universe/classes/titles.dart';
import 'package:wwe_universe/database/database.dart';

class SuperstarsDatabaseHelper {
  static Future<Superstars> createSuperstar(Superstars universeSuperstars) async {
    final db = await DatabaseService.instance.database;

    final id = await db.insert(tableSuperstars, universeSuperstars.toJson());
    return universeSuperstars.copy(id: id);
  }

  static Future<Superstars> readSuperstar(int id) async {
    final db = await DatabaseService.instance.database;

    final maps = await db.query(
      tableSuperstars,
      columns: SuperstarsFields.values,
      where: '${SuperstarsFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Superstars.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  static Future<List<Superstars>> readAllSuperstars() async {
    final db = await DatabaseService.instance.database;
    const orderBy = '${SuperstarsFields.name} ASC';

    final result = await db.query(
      tableSuperstars, 
      orderBy: orderBy
    );

    return Future.wait(result.map((json) => Superstars.fromJson(json)).toList());
  }

  static Future<List<Future<Superstars>>> readAllSuperstarsFilter(int brandId) async {
    final db = await DatabaseService.instance.database;
    const orderBy = '${SuperstarsFields.name} ASC';

    final result = await db.query(
      tableSuperstars, 
      where: '${SuperstarsFields.brand} = ? ',
      whereArgs: [brandId],
      orderBy: orderBy
    );

    return result.map((json) => Superstars.fromJson(json)).toList();
  }

  static Future<List<Future<Superstars>>> readAllSuperstarsDivision(int titleId) async {
    final db = await DatabaseService.instance.database;
    const orderBy = '${SuperstarsFields.name} ASC';

    final result = await db.query(
      tableSuperstars, 
      where: '${SuperstarsFields.division} = ? ',
      whereArgs: [titleId],
      orderBy: orderBy
    );

    return result.map((json) => Superstars.fromJson(json)).toList();
  }

  static Future<List<Future<Superstars>>> readAllSuperstarsSearch(String n) async {
    final db = await DatabaseService.instance.database;
    const orderBy = '${SuperstarsFields.name} ASC';

    final result = await db.query(
      tableSuperstars, 
      where: '${SuperstarsFields.name} LIKE ?',
      whereArgs: ['%$n%'],
      orderBy: orderBy
    );

    return result.map((json) => Superstars.fromJson(json)).toList();
  }

  static Future<int> updateSuperstar(Superstars universeSuperstars) async {
    final db = await DatabaseService.instance.database;

    return db.update(
      tableSuperstars,
      universeSuperstars.toJson(),
      where: '${SuperstarsFields.id} = ?',
      whereArgs: [universeSuperstars.id],
    );
  }

  static Future<int> deleteSuperstar(int id) async {
    final db = await DatabaseService.instance.database;

    Map<String, dynamic> row = {
      TitlesFields.holder1 : 0,
      TitlesFields.holder2 : 0
    };
    await db.update(
      tableTitles, 
      row,
      where: '${TitlesFields.holder1} = $id OR ${TitlesFields.holder2} = $id'
    );

    await db.delete(
      tableMatches,
      where: '${MatchesFields.s1} = $id OR ${MatchesFields.s2} = $id OR ${MatchesFields.s3} = $id OR ${MatchesFields.s4} = $id OR ${MatchesFields.s5} = $id OR ${MatchesFields.s6} = $id OR ${MatchesFields.s7} = $id OR ${MatchesFields.s8} = $id '
    );

    await db.delete(
      tableTeams,
      where: '${TeamsFields.member1} = $id OR ${TeamsFields.member2} = $id OR ${TeamsFields.member3} = $id OR ${TeamsFields.member4} = $id OR ${TeamsFields.member5} = $id'
    );
    
    return await db.delete(
      tableSuperstars,
      where: '${SuperstarsFields.id} = ?',
      whereArgs: [id],
    );
  }

  static Future draft(HashMap map) async {
    final db = await DatabaseService.instance.database;
      
    map.forEach((i, value) {
      db.rawUpdate('UPDATE $tableSuperstars SET ${SuperstarsFields.brand} = ? WHERE ${SuperstarsFields.id} = ?', [value, i]);
    });
  }  
}