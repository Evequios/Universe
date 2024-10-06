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

    Map<String, dynamic> row = {
      SuperstarsFields.brand : 0,
    };
    await db.update(
      tableSuperstars, 
      row,
      where: '${SuperstarsFields.brand} = ?',
      whereArgs: [id]
    );

    return await db.delete(
      tableBrands,
      where: '${BrandsFields.id} = ?',
      whereArgs: [id],
    );
  }
}