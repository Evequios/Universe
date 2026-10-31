import 'package:wwe_universe/classes/match_record.dart';
import 'package:wwe_universe/classes/stipulations.dart';
import 'package:wwe_universe/database/database.dart';

class StipulationsDatabaseHelper {
  static Future<Stipulations> createStipulation(
    Stipulations stipulation,
  ) async {
    final db = await DatabaseService.instance.database;

    final values = stipulation.toJson()
      ..remove(StipulationsFields.id);

    final id = await db.insert(tableStipulations, values);

    return stipulation.copy(id: id);
  }

  static Future<Stipulations> readStipulation(int id) async {
    final stipulation = await readStipulationIfExists(id);

    if (stipulation == null) {
      throw Exception('Stipulation $id not found');
    }

    return stipulation;
  }

  static Future<Stipulations?> readStipulationIfExists(int? id) async {
    if (id == null) return null;

    final db = await DatabaseService.instance.database;

    final result = await db.query(
      tableStipulations,
      where: '${StipulationsFields.id} = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) return null;

    return Stipulations.fromJson(result.first);
  }

  static Future<List<Stipulations>> readAllStipulations() async {
    final db = await DatabaseService.instance.database;

    final result = await db.query(
      tableStipulations,
      orderBy:
          '${StipulationsFields.stipulation} COLLATE NOCASE ASC',
    );

    return result.map(Stipulations.fromJson).toList();
  }

  static Future<List<Stipulations>> readAllStipulationsSearch(
    String search,
  ) async {
    final db = await DatabaseService.instance.database;

    final result = await db.query(
      tableStipulations,
      where: '${StipulationsFields.stipulation} LIKE ?',
      whereArgs: ['%$search%'],
      orderBy:
          '${StipulationsFields.stipulation} COLLATE NOCASE ASC',
    );

    return result.map(Stipulations.fromJson).toList();
  }

  static Future<int> updateStipulation(
    Stipulations stipulation,
  ) async {
    if (stipulation.id == null) {
      throw ArgumentError('Une stipulation doit avoir un identifiant.');
    }

    final db = await DatabaseService.instance.database;

    final values = stipulation.toJson()
      ..remove(StipulationsFields.id);

    return db.update(
      tableStipulations,
      values,
      where: '${StipulationsFields.id} = ?',
      whereArgs: [stipulation.id],
    );
  }

  static Future<int> deleteStipulation(int id) async {
    final db = await DatabaseService.instance.database;

    return db.transaction((txn) async {
      await txn.update(
        tableMatches,
        {MatchRecordFields.stipulationId: null},
        where: '${MatchRecordFields.stipulationId} = ?',
        whereArgs: [id],
      );

      return txn.delete(
        tableStipulations,
        where: '${StipulationsFields.id} = ?',
        whereArgs: [id],
      );
    });
  }
}
