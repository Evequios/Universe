import 'package:sqflite/sqflite.dart';
import 'package:wwe_universe/classes/Universe/UniverseBrands.dart';
import 'package:wwe_universe/classes/Universe/UniverseMatches.dart';
import 'package:wwe_universe/classes/Universe/UniverseNews.dart';
import 'package:wwe_universe/classes/Universe/UniverseShows.dart';
import 'package:wwe_universe/classes/Universe/UniverseStipulations.dart';
import 'package:wwe_universe/classes/Universe/UniverseStorylines.dart';
import 'package:wwe_universe/classes/Universe/UniverseSuperstars.dart';
import 'package:wwe_universe/classes/Universe/UniverseTeams.dart';
import 'package:wwe_universe/classes/Universe/UniverseTitles.dart';
import 'package:path/path.dart';


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

    return await openDatabase(path, version: 59, onCreate: _createDB, onUpgrade: _updateDB);
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
        ${SuperstarsFields.rival5} $intType DEFAULT 0
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
        ${MatchesFields.showId} $intTypeNN
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
        ${TeamsFields.nom} $textType,
        ${TeamsFields.member1} $intTypeNN,
        ${TeamsFields.member2} $intTypeNN,
        ${TeamsFields.member3} $intType,
        ${TeamsFields.member4} $intType,
        ${TeamsFields.member5} $intType
      );
  ''');
  }

  Future _updateDB(Database db, int oldVersion, int newVersion) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const intTypeNN = 'INTEGER NOT NULL';
    const intType = 'INTEGER';
    if (newVersion > oldVersion) {
      await db.execute('''DROP TABLE IF EXISTS $tableMatches;''');
      
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
          ${MatchesFields.showId} $intTypeNN
        ); '''
      );
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
    const orderBy = '${SuperstarsFields.name} ASC';

    final result = await db.query(tableSuperstars, orderBy: orderBy);

    return result.map((json) => UniverseSuperstars.fromJson(json)).toList();
  }

  Future<List<UniverseSuperstars>> readAllSuperstarsFilter(int brandId) async {
    final db = await instance.database;
    const orderBy = '${SuperstarsFields.name} ASC';

    final result = await db.query(
      tableSuperstars, 
      where: '${SuperstarsFields.brand} = ? ',
      whereArgs: [brandId],
      orderBy: orderBy
    );

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

  Future<int> updateStoryline(UniverseStorylines storyline) async {
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

    final result = await db.query(tableMatches,
    where: 'showId = ?',
    whereArgs: [showId],
    orderBy: MatchesFields.matchOrder);

    return result.map((json) => UniverseMatches.fromJson(json)).toList();
  }

  Future<List<UniverseMatches>> readAllMatchesSuperstar(int id) async {
    final db = await instance.database;

    final result = await db.query(tableMatches,
    where: 's1 = $id OR s2 = $id OR s3 = $id OR s4 = $id OR s5 = $id OR s6 = $id OR s7 = $id OR s8 = $id');

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

// Teams
  Future<UniverseTeams> createTeam(UniverseTeams team) async {
    final db = await instance.database;

    final id = await db.insert(tableTeams, team.toJson());
    return team.copy(id: id);
  }

  Future<UniverseTeams> readTeam(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      tableTeams,
      columns: TeamsFields.values,
      where: '${TeamsFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return UniverseTeams.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<UniverseTeams>> readAllTeams() async {
    final db = await instance.database;

    final result = await db.query(tableTeams);

    return result.map((json) => UniverseTeams.fromJson(json)).toList();
  }

  Future<int> updateTeam(UniverseTeams team) async {
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
}