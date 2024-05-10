import 'dart:collection';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:wwe_universe/classes/Brands.dart';
import 'package:wwe_universe/classes/Matches.dart';
import 'package:wwe_universe/classes/News.dart';
import 'package:wwe_universe/classes/Reigns.dart';
import 'package:wwe_universe/classes/Shows.dart';
import 'package:wwe_universe/classes/Stipulations.dart';
import 'package:wwe_universe/classes/Storylines.dart';
import 'package:wwe_universe/classes/Superstars.dart';
import 'package:wwe_universe/classes/Teams.dart';
import 'package:wwe_universe/classes/Titles.dart';


class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('wwe_universe_database.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 67, onCreate: _createDB, onUpgrade: _updateDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const intTypeNN = 'INTEGER NOT NULL';
    const intType = 'INTEGER';
    const booleanTypeNN = 'BOOLEAN NOT NULL';

    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableNews ( 
        ${NewsFields.id} $idType, 
        ${NewsFields.title} $textType,
        ${NewsFields.text} $textType,
        ${NewsFields.createdTime} $textType,
        ${NewsFields.type} $textType DEFAULT 'Other'
      ); '''
    );

    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableBrands ( 
        ${BrandsFields.id} $idType, 
        ${BrandsFields.name} $textType
      ); '''
    );
  
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableSuperstars ( 
        ${SuperstarsFields.id} $idType, 
        ${SuperstarsFields.name} $textType,
        ${SuperstarsFields.brand} $intType,
        ${SuperstarsFields.orientation} $textType,
        ${SuperstarsFields.ally1} $intType DEFAULT 0,
        ${SuperstarsFields.ally2} $intType DEFAULT 0,
        ${SuperstarsFields.ally3} $intType DEFAULT 0,
        ${SuperstarsFields.ally4} $intType DEFAULT 0,
        ${SuperstarsFields.ally5} $intType DEFAULT 0,
        ${SuperstarsFields.rival1} $intType DEFAULT 0,
        ${SuperstarsFields.rival2} $intType DEFAULT 0,
        ${SuperstarsFields.rival3} $intType DEFAULT 0,
        ${SuperstarsFields.rival4} $intType DEFAULT 0,
        ${SuperstarsFields.rival5} $intType DEFAULT 0,
        ${SuperstarsFields.division} $intType DEFAULT 0
      ); '''
    );

    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableStorylines ( 
        ${StorylinesFields.id} $idType, 
        ${StorylinesFields.title} $textType,
        ${StorylinesFields.text} $textType,
        ${StorylinesFields.yearStart} $intTypeNN,
        ${StorylinesFields.yearEnd} $intTypeNN,
        ${StorylinesFields.start} $intTypeNN,
        ${StorylinesFields.end} $intTypeNN
      ); '''
    );

    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableShows( 
      ${ShowFields.id} $idType, 
      ${ShowFields.name} $textType,
      ${ShowFields.year} $intTypeNN,
      ${ShowFields.week} $intTypeNN,
      ${ShowFields.summary} $textType
      ); '''
    );

    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableStipulations(
        ${StipulationsFields.id} $idType,
        ${StipulationsFields.type} $textType,
        ${StipulationsFields.stipulation} $textType
      );'''
    );

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
        ${MatchesFields.winner} $intTypeNN,
        ${MatchesFields.matchOrder} $intTypeNN DEFAULT 0,
        ${MatchesFields.showId} $intTypeNN,
        ${MatchesFields.titleId} $intTypeNN DEFAULT 0
      ); '''
    );

    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableTitles ( 
        ${TitlesFields.id} $idType, 
        ${TitlesFields.name} $textType,
        ${TitlesFields.brand} $intType,
        ${TitlesFields.tag} $booleanTypeNN,
        ${TitlesFields.holder1} $intType,
        ${TitlesFields.holder2} $intType
      ); '''
    );

    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableTeams (
        ${TeamsFields.id} $idType,
        ${TeamsFields.name} $textType,
        ${TeamsFields.member1} $intTypeNN,
        ${TeamsFields.member2} $intTypeNN,
        ${TeamsFields.member3} $intType,
        ${TeamsFields.member4} $intType,
        ${TeamsFields.member5} $intType
      );
  ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableReigns (
        ${ReignsFields.id} $idType,
        ${ReignsFields.holder1} $intTypeNN,
        ${ReignsFields.holder2} $intType,
        ${ReignsFields.titleId} $intTypeNN,
        ${ReignsFields.yearDebut} $intTypeNN,
        ${ReignsFields.weekDebut} $intTypeNN,
        ${ReignsFields.yearEnd} $intType,
        ${ReignsFields.weekEnd} $intType
      );
    ''');
  }

  Future _updateDB(Database db, int oldVersion, int newVersion) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const intTypeNN = 'INTEGER NOT NULL';
    const intType = 'INTEGER';
    const textType = 'TEXT NOT NULL';
    const booleanTypeNN = 'BOOLEAN NOT NULL';
    if (newVersion > oldVersion) {
      await db.execute('''ALTER TABLE $tableMatches ADD COLUMN ${MatchesFields.titleId} $intTypeNN DEFAULT 0;''');
    }
  }

// News
  Future<News> createNews(News news) async {
    final db = await instance.database;

    final id = await db.insert(tableNews, news.toJson());
    return news.copy(id: id);
  }

  Future<News> readNews(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      tableNews,
      columns: NewsFields.values,
      where: '${NewsFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return News.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<News>> readAllNews() async {
    final db = await instance.database;
    const orderBy = '${NewsFields.createdTime} DESC';
    final result = await db.query(
      tableNews,
      orderBy: orderBy);

    return result.map((json) => News.fromJson(json)).toList();
  }

  Future<List<News>> readAllNewsSearch(String n) async {
    final db = await instance.database;
    const orderBy = '${NewsFields.createdTime} DESC';

    final result = await db.query(
      tableNews, 
      where: '${NewsFields.title} LIKE ? OR ${NewsFields.text} LIKE ?',
      whereArgs: ['%$n%', '%$n%'],
      orderBy: orderBy
    );

    return result.map((json) => News.fromJson(json)).toList();
  }

  Future<int> updateNews(News news) async {
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
Future<Superstars> createSuperstar(Superstars universeSuperstars) async {
    final db = await instance.database;

    final id = await db.insert(tableSuperstars, universeSuperstars.toJson());
    return universeSuperstars.copy(id: id);
  }

  Future<Superstars> readSuperstar(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      tableSuperstars,
      columns: SuperstarsFields.values,
      where: '${SuperstarsFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Superstars.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<Superstars>> readAllSuperstars() async {
    final db = await instance.database;
    const orderBy = '${SuperstarsFields.name} ASC';

    final result = await db.query(
      tableSuperstars, 
      orderBy: orderBy
    );

    return result.map((json) => Superstars.fromJson(json)).toList();
  }

  Future<List<Superstars>> readAllSuperstarsFilter(int brandId) async {
    final db = await instance.database;
    const orderBy = '${SuperstarsFields.name} ASC';

    final result = await db.query(
      tableSuperstars, 
      where: '${SuperstarsFields.brand} = ? ',
      whereArgs: [brandId],
      orderBy: orderBy
    );

    return result.map((json) => Superstars.fromJson(json)).toList();
  }

  Future<List<Superstars>> readAllSuperstarsDivision(int titleId) async {
    final db = await instance.database;
    const orderBy = '${SuperstarsFields.name} ASC';

    final result = await db.query(
      tableSuperstars, 
      where: '${SuperstarsFields.division} = ? ',
      whereArgs: [titleId],
      orderBy: orderBy
    );

    return result.map((json) => Superstars.fromJson(json)).toList();
  }

  Future<List<Superstars>> readAllSuperstarsSearch(String n) async {
    final db = await instance.database;
    const orderBy = '${SuperstarsFields.name} ASC';

    final result = await db.query(
      tableSuperstars, 
      where: '${SuperstarsFields.name} LIKE ?',
      whereArgs: ['%$n%'],
      orderBy: orderBy
    );

    return result.map((json) => Superstars.fromJson(json)).toList();
  }

  Future<int> updateSuperstar(Superstars universeSuperstars) async {
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

    Map<String, dynamic> row = {
      TitlesFields.holder1 : 0,
      TitlesFields.holder2 : 0
    };
    await db.update(
      tableTitles, 
      row,
      where: '${TitlesFields.holder1} = $id OR ${TitlesFields.holder2} = $id'
    );

    String queryA1 = "UPDATE $tableSuperstars SET ${SuperstarsFields.ally1} = 0 WHERE ${SuperstarsFields.ally1} = $id;";
    String queryA2 = "UPDATE $tableSuperstars SET ${SuperstarsFields.ally2} = 0 WHERE ${SuperstarsFields.ally2} = $id;";
    String queryA3 = "UPDATE $tableSuperstars SET ${SuperstarsFields.ally3} = 0 WHERE ${SuperstarsFields.ally3} = $id;";
    String queryA4 = "UPDATE $tableSuperstars SET ${SuperstarsFields.ally4} = 0 WHERE ${SuperstarsFields.ally4} = $id;";
    String queryA5 = "UPDATE $tableSuperstars SET ${SuperstarsFields.ally5} = 0 WHERE ${SuperstarsFields.ally5} = $id;";
    String queryR1 = "UPDATE $tableSuperstars SET ${SuperstarsFields.rival1} = 0 WHERE ${SuperstarsFields.rival1} = $id;";
    String queryR2 = "UPDATE $tableSuperstars SET ${SuperstarsFields.rival2} = 0 WHERE ${SuperstarsFields.rival2} = $id;";
    String queryR3 = "UPDATE $tableSuperstars SET ${SuperstarsFields.rival3} = 0 WHERE ${SuperstarsFields.rival3} = $id;";
    String queryR4 = "UPDATE $tableSuperstars SET ${SuperstarsFields.rival4} = 0 WHERE ${SuperstarsFields.rival4} = $id;";
    String queryR5 = "UPDATE $tableSuperstars SET ${SuperstarsFields.rival5} = 0 WHERE ${SuperstarsFields.rival5} = $id;";

    await db.rawUpdate(queryA1);
    await db.rawUpdate(queryA2);
    await db.rawUpdate(queryA3);
    await db.rawUpdate(queryA4);
    await db.rawUpdate(queryA5);
    await db.rawUpdate(queryR1);
    await db.rawUpdate(queryR2);
    await db.rawUpdate(queryR3);
    await db.rawUpdate(queryR4);
    await db.rawUpdate(queryR5);



    await db.delete(
      tableMatches,
      where: '${MatchesFields.s1} = $id OR ${MatchesFields.s2} = $id OR ${MatchesFields.s3} = $id OR ${MatchesFields.s4} = $id OR ${MatchesFields.s5} = $id OR ${MatchesFields.s6} = $id OR ${MatchesFields.s7} = $id OR ${MatchesFields.s8} = $id '
    );

    await db.delete(
      tableTeams,
      where: '${TeamsFields.member1} = $id OR ${TeamsFields.member2} = $id OR ${TeamsFields.member3} = $id OR ${TeamsFields.member4} = $id OR ${TeamsFields.member5} = $id'
    );
    
    return await db.delete(
      tableSuperstars,
      where: '${SuperstarsFields.id} = ?',
      whereArgs: [id],
    );
  }


// Storylines
  Future<Storylines> createStoryline(Storylines universeStorylines) async {
    final db = await instance.database;

    final id = await db.insert(tableStorylines, universeStorylines.toJson());
    return universeStorylines.copy(id: id);
  }

  Future<Storylines> readStoryline(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      tableStorylines,
      columns: StorylinesFields.values,
      where: '${StorylinesFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Storylines.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<Storylines>> readAllStorylines() async {
    final db = await instance.database;
    const orderBy = '${StorylinesFields.id} DESC';

    final result = await db.query(
      tableStorylines,
      orderBy: orderBy
    );

    return result.map((json) => Storylines.fromJson(json)).toList();
  }

  Future<List<Storylines>> readAllStorylinesSearch(String n) async {
    final db = await instance.database;
    const orderBy = '${StorylinesFields.id} DESC';

    final result = await db.query(
      tableStorylines, 
      where: '${StorylinesFields.title} LIKE ? OR ${StorylinesFields.text} LIKE ?',
      whereArgs: ['%$n%', '%$n%'],
      orderBy: orderBy
    );

    return result.map((json) => Storylines.fromJson(json)).toList();
  }

  Future<int> updateStoryline(Storylines storyline) async {
    final db = await instance.database;

    return db.update(
      tableStorylines,
      storyline.toJson(),
      where: '${StorylinesFields.id} = ?',
      whereArgs: [storyline.id],
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
  Future<Shows> createShow(Shows universeShows) async {
    final db = await instance.database;

    final id = await db.insert(tableShows, universeShows.toJson());
    return universeShows.copy(id: id);
  }

  Future<Shows> readShow(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      tableShows,
      columns: ShowFields.values,
      where: '${ShowFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Shows.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<Shows>> readAllShows() async {
    final db = await instance.database;
    const orderBy = '${ShowFields.year} DESC, ${ShowFields.week} DESC';

    final result = await db.query(
      tableShows,
      orderBy: orderBy);

    return result.map((json) => Shows.fromJson(json)).toList();
  }

  Future<int> updateShow(Shows universeShows) async {
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

    await db.delete(
      tableMatches,
      where: '${MatchesFields.showId} = ?',
      whereArgs: [id]
    );

    return await db.delete(
      tableShows,
      where: '${ShowFields.id} = ?',
      whereArgs: [id],
    );
  }




  // Matches
  Future<Matches> createMatch(Matches universeMatches) async {
    final db = await instance.database;

    final id = await db.insert(tableMatches, universeMatches.toJson());
    return universeMatches.copy(id: id);
  }

  Future<Matches> readMatch(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      tableMatches,
      columns: MatchesFields.values,
      where: '${MatchesFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Matches.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<Matches>> readAllMatches(int showId) async {
    final db = await instance.database;

    final result = await db.query(tableMatches,
    where: 'showId = ?',
    whereArgs: [showId],
    orderBy: MatchesFields.matchOrder);

    return result.map((json) => Matches.fromJson(json)).toList();
  }

  Future<List<Matches>> readAllMatchesSuperstar(int id) async {
    final db = await instance.database;

    final result = await db.query(tableMatches,
    where: 's1 = $id OR s2 = $id OR s3 = $id OR s4 = $id OR s5 = $id OR s6 = $id OR s7 = $id OR s8 = $id');

    return result.map((json) => Matches.fromJson(json)).toList();
  }

  Future<int> updateMatches(Matches universeMatches) async {
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
  Future<Stipulations> createStipulation(Stipulations stipulation) async {
    final db = await instance.database;

    final id = await db.insert(tableStipulations, stipulation.toJson());
    return stipulation.copy(id: id);
  }


  Future<Stipulations> readStipulation(int id) async {
    final db = await instance.database;

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

  Future<List<Stipulations>> readAllStipulations() async {
    final db = await instance.database;
    const orderBy = '${StipulationsFields.type} ASC, ${StipulationsFields.stipulation} ASC';
    final result = await db.query(
      tableStipulations,
      orderBy: orderBy
    );

    return result.map((json) => Stipulations.fromJson(json)).toList();
  }

  Future<List<Stipulations>> readAllStipulationsSearch(String n) async {
    final db = await instance.database;
    const orderBy = '${StipulationsFields.type} ASC, ${StipulationsFields.stipulation} ASC';

    final result = await db.query(
      tableStipulations, 
      where: '${StipulationsFields.type} LIKE ? OR ${StipulationsFields.stipulation} LIKE ?',
      whereArgs: ['%$n%', '%$n%'],
      orderBy: orderBy
    );

    return result.map((json) => Stipulations.fromJson(json)).toList();
  }


  Future<int> updateStipulation(Stipulations stipulation) async {
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


  // Brands
  Future<Brands> createBrand(Brands brand) async {
    final db = await instance.database;

    final id = await db.insert(tableBrands, brand.toJson());
    return brand.copy(id: id);
  }

  Future<Brands> readBrand(int id) async {
    final db = await instance.database;

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

  Future<List<Brands>> readAllBrands() async {
    final db = await instance.database;
    const orderBy = '${BrandsFields.name} ASC';
    final result = await db.query(
      tableBrands,
      orderBy: orderBy
    );

    return result.map((json) => Brands.fromJson(json)).toList();
  }

  Future<int> updateBrand(Brands brand) async {
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



  // Titles
  Future<Titles> createTitle(Titles title) async {
    final db = await instance.database;

    final id = await db.insert(tableTitles, title.toJson());
    return title.copy(id: id);
  }

  Future<Titles> readTitle(int id) async {
    final db = await instance.database;

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

  Future<List<Titles>> readAllTitles() async {
    final db = await instance.database;
    const orderBy = '${TitlesFields.name} ASC';
    final result = await db.query(
      tableTitles,
      orderBy: orderBy,
    );

    return result.map((json) => Titles.fromJson(json)).toList();
  }

  Future<List<Titles>> readAllTitlesSearch(String n) async {
    final db = await instance.database;
    const orderBy = '${TitlesFields.name} ASC';

    final result = await db.query(
      tableTitles, 
      where: '${TitlesFields.name} LIKE ?',
      whereArgs: ['%$n%'],
      orderBy: orderBy
    );

    return result.map((json) => Titles.fromJson(json)).toList();
  }

  Future<int> updateTitle(Titles title) async {
    final db = await instance.database;

    return db.update(
      tableTitles,
      title.toJson(),
      where: '${TitlesFields.id} = ?',
      whereArgs: [title.id],
    );
  }

  Future setChampion(Titles title, List<int> winners) async {
    final db = await instance.database;

    if(title.tag == 0) {
      db.rawUpdate('UPDATE $tableTitles SET ${TitlesFields.holder1} = ? WHERE ${TitlesFields.id} = ?', [winners[0], title.id]);
    } else {
      db.rawUpdate('UPDATE $tableTitles SET ${TitlesFields.holder1} = ?, ${TitlesFields.holder2} = ? WHERE ${TitlesFields.id} = ?', [winners[0], winners[1], title.id]);
    }

  }

  Future<int> deleteTitle(int id) async {
    final db = await instance.database;

    return await db.delete(
      tableTitles,
      where: '${TitlesFields.id} = ?',
      whereArgs: [id],
    );
  }

// Teams
  Future<Teams> createTeam(Teams team) async {
    final db = await instance.database;

    final id = await db.insert(tableTeams, team.toJson());
    return team.copy(id: id);
  }

  Future<Teams> readTeam(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      tableTeams,
      columns: TeamsFields.values,
      where: '${TeamsFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Teams.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<Teams>> readAllTeams() async {
    final db = await instance.database;
    const orderBy = '${TeamsFields.name} ASC';

    final result = await db.query(
      tableTeams,
      orderBy: orderBy
    );

    return result.map((json) => Teams.fromJson(json)).toList();
  }

  Future<List<Teams>> readAllTeamsSearch(String n) async {
    final db = await instance.database;
    const orderBy = '${TeamsFields.name} ASC';

    final result = await db.query(
      tableTeams, 
      where: '${TeamsFields.name} LIKE ?',
      whereArgs: ['%$n%'],
      orderBy: orderBy
    );

    return result.map((json) => Teams.fromJson(json)).toList();
  }

  Future<int> updateTeam(Teams team) async {
    final db = await instance.database;

    return db.update(
      tableTeams,
      team.toJson(),
      where: '${TeamsFields.id} = ?',
      whereArgs: [team.id],
    );
  }

  Future<int> deleteTeam(int id) async {
    final db = await instance.database;

    return await db.delete(
      tableTeams,
      where: '${TeamsFields.id} = ?',
      whereArgs: [id],
    );
  }

  //Draft

  Future updateDraft(HashMap map) async {
    final db = await instance.database;
      
    map.forEach((i, value) {
      print("id superstar : " + i.toString());
      print('id brand : ' + value.toString());
      db.rawUpdate('UPDATE $tableSuperstars SET ${SuperstarsFields.brand} = ? WHERE ${SuperstarsFields.id} = ?', [value, i]);
    });
  }   

  // Divisions

  Future setDivision(List<Superstars> selectedSuperstars, int titleId) async {
    final db = await instance.database;

    for(Superstars superstar in selectedSuperstars){
      print(superstar.name);
      print(superstar.division);
      db.rawUpdate('UPDATE $tableSuperstars SET ${SuperstarsFields.division} = ? WHERE ${SuperstarsFields.id} = ${superstar.id}', [titleId]);
    }
  }

  // Reigns 
  Future<Reigns> createReign(Reigns reign) async {
    final db = await instance.database;

    final id = await db.insert(tableReigns, reign.toJson());
    return reign.copy(id: id);
  }

  Future<Reigns> readReign(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      tableReigns,
      columns: ReignsFields.values,
      where: '${ReignsFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Reigns.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<Reigns>> readAllReigns() async {
    final db = await instance.database;
    const orderBy = '${ReignsFields.yearDebut} DESC, ${ReignsFields.weekDebut} DESC';

    final result = await db.query(
      tableReigns,
      orderBy: orderBy
    );

    return result.map((json) => Reigns.fromJson(json)).toList();
  }

  Future<List<Reigns>> readAllReignsTitle(int titleId) async {
    final db = await instance.database;
    const orderBy = '${ReignsFields.yearDebut} DESC, ${ReignsFields.weekDebut} DESC';

    final result = await db.query(
      tableReigns, 
      where: '${ReignsFields.titleId} = ? ',
      whereArgs: [titleId],
      orderBy: orderBy
    );

    return result.map((json) => Reigns.fromJson(json)).toList();
  }

  Future<int> updateReigns(Reigns reign) async {
    final db = await instance.database;

    return db.update(
      tableReigns,
      reign.toJson(),
      where: '${ReignsFields.id} = ?',
      whereArgs: [reign.id],
    );
  }

  Future<int> deleteReign(int id) async {
    final db = await instance.database;

    return await db.delete(
      tableReigns,
      where: '${ReignsFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future<int?> getCurrentReign(int titleId) async {
    final db = await instance.database;
    final maps = await db.query(
      tableReigns,
      columns: ReignsFields.values,
      where: '${ReignsFields.id} = ? AND ${ReignsFields.yearEnd} = ?',
      whereArgs: [titleId, 0],
    );

    if (maps.isNotEmpty) {
      return Reigns.fromJson(maps.first).id;
    } else {
      return 0;
    }
  }

  Future<int?> getPreviousReign(int titleId) async {
    final db = await instance.database;
    final maps = await db.query(
      tableReigns,
      where: '${ReignsFields.titleId} = ? AND ${ReignsFields.weekEnd} != ?',
      whereArgs: [titleId, 0],
      orderBy: "ORDER BY ${ReignsFields.id} DESC",
      limit: 1
    );

    if (maps.isNotEmpty) {
      return Reigns.fromJson(maps.first).id;
    } else {
      return 0;
    }
  }

  Future<int?> activatePreviousReign(int titleId) async {
    final db = await instance.database;
    final idPreviousReign = await getPreviousReign(titleId);
    Reigns previousReign = await readReign(idPreviousReign!);
    final updatedPreviousReign = Reigns(holder1: previousReign.holder1, holder2: previousReign.holder2, titleId: titleId, yearDebut: previousReign.yearDebut, weekDebut: previousReign.weekDebut, yearEnd: 0, weekEnd: 0);
    await updateReigns(updatedPreviousReign);
    final idCurrentReign = await getCurrentReign(titleId);
    await deleteReign(idCurrentReign!);
  }
}
