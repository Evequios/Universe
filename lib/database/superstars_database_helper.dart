import 'dart:collection';
import 'package:wwe_universe/classes/superstars.dart';
import 'package:wwe_universe/classes/teams.dart';
import 'package:wwe_universe/classes/titles.dart';
import 'package:wwe_universe/database/database.dart';
import 'package:wwe_universe/database/brands_database_helper.dart';

class SuperstarsDatabaseHelper {

  static Future<Superstars> _fromMap(
    Map<String, Object?> json,
  ) async {
    final brandId = json[SuperstarsFields.brand] as int?;

    final brand = brandId == null || brandId == 0
        ? null
        : await BrandsDatabaseHelper.readBrandIfExists(brandId);

    return Superstars(
      id: json[SuperstarsFields.id] as int?,
      name: json[SuperstarsFields.name] as String,
      brand: brand,
      orientation: json[SuperstarsFields.orientation] as String,
      division: json[SuperstarsFields.division] as int?,
    );
  }

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
      return await _fromMap(maps.first);
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

    return Future.wait(result.map((json) => _fromMap(json)).toList());
  }

  static Future<List<Superstars>> readAllSuperstarsFilter(int brandId) async {
    final db = await DatabaseService.instance.database;
    const orderBy = '${SuperstarsFields.name} ASC';

    final result = await db.query(
      tableSuperstars, 
      where: '${SuperstarsFields.brand} = ? ',
      whereArgs: [brandId],
      orderBy: orderBy
    );

    return await Future.wait(
      result.map((json) => _fromMap(json)),
    );
  }

  static Future<List<Superstars>> readAllSuperstarsDivision(int titleId) async {
    final db = await DatabaseService.instance.database;
    const orderBy = '${SuperstarsFields.name} ASC';

    final result = await db.query(
      tableSuperstars, 
      where: '${SuperstarsFields.division} = ? ',
      whereArgs: [titleId],
      orderBy: orderBy
    );

    return await Future.wait(
      result.map((json) => _fromMap(json)),
    );
  }

  static Future<List<Superstars>> readAllSuperstarsSearch(String n) async {
    final db = await DatabaseService.instance.database;
    const orderBy = '${SuperstarsFields.name} ASC';

    final result = await db.query(
      tableSuperstars, 
      where: '${SuperstarsFields.name} LIKE ?',
      whereArgs: ['%$n%'],
      orderBy: orderBy
    );

    return await Future.wait(
      result.map((json) => _fromMap(json)),
    );
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

    return db.transaction((txn) async {
      // Retire la Superstar des titres.
      await txn.update(
        tableTitles,
        {TitlesFields.holder1: null},
        where: '${TitlesFields.holder1} = ?',
        whereArgs: [id],
      );

      await txn.update(
        tableTitles,
        {TitlesFields.holder2: null},
        where: '${TitlesFields.holder2} = ?',
        whereArgs: [id],
      );

      // Supprime les équipes auxquelles elle appartient.
      // Les camps historiques des combats sont conservés.
      await txn.delete(
        tableTeams,
        where: '${TeamsFields.member1} = ? '
            'OR ${TeamsFields.member2} = ? '
            'OR ${TeamsFields.member3} = ? '
            'OR ${TeamsFields.member4} = ? '
            'OR ${TeamsFields.member5} = ?',
        whereArgs: List.filled(5, id),
      );

      // Les références Superstar des participants et des vainqueurs
      // seront mises à NULL par les clés étrangères.
      // Les noms historiques restent conservés.
      return txn.delete(
        tableSuperstars,
        where: '${SuperstarsFields.id} = ?',
        whereArgs: [id],
      );
    });
  }



  static Future draft(HashMap map) async {
    final db = await DatabaseService.instance.database;
      
    map.forEach((i, value) {
      db.rawUpdate('UPDATE $tableSuperstars SET ${SuperstarsFields.brand} = ? WHERE ${SuperstarsFields.id} = ?', [value, i]);
    });
  }  
}