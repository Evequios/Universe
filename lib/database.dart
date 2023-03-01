import 'package:sqflite/sqflite.dart';
import 'package:wwe_universe/classes/Universe/UniverseBrands.dart';
import 'package:wwe_universe/classes/Universe/UniverseMatches.dart';
import 'package:wwe_universe/classes/Universe/UniverseNews.dart';
import 'package:wwe_universe/classes/Universe/UniverseShows.dart';
import 'package:wwe_universe/classes/Universe/UniverseStipulations.dart';
import 'package:wwe_universe/classes/Universe/UniverseStorylines.dart';
import 'package:wwe_universe/classes/Universe/UniverseSuperstars.dart';
import 'package:wwe_universe/classes/Universe/UniverseTitles.dart';
import 'NavBar.dart';
import 'main.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';


class UniverseDatabase {
  static final UniverseDatabase instance = UniverseDatabase._init();

  static Database? _database;

  UniverseDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('wwe_universe_database.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 37, onCreate: _createDB, onUpgrade: _updateDB);
  }

  Future _createDB(Database db, int version) async {
    final idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    final textType = 'TEXT NOT NULL';
    final intTypeNN = 'INTEGER NOT NULL';
    final intType = 'INTEGER';

    db.execute('''DROP TABLE IF EXISTS $tableMatches;''');
   db.execute('''DROP TABLE IF EXISTS $tableShows;''');
   db.execute('''DROP TABLE IF EXISTS $tableStipulations;''');
   db.execute('''DROP TABLE IF EXISTS $tableStorylines;''');
   db.execute('''DROP TABLE IF EXISTS $tableSuperstars;''');
   db.execute('''DROP TABLE IF EXISTS $tableNews;''');
    await db.execute('''
CREATE TABLE IF NOT EXISTS $tableNews ( 
  ${NewsFields.id} $idType, 
  ${NewsFields.titre} $textType,
  ${NewsFields.texte} $textType,
  ${NewsFields.createdTime} $textType,
  ${NewsFields.categorie} $textType DEFAULT 'Autre'
  ); ''');


  await db.execute('''
CREATE TABLE IF NOT EXISTS $tableSuperstars ( 
  ${SuperstarsFields.id} $idType, 
  ${SuperstarsFields.nom} $textType,
  ${SuperstarsFields.show} $textType,
  ${SuperstarsFields.orientation} $textType
  ); ''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS $tableStorylines ( 
      ${StorylinesFields.id} $idType, 
      ${StorylinesFields.titre} $textType,
      ${StorylinesFields.texte} $textType,
      ${StorylinesFields.debut} $textType,
      ${StorylinesFields.fin} $textType
      ); ''');

      await db.execute('''
   CREATE TABLE IF NOT EXISTS $tableShows( 
  ${ShowFields.id} $idType, 
   ${ShowFields.nom} $textType,
   ${ShowFields.annee} $intTypeNN,
   ${ShowFields.semaine} $intTypeNN,
   ${ShowFields.resume} $textType
   ); ''');

    await db.execute('''
  CREATE TABLE IF NOT EXISTS $tableStipulations(
    ${StipulationsFields.id} $idType,
    ${StipulationsFields.type} $textType,
    ${StipulationsFields.stipulation} $textType
  );''');
   await db.execute('''
   CREATE TABLE IF NOT EXISTS $tableMatches( 
  ${MatchesFields.id} $idType, 
  ${MatchesFields.stipulation} $intTypeNN,
   ${MatchesFields.s1} $intTypeNN,
   ${MatchesFields.s2} $intTypeNN,
   ${MatchesFields.s3} $intType,
   ${MatchesFields.s4} $intType,
   ${MatchesFields.s5} $intType,
   ${MatchesFields.s6} $intType,
   ${MatchesFields.s7} $intType,
   ${MatchesFields.s8} $intType,
   ${MatchesFields.gagnant} $intTypeNN,
   ${MatchesFields.ordre} $intTypeNN DEFAULT 0,
   ${MatchesFields.showId} $intTypeNN
   ); ''');
  }

  Future _updateDB(Database db, int oldVersion, int newVersion) async {
    final idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    final textType = 'TEXT NOT NULL';
    final intTypeNN = 'INTEGER NOT NULL';
    final intType = 'INTEGER';
    final booleanTypeNN = 'BOOLEAN NOT NULL';
    if (newVersion > oldVersion) {
   
   db.execute('''
DROP TABLE IF EXISTS $tableTitles
  ; ''');

  db.execute('''
CREATE TABLE IF NOT EXISTS $tableTitles ( 
  ${TitlesFields.id} $idType, 
  ${TitlesFields.nom} $textType,
  ${TitlesFields.brand} $intType,
  ${TitlesFields.tag} $booleanTypeNN,
  ${TitlesFields.holder1} $intType,
  ${TitlesFields.holder2} $intType
  ); ''');
  }
  }

// News
  Future<UniverseNews> createNews(UniverseNews news) async {
    final db = await instance.database;

    final id = await db.insert(tableNews, news.toJson());
    return news.copy(id: id);
  }

