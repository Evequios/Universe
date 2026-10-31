
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'package:wwe_universe/classes/brands.dart';
import 'package:wwe_universe/classes/match_record.dart';
import 'package:wwe_universe/classes/match_formats.dart';
import 'package:wwe_universe/classes/match_sides.dart';
import 'package:wwe_universe/classes/match_participants.dart';
import 'package:wwe_universe/classes/news.dart';
import 'package:wwe_universe/classes/reigns.dart';
import 'package:wwe_universe/classes/show.dart';
import 'package:wwe_universe/classes/stipulations.dart';
import 'package:wwe_universe/classes/storylines.dart';
import 'package:wwe_universe/classes/superstars.dart';
import 'package:wwe_universe/classes/teams.dart';
import 'package:wwe_universe/classes/titles.dart';

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

    return openDatabase(
      path,
      version: 77,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _createDB,
      onUpgrade: _updateDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // ---------------------------------------------------------
    // NEWS
    // ---------------------------------------------------------

    await db.execute('''
      CREATE TABLE $tableNews (
        ${NewsFields.id} $idType,
        ${NewsFields.title} $textType,
        ${NewsFields.text} $textType,
        ${NewsFields.createdTime} $textType,
        ${NewsFields.type} $textType DEFAULT 'Other'
      )
    ''');

    // ---------------------------------------------------------
    // BRANDS
    // ---------------------------------------------------------

    await db.execute('''
      CREATE TABLE $tableBrands (
        ${BrandsFields.id} $idType,
        ${BrandsFields.name} $textType
      )
    ''');

    // ---------------------------------------------------------
    // SUPERSTARS
    // ---------------------------------------------------------

    await db.execute('''
      CREATE TABLE $tableSuperstars (
        ${SuperstarsFields.id} $idType,
        ${SuperstarsFields.name} $textType,
        ${SuperstarsFields.brand} $intType,
        ${SuperstarsFields.orientation} $textType,
        ${SuperstarsFields.division} $intType DEFAULT NULL
      )
    ''');

    // ---------------------------------------------------------
    // STORYLINES
    // ---------------------------------------------------------

    await db.execute('''
      CREATE TABLE $tableStorylines (
        ${StorylinesFields.id} $idType,
        ${StorylinesFields.title} $textType,
        ${StorylinesFields.text} $textType,
        ${StorylinesFields.yearStart} $intTypeNN,
        ${StorylinesFields.yearEnd} $intTypeNN,
        ${StorylinesFields.start} $intTypeNN,
        ${StorylinesFields.end} $intTypeNN
      )
    ''');

    // ---------------------------------------------------------
    // SHOWS
    // ---------------------------------------------------------

    await db.execute('''
      CREATE TABLE $tableShows (
        ${ShowFields.id} $idType,
        ${ShowFields.name} $textType,
        ${ShowFields.year} $intTypeNN,
        ${ShowFields.week} $intTypeNN,
        ${ShowFields.dayOfWeek} $intTypeNN,
        ${ShowFields.summary} $textType
      )
    ''');

    // ---------------------------------------------------------
    // STIPULATIONS
    // ---------------------------------------------------------
    // Le champ "type" est conservé temporairement pour les
    // anciennes interfaces. Il sera retiré lors de leur migration.

    await db.execute('''
      CREATE TABLE $tableStipulations (
        ${StipulationsFields.id} $idType,
        ${StipulationsFields.type} TEXT NOT NULL DEFAULT '',
        ${StipulationsFields.stipulation} $textType
      )
    ''');

    // ---------------------------------------------------------
    // MATCH FORMATS
    // ---------------------------------------------------------

    await db.execute('''
      CREATE TABLE $tableMatchFormats (
        ${MatchFormatsFields.id} $idType,
        ${MatchFormatsFields.name} $textType,
        ${MatchFormatsFields.description} TEXT,
        UNIQUE (${MatchFormatsFields.name} COLLATE NOCASE)
      )
    ''');

    // ---------------------------------------------------------
    // TITLES
    // ---------------------------------------------------------

    await db.execute('''
      CREATE TABLE $tableTitles (
        ${TitlesFields.id} $idType,
        ${TitlesFields.name} $textType,
        ${TitlesFields.brand} $intType,
        ${TitlesFields.tag} $booleanTypeNN,
        ${TitlesFields.holder1} $intType,
        ${TitlesFields.holder2} $intType
      )
    ''');

    // ---------------------------------------------------------
    // TEAMS
    // ---------------------------------------------------------

    await db.execute('''
      CREATE TABLE $tableTeams (
        ${TeamsFields.id} $idType,
        ${TeamsFields.name} $textType,
        ${TeamsFields.member1} $intTypeNN,
        ${TeamsFields.member2} $intTypeNN,
        ${TeamsFields.member3} $intType,
        ${TeamsFields.member4} $intType,
        ${TeamsFields.member5} $intType
      )
    ''');

    // ---------------------------------------------------------
    // MATCHES
    // ---------------------------------------------------------

    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableMatches (
        ${MatchRecordFields.id} $idType,
        ${MatchRecordFields.formatId} $intType,
        ${MatchRecordFields.formatName} $textType,
        ${MatchRecordFields.stipulationId} $intType,
        ${MatchRecordFields.stipulationName} $textType,
        ${MatchRecordFields.resultStatus} $textType,
        ${MatchRecordFields.winnerSideOrder} $intType,
        ${MatchRecordFields.winnerSuperstarId} $intType,
        ${MatchRecordFields.winnerName} TEXT,
        ${MatchRecordFields.matchOrder} $intTypeNN DEFAULT 0,
        ${MatchRecordFields.showId} $intTypeNN,
        ${MatchRecordFields.titleId} $intType,

        FOREIGN KEY (${MatchRecordFields.formatId})
          REFERENCES $tableMatchFormats (${MatchFormatsFields.id})
          ON DELETE SET NULL,

        FOREIGN KEY (${MatchRecordFields.stipulationId})
          REFERENCES $tableStipulations (${StipulationsFields.id})
          ON DELETE SET NULL,

        FOREIGN KEY (${MatchRecordFields.showId})
          REFERENCES $tableShows (${ShowFields.id})
          ON DELETE CASCADE,

        FOREIGN KEY (${MatchRecordFields.titleId})
          REFERENCES $tableTitles (${TitlesFields.id})
          ON DELETE SET NULL,

        FOREIGN KEY (${MatchRecordFields.winnerSuperstarId})
          REFERENCES $tableSuperstars (${SuperstarsFields.id})
          ON DELETE SET NULL
      );
    ''');

    // ---------------------------------------------------------
    // MATCH SIDES
    // ---------------------------------------------------------

    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableMatchSides (
        ${MatchSidesFields.id} $idType,
        ${MatchSidesFields.matchId} $intTypeNN,
        ${MatchSidesFields.sideOrder} $intTypeNN,
        ${MatchSidesFields.name} $textType,
        ${MatchSidesFields.teamId} $intType,

        UNIQUE (${MatchSidesFields.matchId}, ${MatchSidesFields.sideOrder}),

        FOREIGN KEY (${MatchSidesFields.matchId})
          REFERENCES $tableMatches (${MatchRecordFields.id})
          ON DELETE CASCADE,

        FOREIGN KEY (${MatchSidesFields.teamId})
          REFERENCES $tableTeams (${TeamsFields.id})
          ON DELETE SET NULL
      );
    ''');

    // ---------------------------------------------------------
    // MATCH PARTICIPANTS
    // ---------------------------------------------------------

    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableMatchParticipants (
        ${MatchParticipantsFields.id} $idType,
        ${MatchParticipantsFields.matchId} $intTypeNN,
        ${MatchParticipantsFields.sideId} $intTypeNN,
        ${MatchParticipantsFields.position} $intTypeNN,
        ${MatchParticipantsFields.superstarId} $intType,
        ${MatchParticipantsFields.superstarName} $textType,

        UNIQUE (${MatchParticipantsFields.sideId}, ${MatchParticipantsFields.position}),

        FOREIGN KEY (${MatchParticipantsFields.matchId})
          REFERENCES $tableMatches (${MatchRecordFields.id})
          ON DELETE CASCADE,

        FOREIGN KEY (${MatchParticipantsFields.sideId})
          REFERENCES $tableMatchSides (${MatchSidesFields.id})
          ON DELETE CASCADE,

        FOREIGN KEY (${MatchParticipantsFields.superstarId})
          REFERENCES $tableSuperstars (${SuperstarsFields.id})
          ON DELETE SET NULL
      );
    ''');

    // ---------------------------------------------------------
    // REIGNS
    // ---------------------------------------------------------

    await db.execute('''
      CREATE TABLE $tableReigns (
        ${ReignsFields.id} $idType,
        ${ReignsFields.holder1} $intTypeNN,
        ${ReignsFields.holder2} $intType,
        ${ReignsFields.titleId} $intTypeNN,
        ${ReignsFields.yearDebut} $intTypeNN,
        ${ReignsFields.weekDebut} $intTypeNN,
        ${ReignsFields.yearEnd} $intType,
        ${ReignsFields.weekEnd} $intType
      )
    ''');

    // ---------------------------------------------------------
    // INDEXES
    // ---------------------------------------------------------

    await db.execute('''
      CREATE INDEX idx_matches_show_order
      ON $tableMatches (
        ${MatchRecordFields.showId},
        ${MatchRecordFields.matchOrder}
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_matches_format
      ON $tableMatches (${MatchRecordFields.formatId})
    ''');

    await db.execute('''
      CREATE INDEX idx_matches_stipulation
      ON $tableMatches (${MatchRecordFields.stipulationId})
    ''');

    await db.execute('''
      CREATE INDEX idx_match_sides_match_order
      ON $tableMatchSides (
        ${MatchSidesFields.matchId},
        ${MatchSidesFields.sideOrder}
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_match_participants_match
      ON $tableMatchParticipants (
        ${MatchParticipantsFields.matchId}
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_match_participants_side_position
      ON $tableMatchParticipants (
        ${MatchParticipantsFields.sideId},
        ${MatchParticipantsFields.position}
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_match_participants_superstar
      ON $tableMatchParticipants (
        ${MatchParticipantsFields.superstarId}
      )
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_matches_show_order
      ON $tableMatches (
        ${MatchRecordFields.showId},
        ${MatchRecordFields.matchOrder}
      );
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_match_participants_superstar
      ON $tableMatchParticipants (
        ${MatchParticipantsFields.superstarId}
      );
    ''');
  }

  Future<void> _updateDB(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Suppression des tables enfants avant leurs tables parentes.
    await db.execute('DROP TABLE IF EXISTS $tableMatchParticipants');
    await db.execute('DROP TABLE IF EXISTS $tableMatchSides');
    await db.execute('DROP TABLE IF EXISTS $tableMatches');
    await db.execute('DROP TABLE IF EXISTS $tableMatchFormats');

    await db.execute('DROP TABLE IF EXISTS $tableReigns');
    await db.execute('DROP TABLE IF EXISTS $tableTeams');
    await db.execute('DROP TABLE IF EXISTS $tableTitles');
    await db.execute('DROP TABLE IF EXISTS $tableStipulations');
    await db.execute('DROP TABLE IF EXISTS $tableShows');
    await db.execute('DROP TABLE IF EXISTS $tableStorylines');
    await db.execute('DROP TABLE IF EXISTS $tableSuperstars');
    await db.execute('DROP TABLE IF EXISTS $tableBrands');
    await db.execute('DROP TABLE IF EXISTS $tableNews');

    await _createDB(db, newVersion);
  }
}
