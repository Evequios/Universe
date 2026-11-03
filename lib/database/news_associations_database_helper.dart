import 'package:sqflite/sqflite.dart';
import 'package:wwe_universe/database/database.dart';

/// Associations indépendantes entre une actualité et les entités de l'univers.
/// Les entités restent autonomes : seule la ligne de liaison est supprimée.
class NewsAssociationsDatabaseHelper {
  static const Map<String, String> _tables = {
    'superstars': 'news_superstars',
    'teams': 'news_teams',
    'titles': 'news_titles',
    'shows': 'news_shows',
  };
  static const Map<String, String> _columns = {
    'superstars': 'superstar_id',
    'teams': 'team_id',
    'titles': 'title_id',
    'shows': 'show_id',
  };

  static Future<Map<String, List<int>>> read(int newsId) async {
    final db = await DatabaseService.instance.database;
    final result = <String, List<int>>{};
    for (final type in _tables.keys) {
      final rows = await db.query(_tables[type]!, columns: [_columns[type]!],
        where: 'news_id = ?', whereArgs: [newsId], orderBy: '${_columns[type]} ASC');
      result[type] = rows.map((r) => r[_columns[type]!] as int).toList();
    }
    return result;
  }

  static Future<void> replace({required int newsId, required Map<String, List<int>> ids}) async {
    final db = await DatabaseService.instance.database;
    await db.transaction((txn) async {
      for (final type in _tables.keys) {
        await txn.delete(_tables[type]!, where: 'news_id = ?', whereArgs: [newsId]);
        for (final id in (ids[type] ?? const <int>[]).toSet()) {
          await txn.insert(_tables[type]!, {'news_id': newsId, _columns[type]!: id},
            conflictAlgorithm: ConflictAlgorithm.ignore);
        }
      }
    });
  }
}
