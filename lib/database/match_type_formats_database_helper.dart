import 'package:wwe_universe/classes/match_type_formats.dart';
import 'package:wwe_universe/classes/match_formats.dart';
import 'package:wwe_universe/database/database.dart';

class MatchTypeFormatsDatabaseHelper {
  static Future<List<MatchFormats>> readFormatsForType(int typeId) async {
    final db = await DatabaseService.instance.database;
    final rows = await db.rawQuery('''
      SELECT f.* FROM $tableMatchFormats f
      INNER JOIN $tableMatchTypeFormats tf
        ON tf.${MatchTypeFormatsFields.matchFormatId} = f.${MatchFormatsFields.id}
      WHERE tf.${MatchTypeFormatsFields.matchTypeId} = ?
        AND f.${MatchFormatsFields.isActive} = 1
      ORDER BY f.${MatchFormatsFields.name} COLLATE NOCASE ASC
    ''', [typeId]);
    return rows.map(MatchFormats.fromJson).toList();
  }

  static Future<List<int>> readFormatIdsForType(int typeId) async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query(tableMatchTypeFormats,
      columns: [MatchTypeFormatsFields.matchFormatId],
      where: '${MatchTypeFormatsFields.matchTypeId} = ?', whereArgs: [typeId]);
    return rows.map((row) => row[MatchTypeFormatsFields.matchFormatId] as int).toList();
  }

  static Future<void> setCompatibility(int typeId, List<int> formatIds) async {
    final db = await DatabaseService.instance.database;
    await db.transaction((txn) async {
      await txn.delete(tableMatchTypeFormats,
        where: '${MatchTypeFormatsFields.matchTypeId} = ?', whereArgs: [typeId]);
      for (final formatId in formatIds.toSet()) {
        await txn.insert(tableMatchTypeFormats, {
          MatchTypeFormatsFields.matchTypeId: typeId,
          MatchTypeFormatsFields.matchFormatId: formatId,
        });
      }
    });
  }
}