  Future<UniverseNews> readNews(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      tableNews,
      columns: NewsFields.values,
      where: '${NewsFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return UniverseNews.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<UniverseNews>> readAllNews() async {
    final db = await instance.database;
    // final result =
    //     await db.rawQuery('SELECT * FROM $tableNotes ORDER BY $orderBy');

    final result = await db.query(tableNews);

    return result.map((json) => UniverseNews.fromJson(json)).toList();
  }

  Future<int> updateNews(UniverseNews news) async {
    final db = await instance.database;

    return db.update(
      tableNews,
      news.toJson(),
      where: '${NewsFields.id} = ?',
      whereArgs: [news.id],
    );
  }

  Future<int> deleteNews(int id) async {
    final db = await instance.database;

    return await db.delete(
      tableNews,
      where: '${NewsFields.id} = ?',
      whereArgs: [id],
    );
  }

//Superstars
Future<UniverseSuperstars> createSuperstar(UniverseSuperstars universeSuperstars) async {
    final db = await instance.database;

    final id = await db.insert(tableSuperstars, universeSuperstars.toJson());
    return universeSuperstars.copy(id: id);
  }

  Future<UniverseSuperstars> readSuperstar(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      tableSuperstars,
      columns: SuperstarsFields.values,
      where: '${SuperstarsFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return UniverseSuperstars.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<UniverseSuperstars>> readAllSuperstars() async {
    final db = await instance.database;
    final orderBy = '${SuperstarsFields.nom} ASC';
    // final result =
    //     await db.rawQuery('SELECT * FROM $tableIRLSuperstars ORDER BY $orderBy');

    final result = await db.query(tableSuperstars, orderBy: orderBy);

    return result.map((json) => UniverseSuperstars.fromJson(json)).toList();
  }

  Future<int> updateSuperstar(UniverseSuperstars universeSuperstars) async {
    final db = await instance.database;

    return db.update(
      tableSuperstars,
      universeSuperstars.toJson(),
      where: '${SuperstarsFields.id} = ?',
      whereArgs: [universeSuperstars.id],
    );
  }

