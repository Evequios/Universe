import 'package:wwe_universe/classes/matches.dart';
import 'package:wwe_universe/classes/stipulations.dart';
import 'package:wwe_universe/database/database.dart';

class StipulationsDatabaseHelper {
  static Future<Stipulations> createStipulation(Stipulations stipulation) async {
    final db = await DatabaseService.instance.database;

    final id = await db.insert(tableStipulations, stipulation.toJson());
    return stipulation.copy(id: id);
  }


  static Future<Stipulations> readStipulation(int id) async {
    final db = await DatabaseService.instance.database;

    final maps = await db.query(
      tableStipulations,
      columns: StipulationsFields.values,
      where: '${StipulationsFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Stipulations.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  static Future<List<Stipulations>> readAllStipulations() async {
    final db = await DatabaseService.instance.database;
    const orderBy = '${StipulationsFields.type} ASC, ${StipulationsFields.stipulation} ASC';
    final result = await db.query(
      tableStipulations,
      orderBy: orderBy
    );

    return result.map((json) => Stipulations.fromJson(json)).toList();
  }

  static Future<List<Stipulations>> readAllStipulationsSearch(String n) async {
    final db = await DatabaseService.instance.database;
    const orderBy = '${StipulationsFields.type} ASC, ${StipulationsFields.stipulation} ASC';

    final result = await db.query(
      tableStipulations, 
      where: '${StipulationsFields.type} LIKE ? OR ${StipulationsFields.stipulation} LIKE ?',
      whereArgs: ['%$n%', '%$n%'],
      orderBy: orderBy
    );

    return result.map((json) => Stipulations.fromJson(json)).toList();
  }


  static Future<int> updateStipulation(Stipulations stipulation) async {
    final db = await DatabaseService.instance.database;

    return db.update(
      tableStipulations,
      stipulation.toJson(),
      where: '${StipulationsFields.id} = ?',
      whereArgs: [stipulation.id],
    );
  }

  static Future<int> deleteStipulation(int id) async {
    final db = await DatabaseService.instance.database;

    await db.delete(
      tableMatches,
      where: '${MatchesFields.stipulation} = ?',
      whereArgs: [id],
    );

    return await db.delete(
      tableStipulations,
      where: '${StipulationsFields.id} = ?',
      whereArgs: [id],
    );
  }
}