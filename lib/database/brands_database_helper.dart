import 'package:wwe_universe/classes/titles.dart';
import 'package:wwe_universe/classes/brands.dart';
import 'package:wwe_universe/classes/superstars.dart';
import 'package:wwe_universe/database/database.dart';

class BrandsDatabaseHelper {
  static Future<Brands> createBrand(Brands brand) async {
    final db = await DatabaseService.instance.database;

    final id = await db.insert(tableBrands, brand.toJson());
    return brand.copy(id: id);
  }

  static Future<Brands> readBrand(int id) async {
    final db = await DatabaseService.instance.database;

    final maps = await db.query(
      tableBrands,
      columns: BrandsFields.values,
      where: '${BrandsFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Brands.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  static Future<Brands?> readBrandIfExists(int id) async {
    final db = await DatabaseService.instance.database;

    final maps = await db.query(
      tableBrands,
      columns: BrandsFields.values,
      where: '${BrandsFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) {
      return null;
    }

    return Brands.fromJson(maps.first);
  }


  static Future<List<Brands>> readAllBrands() async {
    final db = await DatabaseService.instance.database;
    const orderBy = '${BrandsFields.name} ASC';
    final result = await db.query(
      tableBrands,
      orderBy: orderBy
    );

    return result.map((json) => Brands.fromJson(json)).toList();
  }

  static Future<int> updateBrand(Brands brand) async {
    final db = await DatabaseService.instance.database;

    return db.update(
      tableBrands,
      brand.toJson(),
      where: '${BrandsFields.id} = ?',
      whereArgs: [brand.id],
    );
  }

  
  static Future<int> deleteBrand(int id) async {
    final db = await DatabaseService.instance.database;

    return db.transaction((txn) async {
      await txn.update(
        tableTitles,
        {TitlesFields.brand: null},
        where: '${TitlesFields.brand} = ?',
        whereArgs: [id],
      );

      await txn.update(
        tableSuperstars,
        {SuperstarsFields.brand: null},
        where: '${SuperstarsFields.brand} = ?',
        whereArgs: [id],
      );

      return txn.delete(
        tableBrands,
        where: '${BrandsFields.id} = ?',
        whereArgs: [id],
      );
    });
  }

}