  Future<int> deleteSuperstar(int id) async {
    final db = await instance.database;

    return await db.delete(
      tableSuperstars,
      where: '${SuperstarsFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;

    db.close();
  }

// Storylines
  Future<UniverseStorylines> createStoryline(UniverseStorylines universeStorylines) async {
    final db = await instance.database;

    final id = await db.insert(tableStorylines, universeStorylines.toJson());
    return universeStorylines.copy(id: id);
  }

  Future<UniverseStorylines> readStoryline(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      tableStorylines,
      columns: StorylinesFields.values,
      where: '${StorylinesFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return UniverseStorylines.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<UniverseStorylines>> readAllStorylines() async {
    final db = await instance.database;

    final result = await db.query(tableStorylines);

    return result.map((json) => UniverseStorylines.fromJson(json)).toList();
  }

  Future<int> updateStoryline(UniverseStorylines universeStoryline) async {
    final db = await instance.database;

    return db.update(
      tableStorylines,
      universeStoryline.toJson(),
      where: '${StorylinesFields.id} = ?',
      whereArgs: [StorylinesFields.id],
    );
  }

  Future<int> deleteStoryline(int id) async {
    final db = await instance.database;

    return await db.delete(
      tableStorylines,
      where: '${StorylinesFields.id} = ?',
      whereArgs: [id],
    );
  }


  // Shows
  Future<UniverseShows> createShow(UniverseShows universeShows) async {
    final db = await instance.database;

    final id = await db.insert(tableShows, universeShows.toJson());
    return universeShows.copy(id: id);
  }

  Future<UniverseShows> readShow(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      tableShows,
      columns: ShowFields.values,
      where: '${ShowFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return UniverseShows.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<UniverseShows>> readAllShows() async {
    final db = await instance.database;
    // final result =
    //     await db.rawQuery('SELECT * FROM $tableNotes ORDER BY $orderBy');

    final result = await db.query(tableShows);

    return result.map((json) => UniverseShows.fromJson(json)).toList();
  }

  Future<int> updateShow(UniverseShows universeShows) async {
    final db = await instance.database;

    return db.update(
      tableShows,
      universeShows.toJson(),
      where: '${ShowFields.id} = ?',
      whereArgs: [universeShows.id],
    );
  }

  Future<int> deleteShow(int id) async {
    final db = await instance.database;

    return await db.delete(
      tableShows,
      where: '${ShowFields.id} = ?',
      whereArgs: [id],
    );
  }




  // Matches
  Future<UniverseMatches> createMatch(UniverseMatches universeMatches) async {
    final db = await instance.database;

    final id = await db.insert(tableMatches, universeMatches.toJson());
    return universeMatches.copy(id: id);
  }

  Future<UniverseMatches> readMatch(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      tableMatches,
      columns: MatchesFields.values,
      where: '${MatchesFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return UniverseMatches.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<UniverseMatches>> readAllMatches(int showId) async {
    final db = await instance.database;
    // final result =
    //     await db.rawQuery('SELECT * FROM $tableIRLMatches WHERE showId =?', [showId]);

    final result = await db.query(tableMatches,
    where: 'showId = ?',
    whereArgs: [showId]);

    return result.map((json) => UniverseMatches.fromJson(json)).toList();
  }

  Future<int> updateMatches(UniverseMatches universeMatches) async {
    final db = await instance.database;

    return db.update(
      tableMatches,
      universeMatches.toJson(),
      where: '${MatchesFields.id} = ?',
      whereArgs: [universeMatches.id],
    );
  }

  Future<int> deleteMatch(int id) async {
    final db = await instance.database;

    return await db.delete(
      tableMatches,
      where: '${MatchesFields.id} = ?',
      whereArgs: [id],
    );
  }


  // Stipulations
  Future<UniverseStipulations> createStipulation(UniverseStipulations stipulation) async {
    final db = await instance.database;

    final id = await db.insert(tableStipulations, stipulation.toJson());
    return stipulation.copy(id: id);
  }


  Future<UniverseStipulations> readStipulation(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      tableStipulations,
      columns: StipulationsFields.values,
      where: '${StipulationsFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return UniverseStipulations.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<UniverseStipulations>> readAllStipulations() async {
    final db = await instance.database;
    // final result =
    //     await db.rawQuery('SELECT * FROM $tableNotes ORDER BY $orderBy');

    final result = await db.query(tableStipulations);

    return result.map((json) => UniverseStipulations.fromJson(json)).toList();
  }

  Future<int> updateStipulation(UniverseStipulations stipulation) async {
    final db = await instance.database;

    return db.update(
      tableStipulations,
      stipulation.toJson(),
      where: '${StipulationsFields.id} = ?',
      whereArgs: [stipulation.id],
    );
  }

  Future<int> deleteStipulation(int id) async {
    final db = await instance.database;

    return await db.delete(
      tableStipulations,
      where: '${StipulationsFields.id} = ?',
      whereArgs: [id],
    );
  }


  // Brands
  Future<UniverseBrands> createBrand(UniverseBrands brand) async {
    final db = await instance.database;

    final id = await db.insert(tableBrands, brand.toJson());
    return brand.copy(id: id);
  }

  Future<UniverseBrands> readBrand(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      tableBrands,
      columns: BrandsFields.values,
      where: '${BrandsFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return UniverseBrands.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<UniverseBrands>> readAllBrands() async {
    final db = await instance.database;
    final result = await db.query(tableBrands);

    return result.map((json) => UniverseBrands.fromJson(json)).toList();
  }

  Future<int> updateBrand(UniverseBrands brand) async {
    final db = await instance.database;

    return db.update(
      tableBrands,
      brand.toJson(),
      where: '${BrandsFields.id} = ?',
      whereArgs: [brand.id],
    );
  }

  Future<int> deleteBrand(int id) async {
    final db = await instance.database;

    return await db.delete(
      tableBrands,
      where: '${BrandsFields.id} = ?',
      whereArgs: [id],
    );
  }



  // Titles
  Future<UniverseTitles> createTitle(UniverseTitles title) async {
    final db = await instance.database;

    final id = await db.insert(tableTitles, title.toJson());
    return title.copy(id: id);
  }

  Future<UniverseTitles> readTitle(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      tableTitles,
      columns: TitlesFields.values,
      where: '${TitlesFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return UniverseTitles.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<UniverseTitles>> readAllTitles() async {
    final db = await instance.database;
    final result = await db.query(tableTitles);

    return result.map((json) => UniverseTitles.fromJson(json)).toList();
  }

  Future<int> updateTitle(UniverseTitles title) async {
    final db = await instance.database;

    return db.update(
      tableTitles,
      title.toJson(),
      where: '${TitlesFields.id} = ?',
      whereArgs: [title.id],
    );
  }

  Future<int> deleteTitle(int id) async {
    final db = await instance.database;

    return await db.delete(
      tableTitles,
      where: '${TitlesFields.id} = ?',
      whereArgs: [id],
    );
  }
}