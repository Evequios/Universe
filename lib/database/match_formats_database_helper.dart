
import 'package:wwe_universe/classes/match_formats.dart';
import 'package:wwe_universe/database/database.dart';
import 'package:wwe_universe/classes/match_record.dart';
import 'package:wwe_universe/classes/match_type_formats.dart';

class MatchFormatsDatabaseHelper {
  static Future<MatchFormats> createFormat(
    MatchFormats format,
  ) async {
    final db = await DatabaseService.instance.database;

    final id = await db.insert(
      tableMatchFormats,
      format.toJson()..remove(MatchFormatsFields.id),
    );

    return format.copy(id: id);
  }

  static Future<MatchFormats> readFormat(int id) async {
    final format = await readFormatIfExists(id);

    if (format == null) {
      throw Exception('Format $id not found');
    }

    return format;
  }

  static Future<MatchFormats?> readFormatIfExists(int? id) async {
    if (id == null) return null;

    final db = await DatabaseService.instance.database;

    final result = await db.query(
      tableMatchFormats,
      where: '${MatchFormatsFields.id} = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) return null;

    return MatchFormats.fromJson(result.first);
  }

  static Future<List<MatchFormats>> readAllFormats() async {
    final db = await DatabaseService.instance.database;

    final result = await db.query(
      tableMatchFormats,
      orderBy: '${MatchFormatsFields.name} COLLATE NOCASE ASC',
    );

    return result.map(MatchFormats.fromJson).toList();
  }

  static Future<int> updateFormat(MatchFormats format) async {
    if (format.id == null) {
      throw ArgumentError('A format must have an ID.');
    }

    final db = await DatabaseService.instance.database;

    final values = format.toJson()
      ..remove(MatchFormatsFields.id);

    return db.update(
      tableMatchFormats,
      values,
      where: '${MatchFormatsFields.id} = ?',
      whereArgs: [format.id],
    );
  }

  static Future<int> deleteFormat(int id) async {
    final db = await DatabaseService.instance.database;

    return db.transaction((txn) async {
      await txn.update(tableMatches, {MatchRecordFields.formatId: null}, where: '${MatchRecordFields.formatId} = ?', whereArgs: [id]);
      await txn.delete(tableMatchTypeFormats,
        where: '${MatchTypeFormatsFields.matchFormatId} = ?', whereArgs: [id]);
      return txn.delete(tableMatchFormats,
        where: '${MatchFormatsFields.id} = ?', whereArgs: [id]);
    });
  }
}
