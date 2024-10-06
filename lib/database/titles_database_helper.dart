import 'package:wwe_universe/classes/titles.dart';
import 'package:wwe_universe/database/database.dart';

class TitlesDatabaseHelper {
  static Future<Titles> createTitle(Titles title) async {
    final db = await DatabaseService.instance.database;

    final id = await db.insert(tableTitles, title.toJson());
    return title.copy(id: id);
  }

  static Future<Titles> readTitle(int id) async {
    final db = await DatabaseService.instance.database;

    final maps = await db.query(
      tableTitles,
      columns: TitlesFields.values,
      where: '${TitlesFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Titles.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  static Future<List<Titles>> readAllTitles() async {
    final db = await DatabaseService.instance.database;
    const orderBy = '${TitlesFields.name} ASC';
    final result = await db.query(
      tableTitles,
      orderBy: orderBy,
    );

    return result.map((json) => Titles.fromJson(json)).toList();
  }

  static Future<List<Titles>> readAllTitlesSearch(String n) async {
    final db = await DatabaseService.instance.database;
    const orderBy = '${TitlesFields.name} ASC';

    final result = await db.query(
      tableTitles, 
      where: '${TitlesFields.name} LIKE ?',
      whereArgs: ['%$n%'],
      orderBy: orderBy
    );

    return result.map((json) => Titles.fromJson(json)).toList();
  }

  static Future<int> updateTitle(Titles title) async {
    final db = await DatabaseService.instance.database;

    return db.update(
      tableTitles,
      title.toJson(),
      where: '${TitlesFields.id} = ?',
      whereArgs: [title.id],
    );
  }

  static Future setChampion(Titles title, List<int> winners) async {
    final db = await DatabaseService.instance.database;

    if(title.tag == 0) {
      db.rawUpdate('UPDATE $tableTitles SET ${TitlesFields.holder1} = ? WHERE ${TitlesFields.id} = ?', [winners[0], title.id]);
    } else {
      db.rawUpdate('UPDATE $tableTitles SET ${TitlesFields.holder1} = ?, ${TitlesFields.holder2} = ? WHERE ${TitlesFields.id} = ?', [winners[0], winners[1], title.id]);
    }

  }

  static Future<int> deleteTitle(int id) async {
    final db = await DatabaseService.instance.database;

    return await db.delete(
      tableTitles,
      where: '${TitlesFields.id} = ?',
      whereArgs: [id],
    );
  }
}