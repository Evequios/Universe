import 'package:wwe_universe/classes/match_types.dart';
import 'package:wwe_universe/classes/match_type_formats.dart';
import 'package:wwe_universe/database/database.dart';
import 'package:wwe_universe/classes/match_record.dart';

class MatchTypesDatabaseHelper {
  static Future<MatchTypes> create(MatchTypes value) async {
    final db = await DatabaseService.instance.database;
    final values = value.toJson()..remove(MatchTypesFields.id);
    final id = await db.insert(tableMatchTypes, values);
    return value.copy(id: id);
  }

  static Future<List<MatchTypes>> readAll({bool activeOnly = true}) async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query(tableMatchTypes,
      where: activeOnly ? '${MatchTypesFields.isActive} = 1' : null,
      orderBy: '${MatchTypesFields.name} COLLATE NOCASE ASC');
    return rows.map(MatchTypes.fromJson).toList();
  }

  static Future<MatchTypes?> readIfExists(int? id) async {
    if (id == null) return null;
    final db = await DatabaseService.instance.database;
    final rows = await db.query(tableMatchTypes,
      where: '${MatchTypesFields.id} = ?', whereArgs: [id], limit: 1);
    return rows.isEmpty ? null : MatchTypes.fromJson(rows.first);
  }

  static Future<int> update(MatchTypes value) async {
    if (value.id == null) throw ArgumentError('Match type has no ID.');
    final db = await DatabaseService.instance.database;
    final values = value.toJson()..remove(MatchTypesFields.id);
    return db.update(tableMatchTypes, values,
      where: '${MatchTypesFields.id} = ?', whereArgs: [value.id]);
  }

  static Future<int> delete(int id) async {
    final db = await DatabaseService.instance.database;
    return db.transaction((txn) async {
      await txn.delete(tableMatchTypeFormats,
        where: '${MatchTypeFormatsFields.matchTypeId} = ?', whereArgs: [id]);
      await txn.update(tableMatches, {MatchRecordFields.matchTypeId: null}, where: '${MatchRecordFields.matchTypeId} = ?', whereArgs: [id]);
      return txn.delete(tableMatchTypes,
        where: '${MatchTypesFields.id} = ?', whereArgs: [id]);
    });
  }
}
