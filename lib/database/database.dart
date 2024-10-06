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

  static const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
  static const textType = 'TEXT NOT NULL';
  static const intTypeNN = 'INTEGER NOT NULL';
  static const intType = 'INTEGER';
  static const booleanTypeNN = 'BOOLEAN NOT NULL';

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
    if (newVersion > oldVersion) {
      await db.execute('''ALTER TABLE $tableMatches ADD COLUMN ${MatchesFields.titleId} $intTypeNN DEFAULT 0;''');
    }
  }
}
