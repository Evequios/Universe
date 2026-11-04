
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'package:wwe_universe/classes/brands.dart';
import 'package:wwe_universe/classes/match_record.dart';
import 'package:wwe_universe/classes/match_formats.dart';
import 'package:wwe_universe/classes/match_types.dart';
import 'package:wwe_universe/classes/match_type_formats.dart';
import 'package:wwe_universe/classes/match_sides.dart';
import 'package:wwe_universe/classes/match_participants.dart';
import 'package:wwe_universe/classes/news.dart';
import 'package:wwe_universe/classes/reigns.dart';
import 'package:wwe_universe/classes/show.dart';
import 'package:wwe_universe/classes/stipulations.dart';
import 'package:wwe_universe/classes/storylines.dart';
import 'package:wwe_universe/classes/storyline_event.dart';
import 'package:wwe_universe/classes/superstars.dart';
import 'package:wwe_universe/classes/teams.dart';
import 'package:wwe_universe/classes/titles.dart';
import 'package:wwe_universe/classes/superstar_relationship.dart';

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
      version: 93,
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
        ${NewsFields.type} $textType DEFAULT 'Other',
        ${NewsFields.year} INTEGER,
        ${NewsFields.week} INTEGER,
        ${NewsFields.dayOfWeek} INTEGER
      )
    ''');

    await db.execute('CREATE INDEX idx_news_wwe_date ON $tableNews (${NewsFields.year}, ${NewsFields.week}, ${NewsFields.dayOfWeek})');

    await _createNewsAssociationTables(db);

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
        ${SuperstarsFields.division} $intType DEFAULT NULL,
        ${SuperstarsFields.photoUrl} TEXT DEFAULT NULL
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
        ${StorylinesFields.end} $intTypeNN,
        ${StorylinesFields.dayStart} INTEGER NOT NULL DEFAULT 1,
        ${StorylinesFields.dayEnd} INTEGER NOT NULL DEFAULT 1,
        ${StorylinesFields.status} TEXT NOT NULL DEFAULT 'ongoing'
      )
    ''');

    await db.execute('''CREATE TABLE storyline_news (
      storyline_id INTEGER NOT NULL,
      news_id INTEGER NOT NULL,
      position INTEGER NOT NULL DEFAULT 0,
      PRIMARY KEY (storyline_id, news_id),
      FOREIGN KEY (storyline_id) REFERENCES $tableStorylines (${StorylinesFields.id}) ON DELETE CASCADE,
      FOREIGN KEY (news_id) REFERENCES $tableNews (${NewsFields.id}) ON DELETE CASCADE
    )''');

    await db.execute('''CREATE TABLE storyline_matches (
      storyline_id INTEGER NOT NULL,
      match_id INTEGER NOT NULL,
      position INTEGER NOT NULL DEFAULT 0,
      PRIMARY KEY (storyline_id, match_id),
      FOREIGN KEY (storyline_id) REFERENCES $tableStorylines (${StorylinesFields.id}) ON DELETE CASCADE,
      FOREIGN KEY (match_id) REFERENCES $tableMatches (${MatchRecordFields.id}) ON DELETE CASCADE
    )''');
    await db.execute('CREATE INDEX idx_storyline_news_news ON storyline_news (news_id)');
    await db.execute('CREATE INDEX idx_storyline_matches_match ON storyline_matches (match_id)');
    await db.execute('''CREATE TABLE $tableStorylineEvents (
      ${StorylineEventFields.id} $idType,
      ${StorylineEventFields.storylineId} INTEGER NOT NULL,
      ${StorylineEventFields.type} TEXT NOT NULL DEFAULT 'segment',
      ${StorylineEventFields.title} $textType,
      ${StorylineEventFields.description} TEXT NOT NULL DEFAULT '',
      ${StorylineEventFields.year} INTEGER NOT NULL,
      ${StorylineEventFields.week} INTEGER NOT NULL,
      ${StorylineEventFields.dayOfWeek} INTEGER NOT NULL DEFAULT 1,
      ${StorylineEventFields.position} INTEGER NOT NULL DEFAULT 0,
      ${StorylineEventFields.matchId} INTEGER,
      ${StorylineEventFields.newsId} INTEGER,
      FOREIGN KEY (${StorylineEventFields.storylineId}) REFERENCES $tableStorylines (${StorylinesFields.id}) ON DELETE CASCADE,
      FOREIGN KEY (${StorylineEventFields.matchId}) REFERENCES $tableMatches (${MatchRecordFields.id}) ON DELETE SET NULL,
      FOREIGN KEY (${StorylineEventFields.newsId}) REFERENCES $tableNews (${NewsFields.id}) ON DELETE SET NULL
    )''');
    await db.execute('CREATE INDEX idx_storyline_events_order ON $tableStorylineEvents (${StorylineEventFields.storylineId}, ${StorylineEventFields.year}, ${StorylineEventFields.week}, ${StorylineEventFields.dayOfWeek}, ${StorylineEventFields.position})');
    await db.execute('''CREATE TABLE storyline_superstars (
      storyline_id INTEGER NOT NULL,
      superstar_id INTEGER NOT NULL,
      PRIMARY KEY (storyline_id, superstar_id),
      FOREIGN KEY (storyline_id) REFERENCES $tableStorylines (${StorylinesFields.id}) ON DELETE CASCADE,
      FOREIGN KEY (superstar_id) REFERENCES $tableSuperstars (${SuperstarsFields.id}) ON DELETE CASCADE
    )''');
    await db.execute('''CREATE TABLE storyline_teams (
      storyline_id INTEGER NOT NULL,
      team_id INTEGER NOT NULL,
      PRIMARY KEY (storyline_id, team_id),
      FOREIGN KEY (storyline_id) REFERENCES $tableStorylines (${StorylinesFields.id}) ON DELETE CASCADE,
      FOREIGN KEY (team_id) REFERENCES $tableTeams (${TeamsFields.id}) ON DELETE CASCADE
    )''');

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
        ${ShowFields.summary} $textType,
        ${ShowFields.isCompleted} INTEGER NOT NULL DEFAULT 0
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
        ${MatchFormatsFields.category} TEXT NOT NULL DEFAULT 'individual',
        ${MatchFormatsFields.participantCount} INTEGER NOT NULL DEFAULT 2,
        ${MatchFormatsFields.sideCount} INTEGER NOT NULL DEFAULT 2,
        ${MatchFormatsFields.participantsPerSide} TEXT NOT NULL DEFAULT '[1,1]',
        ${MatchFormatsFields.isActive} INTEGER NOT NULL DEFAULT 1,
        UNIQUE (${MatchFormatsFields.name} COLLATE NOCASE)
      )
    ''');

    // MATCH TYPES + COMPATIBILITIES
    await db.execute('''CREATE TABLE $tableMatchTypes (
      ${MatchTypesFields.id} $idType,
      ${MatchTypesFields.name} $textType,
      ${MatchTypesFields.description} TEXT,
      ${MatchTypesFields.category} TEXT NOT NULL DEFAULT 'standard',
      ${MatchTypesFields.isActive} INTEGER NOT NULL DEFAULT 1,
      UNIQUE (${MatchTypesFields.name} COLLATE NOCASE)
    )''');
    await db.execute('''CREATE TABLE $tableMatchTypeFormats (
      ${MatchTypeFormatsFields.matchTypeId} $intTypeNN,
      ${MatchTypeFormatsFields.matchFormatId} $intTypeNN,
      PRIMARY KEY (${MatchTypeFormatsFields.matchTypeId}, ${MatchTypeFormatsFields.matchFormatId}),
      FOREIGN KEY (${MatchTypeFormatsFields.matchTypeId}) REFERENCES $tableMatchTypes (${MatchTypesFields.id}) ON DELETE CASCADE,
      FOREIGN KEY (${MatchTypeFormatsFields.matchFormatId}) REFERENCES $tableMatchFormats (${MatchFormatsFields.id}) ON DELETE CASCADE
    )''');

    await _seedMatchCatalog(db);

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
        ${MatchRecordFields.formatCategory} TEXT,
        ${MatchRecordFields.formatParticipantCount} INTEGER,
        ${MatchRecordFields.formatSideCount} INTEGER,
        ${MatchRecordFields.formatParticipantsPerSide} TEXT,
        ${MatchRecordFields.matchTypeId} $intType,
        ${MatchRecordFields.matchTypeName} $textType,
        ${MatchRecordFields.stipulationId} $intType,
        ${MatchRecordFields.stipulationName} $textType,
        ${MatchRecordFields.resultStatus} $textType,
        ${MatchRecordFields.winnerSideOrder} $intType,
        ${MatchRecordFields.winnerSuperstarId} $intType,
        ${MatchRecordFields.winnerName} TEXT,
        ${MatchRecordFields.titleChange} INTEGER NOT NULL DEFAULT 0,
        ${MatchRecordFields.matchOrder} $intTypeNN DEFAULT 0,
        ${MatchRecordFields.showId} $intTypeNN,
        ${MatchRecordFields.titleId} $intType,

        FOREIGN KEY (${MatchRecordFields.formatId})
          REFERENCES $tableMatchFormats (${MatchFormatsFields.id})
          ON DELETE SET NULL,

        FOREIGN KEY (${MatchRecordFields.matchTypeId})
          REFERENCES $tableMatchTypes (${MatchTypesFields.id})
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
        ${MatchParticipantsFields.sideId} $intType,
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
        ${ReignsFields.titleId} $intTypeNN,
        ${ReignsFields.holder1Id} $intType,
        ${ReignsFields.holder1Name} $textType,
        ${ReignsFields.holder2Id} $intType,
        ${ReignsFields.holder2Name} TEXT,
        ${ReignsFields.teamId} $intType,
        ${ReignsFields.teamName} TEXT,
        ${ReignsFields.yearStart} $intTypeNN,
        ${ReignsFields.weekStart} $intTypeNN,
        ${ReignsFields.dayStart} INTEGER NOT NULL DEFAULT 1,
        ${ReignsFields.yearEnd} $intType,
        ${ReignsFields.weekEnd} $intType,
        ${ReignsFields.dayEnd} INTEGER,
        ${ReignsFields.endReason} TEXT,
        ${ReignsFields.startMatchId} $intType,
        ${ReignsFields.endMatchId} $intType,
        FOREIGN KEY (${ReignsFields.titleId}) REFERENCES $tableTitles (${TitlesFields.id}) ON DELETE CASCADE,
        FOREIGN KEY (${ReignsFields.holder1Id}) REFERENCES $tableSuperstars (${SuperstarsFields.id}) ON DELETE SET NULL,
        FOREIGN KEY (${ReignsFields.holder2Id}) REFERENCES $tableSuperstars (${SuperstarsFields.id}) ON DELETE SET NULL,
        FOREIGN KEY (${ReignsFields.startMatchId}) REFERENCES $tableMatches (${MatchRecordFields.id}) ON DELETE SET NULL,
        FOREIGN KEY (${ReignsFields.endMatchId}) REFERENCES $tableMatches (${MatchRecordFields.id}) ON DELETE SET NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE $tableTitleReignEvents (
        ${TitleReignEventFields.id} $idType,
        ${TitleReignEventFields.titleId} $intTypeNN,
        ${TitleReignEventFields.eventType} $textType,
        ${TitleReignEventFields.year} $intTypeNN,
        ${TitleReignEventFields.week} $intTypeNN,
        ${TitleReignEventFields.dayOfWeek} INTEGER NOT NULL DEFAULT 0,
        ${TitleReignEventFields.matchOrder} INTEGER NOT NULL DEFAULT 0,
        ${TitleReignEventFields.matchId} $intType,
        ${TitleReignEventFields.holder1Id} $intType,
        ${TitleReignEventFields.holder1Name} TEXT,
        ${TitleReignEventFields.holder2Id} $intType,
        ${TitleReignEventFields.holder2Name} TEXT,
        ${TitleReignEventFields.teamId} $intType,
        ${TitleReignEventFields.teamName} TEXT,
        FOREIGN KEY (${TitleReignEventFields.titleId}) REFERENCES $tableTitles (${TitlesFields.id}) ON DELETE CASCADE,
        FOREIGN KEY (${TitleReignEventFields.matchId}) REFERENCES $tableMatches (${MatchRecordFields.id}) ON DELETE CASCADE
      )
    ''');
    await db.execute('CREATE INDEX idx_reigns_title_start ON $tableReigns (${ReignsFields.titleId}, ${ReignsFields.yearStart}, ${ReignsFields.weekStart})');
    await db.execute('CREATE INDEX idx_title_events_match ON $tableTitleReignEvents (${TitleReignEventFields.matchId})');

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

    await _createLot22Tables(db);
    await _seedWwe26Catalog(db);
  }

  Future<void> _createLot22Tables(DatabaseExecutor db) async {
    await db.execute('''CREATE TABLE IF NOT EXISTS $tableSuperstarRelationships (
      ${SuperstarRelationshipFields.superstarId} INTEGER NOT NULL,
      ${SuperstarRelationshipFields.relatedSuperstarId} INTEGER NOT NULL,
      ${SuperstarRelationshipFields.type} TEXT NOT NULL CHECK (${SuperstarRelationshipFields.type} IN ('manager','ally','rival')),
      PRIMARY KEY (${SuperstarRelationshipFields.superstarId}, ${SuperstarRelationshipFields.relatedSuperstarId}, ${SuperstarRelationshipFields.type}),
      CHECK (${SuperstarRelationshipFields.superstarId} != ${SuperstarRelationshipFields.relatedSuperstarId}),
      FOREIGN KEY (${SuperstarRelationshipFields.superstarId}) REFERENCES $tableSuperstars (${SuperstarsFields.id}) ON DELETE CASCADE,
      FOREIGN KEY (${SuperstarRelationshipFields.relatedSuperstarId}) REFERENCES $tableSuperstars (${SuperstarsFields.id}) ON DELETE CASCADE
    )''');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_superstar_relationship_related ON $tableSuperstarRelationships (${SuperstarRelationshipFields.relatedSuperstarId})');
    await db.execute('''CREATE TABLE IF NOT EXISTS $tableMatchParticipantManagers (
      ${MatchParticipantManagerFields.id} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${MatchParticipantManagerFields.matchId} INTEGER NOT NULL,
      ${MatchParticipantManagerFields.participantSuperstarId} INTEGER NOT NULL,
      ${MatchParticipantManagerFields.managerSuperstarId} INTEGER NOT NULL,
      UNIQUE (${MatchParticipantManagerFields.matchId}, ${MatchParticipantManagerFields.participantSuperstarId}, ${MatchParticipantManagerFields.managerSuperstarId}),
      FOREIGN KEY (${MatchParticipantManagerFields.matchId}) REFERENCES $tableMatches (${MatchRecordFields.id}) ON DELETE CASCADE,
      FOREIGN KEY (${MatchParticipantManagerFields.participantSuperstarId}) REFERENCES $tableSuperstars (${SuperstarsFields.id}) ON DELETE CASCADE,
      FOREIGN KEY (${MatchParticipantManagerFields.managerSuperstarId}) REFERENCES $tableSuperstars (${SuperstarsFields.id}) ON DELETE CASCADE
    )''');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_match_participant_managers_match ON $tableMatchParticipantManagers (${MatchParticipantManagerFields.matchId})');
    await db.execute('''CREATE TABLE IF NOT EXISTS $tableMatchParticipantManagerOverrides (
      match_id INTEGER NOT NULL, participant_superstar_id INTEGER NOT NULL,
      PRIMARY KEY (match_id, participant_superstar_id),
      FOREIGN KEY (match_id) REFERENCES $tableMatches (${MatchRecordFields.id}) ON DELETE CASCADE,
      FOREIGN KEY (participant_superstar_id) REFERENCES $tableSuperstars (${SuperstarsFields.id}) ON DELETE CASCADE
    )''');
  }

  Future<void> _createNewsAssociationTables(DatabaseExecutor db) async {
    final definitions = <String, String>{
      'news_superstars': 'superstar_id',
      'news_teams': 'team_id',
      'news_titles': 'title_id',
      'news_shows': 'show_id',
    };
    final references = <String, String>{
      'news_superstars': '$tableSuperstars (${SuperstarsFields.id})',
      'news_teams': '$tableTeams (${TeamsFields.id})',
      'news_titles': '$tableTitles (${TitlesFields.id})',
      'news_shows': '$tableShows (${ShowFields.id})',
    };
    for (final entry in definitions.entries) {
      await db.execute('''CREATE TABLE IF NOT EXISTS ${entry.key} (
        news_id INTEGER NOT NULL,
        ${entry.value} INTEGER NOT NULL,
        PRIMARY KEY (news_id, ${entry.value}),
        FOREIGN KEY (news_id) REFERENCES $tableNews (${NewsFields.id}) ON DELETE CASCADE,
        FOREIGN KEY (${entry.value}) REFERENCES ${references[entry.key]} ON DELETE CASCADE
      )''');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_${entry.key}_entity ON ${entry.key} (${entry.value})');
    }
  }

  Future<void> _updateDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 93) {
      final columns = await db.rawQuery('PRAGMA table_info($tableStorylines)');
      final existing = columns.map((row) => row['name'] as String).toSet();
      if (!existing.contains(StorylinesFields.dayStart)) {
        await db.execute(
          'ALTER TABLE $tableStorylines ADD COLUMN ${StorylinesFields.dayStart} INTEGER NOT NULL DEFAULT 1',
        );
      }
      if (!existing.contains(StorylinesFields.dayEnd)) {
        await db.execute(
          'ALTER TABLE $tableStorylines ADD COLUMN ${StorylinesFields.dayEnd} INTEGER NOT NULL DEFAULT 1',
        );
      }
    }
    if (oldVersion < 91) {
      final columns = await db.rawQuery('PRAGMA table_info($tableShows)');
      final existing = columns.map((row) => row['name'] as String).toSet();
      if (!existing.contains(ShowFields.isCompleted)) {
        await db.execute(
          'ALTER TABLE $tableShows ADD COLUMN ${ShowFields.isCompleted} INTEGER NOT NULL DEFAULT 0',
        );
      }
    }

    if (oldVersion < 89) await _createLot22Tables(db);
    if (oldVersion < 88) {
      await _seedWwe26Catalog(db);
    }
    if (oldVersion < 87) {
      await _createNewsAssociationTables(db);
    }

    if (oldVersion < 86) {
      // News dates are optional for legacy records; new records enter through
      // the form with a complete WWE calendar date.
      final columns = await db.rawQuery('PRAGMA table_info($tableNews)');
      final existing = columns.map((row) => row['name'] as String).toSet();
      final additions = <String, String>{
        NewsFields.year: 'INTEGER',
        NewsFields.week: 'INTEGER',
        NewsFields.dayOfWeek: 'INTEGER',
      };
      for (final entry in additions.entries) {
        if (!existing.contains(entry.key)) {
          await db.execute('ALTER TABLE $tableNews ADD COLUMN ${entry.key} ${entry.value}');
        }
      }
      await db.execute('CREATE INDEX IF NOT EXISTS idx_news_wwe_date ON $tableNews (${NewsFields.year}, ${NewsFields.week}, ${NewsFields.dayOfWeek})');
    }
    if (oldVersion < 85) {
      await db.execute('''CREATE TABLE IF NOT EXISTS $tableStorylineEvents (
        ${StorylineEventFields.id} $idType,
        ${StorylineEventFields.storylineId} INTEGER NOT NULL,
        ${StorylineEventFields.type} TEXT NOT NULL DEFAULT 'segment',
        ${StorylineEventFields.title} $textType,
        ${StorylineEventFields.description} TEXT NOT NULL DEFAULT '',
        ${StorylineEventFields.year} INTEGER NOT NULL,
        ${StorylineEventFields.week} INTEGER NOT NULL,
        ${StorylineEventFields.dayOfWeek} INTEGER NOT NULL DEFAULT 1,
        ${StorylineEventFields.position} INTEGER NOT NULL DEFAULT 0,
        ${StorylineEventFields.matchId} INTEGER,
        ${StorylineEventFields.newsId} INTEGER,
        FOREIGN KEY (${StorylineEventFields.storylineId}) REFERENCES $tableStorylines (${StorylinesFields.id}) ON DELETE CASCADE,
        FOREIGN KEY (${StorylineEventFields.matchId}) REFERENCES $tableMatches (${MatchRecordFields.id}) ON DELETE SET NULL,
        FOREIGN KEY (${StorylineEventFields.newsId}) REFERENCES $tableNews (${NewsFields.id}) ON DELETE SET NULL
      )''');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_storyline_events_order ON $tableStorylineEvents (${StorylineEventFields.storylineId}, ${StorylineEventFields.year}, ${StorylineEventFields.week}, ${StorylineEventFields.dayOfWeek}, ${StorylineEventFields.position})');
    }
    if (oldVersion < 84) {
      await db.execute('''CREATE TABLE IF NOT EXISTS storyline_superstars (
        storyline_id INTEGER NOT NULL,
        superstar_id INTEGER NOT NULL,
        PRIMARY KEY (storyline_id, superstar_id),
        FOREIGN KEY (storyline_id) REFERENCES $tableStorylines (${StorylinesFields.id}) ON DELETE CASCADE,
        FOREIGN KEY (superstar_id) REFERENCES $tableSuperstars (${SuperstarsFields.id}) ON DELETE CASCADE
      )''');
      await db.execute('''CREATE TABLE IF NOT EXISTS storyline_teams (
        storyline_id INTEGER NOT NULL,
        team_id INTEGER NOT NULL,
        PRIMARY KEY (storyline_id, team_id),
        FOREIGN KEY (storyline_id) REFERENCES $tableStorylines (${StorylinesFields.id}) ON DELETE CASCADE,
        FOREIGN KEY (team_id) REFERENCES $tableTeams (${TeamsFields.id}) ON DELETE CASCADE
      )''');
    }
    if (oldVersion < 83) {
      final newsColumns = await db.rawQuery('PRAGMA table_info($tableNews)');
      final newsExisting = newsColumns.map((row) => row['name'] as String).toSet();
      final newsAdditions = <String, String>{
        NewsFields.year: 'INTEGER',
        NewsFields.week: 'INTEGER',
        NewsFields.dayOfWeek: 'INTEGER',
      };
      for (final entry in newsAdditions.entries) {
        if (!newsExisting.contains(entry.key)) {
          await db.execute('ALTER TABLE $tableNews ADD COLUMN ${entry.key} ${entry.value}');
        }
      }

      final storylineColumns = await db.rawQuery('PRAGMA table_info($tableStorylines)');
      final storylineExisting = storylineColumns.map((row) => row['name'] as String).toSet();
      if (!storylineExisting.contains(StorylinesFields.status)) {
        await db.execute("ALTER TABLE $tableStorylines ADD COLUMN ${StorylinesFields.status} TEXT NOT NULL DEFAULT 'ongoing'");
        // Preserve the old convention: a non-zero ending week means completed.
        await db.execute("UPDATE $tableStorylines SET ${StorylinesFields.status} = 'completed' WHERE ${StorylinesFields.end} != 0");
      }

      await db.execute('''CREATE TABLE IF NOT EXISTS storyline_news (
        storyline_id INTEGER NOT NULL,
        news_id INTEGER NOT NULL,
        position INTEGER NOT NULL DEFAULT 0,
        PRIMARY KEY (storyline_id, news_id),
        FOREIGN KEY (storyline_id) REFERENCES $tableStorylines (${StorylinesFields.id}) ON DELETE CASCADE,
        FOREIGN KEY (news_id) REFERENCES $tableNews (${NewsFields.id}) ON DELETE CASCADE
      )''');
      await db.execute('''CREATE TABLE IF NOT EXISTS storyline_matches (
        storyline_id INTEGER NOT NULL,
        match_id INTEGER NOT NULL,
        position INTEGER NOT NULL DEFAULT 0,
        PRIMARY KEY (storyline_id, match_id),
        FOREIGN KEY (storyline_id) REFERENCES $tableStorylines (${StorylinesFields.id}) ON DELETE CASCADE,
        FOREIGN KEY (match_id) REFERENCES $tableMatches (${MatchRecordFields.id}) ON DELETE CASCADE
      )''');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_storyline_news_news ON storyline_news (news_id)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_storyline_matches_match ON storyline_matches (match_id)');
    }
    if (oldVersion < 82) {
      final columns = await db.rawQuery('PRAGMA table_info($tableSuperstars)');
      final existing = columns.map((row) => row['name'] as String).toSet();
      if (!existing.contains(SuperstarsFields.photoUrl)) {
        await db.execute('ALTER TABLE $tableSuperstars ADD COLUMN ${SuperstarsFields.photoUrl} TEXT');
      }
    }

    if (oldVersion < 78) {
      final columns = await db.rawQuery('PRAGMA table_info($tableMatchFormats)');
      final existing = columns.map((row) => row['name'] as String).toSet();
      final additions = <String, String>{
        MatchFormatsFields.category: "TEXT NOT NULL DEFAULT 'individual'",
        MatchFormatsFields.participantCount: 'INTEGER NOT NULL DEFAULT 2',
        MatchFormatsFields.sideCount: 'INTEGER NOT NULL DEFAULT 2',
        MatchFormatsFields.participantsPerSide: "TEXT NOT NULL DEFAULT '[1,1]'",
        MatchFormatsFields.isActive: 'INTEGER NOT NULL DEFAULT 1',
      };
      for (final entry in additions.entries) {
        if (!existing.contains(entry.key)) {
          await db.execute('ALTER TABLE $tableMatchFormats ADD COLUMN ${entry.key} ${entry.value}');
        }
      }
      await db.execute('''CREATE TABLE IF NOT EXISTS $tableMatchTypes (
        ${MatchTypesFields.id} $idType, ${MatchTypesFields.name} $textType,
        ${MatchTypesFields.description} TEXT, ${MatchTypesFields.category} TEXT NOT NULL DEFAULT 'standard',
        ${MatchTypesFields.isActive} INTEGER NOT NULL DEFAULT 1,
        UNIQUE (${MatchTypesFields.name} COLLATE NOCASE))''');
      await db.execute('''CREATE TABLE IF NOT EXISTS $tableMatchTypeFormats (
        ${MatchTypeFormatsFields.matchTypeId} $intTypeNN,
        ${MatchTypeFormatsFields.matchFormatId} $intTypeNN,
        PRIMARY KEY (${MatchTypeFormatsFields.matchTypeId}, ${MatchTypeFormatsFields.matchFormatId}),
        FOREIGN KEY (${MatchTypeFormatsFields.matchTypeId}) REFERENCES $tableMatchTypes (${MatchTypesFields.id}) ON DELETE CASCADE,
        FOREIGN KEY (${MatchTypeFormatsFields.matchFormatId}) REFERENCES $tableMatchFormats (${MatchFormatsFields.id}) ON DELETE CASCADE)''');
      await _seedMatchCatalog(db);
    }

    if (oldVersion < 79) {
      final matchColumns = await db.rawQuery('PRAGMA table_info($tableMatches)');
      final matchExisting = matchColumns.map((row) => row['name'] as String).toSet();
      if (!matchExisting.contains(MatchRecordFields.matchTypeId)) {
        await db.execute('ALTER TABLE $tableMatches ADD COLUMN ${MatchRecordFields.matchTypeId} INTEGER');
      }
      if (!matchExisting.contains(MatchRecordFields.matchTypeName)) {
        await db.execute("ALTER TABLE $tableMatches ADD COLUMN ${MatchRecordFields.matchTypeName} TEXT NOT NULL DEFAULT ''");
      }

      // Autorise les participants sans camp (Royal Rumble, Gauntlet, Battle Royal).
      final participantColumns = await db.rawQuery('PRAGMA table_info($tableMatchParticipants)');
      final sideColumn = participantColumns.firstWhere(
        (row) => row['name'] == MatchParticipantsFields.sideId,
        orElse: () => <String, Object?>{},
      );
      if (sideColumn.isNotEmpty && sideColumn['notnull'] == 1) {
        await db.execute('''CREATE TABLE match_participants_new (
          ${MatchParticipantsFields.id} INTEGER PRIMARY KEY AUTOINCREMENT,
          ${MatchParticipantsFields.matchId} INTEGER NOT NULL,
          ${MatchParticipantsFields.sideId} INTEGER,
          ${MatchParticipantsFields.position} INTEGER NOT NULL,
          ${MatchParticipantsFields.superstarId} INTEGER,
          ${MatchParticipantsFields.superstarName} TEXT NOT NULL,
          UNIQUE (${MatchParticipantsFields.sideId}, ${MatchParticipantsFields.position}),
          FOREIGN KEY (${MatchParticipantsFields.matchId}) REFERENCES $tableMatches (${MatchRecordFields.id}) ON DELETE CASCADE,
          FOREIGN KEY (${MatchParticipantsFields.sideId}) REFERENCES $tableMatchSides (${MatchSidesFields.id}) ON DELETE CASCADE,
          FOREIGN KEY (${MatchParticipantsFields.superstarId}) REFERENCES $tableSuperstars (${SuperstarsFields.id}) ON DELETE SET NULL
        )''');
        await db.execute('''INSERT INTO match_participants_new
          (${MatchParticipantsFields.id}, ${MatchParticipantsFields.matchId}, ${MatchParticipantsFields.sideId}, ${MatchParticipantsFields.position}, ${MatchParticipantsFields.superstarId}, ${MatchParticipantsFields.superstarName})
          SELECT ${MatchParticipantsFields.id}, ${MatchParticipantsFields.matchId}, ${MatchParticipantsFields.sideId}, ${MatchParticipantsFields.position}, ${MatchParticipantsFields.superstarId}, ${MatchParticipantsFields.superstarName}
          FROM $tableMatchParticipants''');
        await db.execute('DROP TABLE $tableMatchParticipants');
        await db.execute('ALTER TABLE match_participants_new RENAME TO $tableMatchParticipants');
        await db.execute('CREATE INDEX IF NOT EXISTS idx_match_participants_match ON $tableMatchParticipants (${MatchParticipantsFields.matchId})');
        await db.execute('CREATE INDEX IF NOT EXISTS idx_match_participants_side_position ON $tableMatchParticipants (${MatchParticipantsFields.sideId}, ${MatchParticipantsFields.position})');
        await db.execute('CREATE INDEX IF NOT EXISTS idx_match_participants_superstar ON $tableMatchParticipants (${MatchParticipantsFields.superstarId})');
      }
    }

    if (oldVersion < 80) {
      final columns = await db.rawQuery('PRAGMA table_info($tableMatches)');
      final existing = columns.map((row) => row['name'] as String).toSet();

      final additions = <String, String>{
        MatchRecordFields.formatCategory: 'TEXT',
        MatchRecordFields.formatParticipantCount: 'INTEGER',
        MatchRecordFields.formatSideCount: 'INTEGER',
        MatchRecordFields.formatParticipantsPerSide: 'TEXT',
      };

      for (final entry in additions.entries) {
        if (!existing.contains(entry.key)) {
          await db.execute(
            'ALTER TABLE $tableMatches ADD COLUMN ${entry.key} ${entry.value}',
          );
        }
      }

      // Récupération de la structure actuelle pour les combats
      // dont le format est encore présent dans le catalogue.
      await db.execute('''
        UPDATE $tableMatches
        SET
          ${MatchRecordFields.formatCategory} = (
            SELECT ${MatchFormatsFields.category}
            FROM $tableMatchFormats
            WHERE ${MatchFormatsFields.id} = $tableMatches.${MatchRecordFields.formatId}
          ),
          ${MatchRecordFields.formatParticipantCount} = (
            SELECT ${MatchFormatsFields.participantCount}
            FROM $tableMatchFormats
            WHERE ${MatchFormatsFields.id} = $tableMatches.${MatchRecordFields.formatId}
          ),
          ${MatchRecordFields.formatSideCount} = (
            SELECT ${MatchFormatsFields.sideCount}
            FROM $tableMatchFormats
            WHERE ${MatchFormatsFields.id} = $tableMatches.${MatchRecordFields.formatId}
          ),
          ${MatchRecordFields.formatParticipantsPerSide} = (
            SELECT ${MatchFormatsFields.participantsPerSide}
            FROM $tableMatchFormats
            WHERE ${MatchFormatsFields.id} = $tableMatches.${MatchRecordFields.formatId}
          )
        WHERE ${MatchRecordFields.formatId} IS NOT NULL
      ''');
    }

    if (oldVersion < 81) {
      final columns = await db.rawQuery('PRAGMA table_info($tableMatches)');
      final existing = columns.map((row) => row['name'] as String).toSet();
      if (!existing.contains(MatchRecordFields.titleChange)) {
        await db.execute('ALTER TABLE $tableMatches ADD COLUMN ${MatchRecordFields.titleChange} INTEGER NOT NULL DEFAULT 0');
      }
      await db.execute('DROP TABLE IF EXISTS $tableReigns');
      await db.execute('''CREATE TABLE $tableReigns (
        ${ReignsFields.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${ReignsFields.titleId} INTEGER NOT NULL,
        ${ReignsFields.holder1Id} INTEGER,
        ${ReignsFields.holder1Name} TEXT NOT NULL,
        ${ReignsFields.holder2Id} INTEGER,
        ${ReignsFields.holder2Name} TEXT,
        ${ReignsFields.teamId} INTEGER,
        ${ReignsFields.teamName} TEXT,
        ${ReignsFields.yearStart} INTEGER NOT NULL,
        ${ReignsFields.weekStart} INTEGER NOT NULL,
        ${ReignsFields.yearEnd} INTEGER,
        ${ReignsFields.weekEnd} INTEGER,
        ${ReignsFields.endReason} TEXT,
        ${ReignsFields.startMatchId} INTEGER,
        ${ReignsFields.endMatchId} INTEGER,
        FOREIGN KEY (${ReignsFields.titleId}) REFERENCES $tableTitles (${TitlesFields.id}) ON DELETE CASCADE,
        FOREIGN KEY (${ReignsFields.holder1Id}) REFERENCES $tableSuperstars (${SuperstarsFields.id}) ON DELETE SET NULL,
        FOREIGN KEY (${ReignsFields.holder2Id}) REFERENCES $tableSuperstars (${SuperstarsFields.id}) ON DELETE SET NULL,
        FOREIGN KEY (${ReignsFields.startMatchId}) REFERENCES $tableMatches (${MatchRecordFields.id}) ON DELETE SET NULL,
        FOREIGN KEY (${ReignsFields.endMatchId}) REFERENCES $tableMatches (${MatchRecordFields.id}) ON DELETE SET NULL
      )''');
      await db.execute('''CREATE TABLE $tableTitleReignEvents (
        ${TitleReignEventFields.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${TitleReignEventFields.titleId} INTEGER NOT NULL,
        ${TitleReignEventFields.eventType} TEXT NOT NULL,
        ${TitleReignEventFields.year} INTEGER NOT NULL,
        ${TitleReignEventFields.week} INTEGER NOT NULL,
        ${TitleReignEventFields.dayOfWeek} INTEGER NOT NULL DEFAULT 0,
        ${TitleReignEventFields.matchOrder} INTEGER NOT NULL DEFAULT 0,
        ${TitleReignEventFields.matchId} INTEGER,
        ${TitleReignEventFields.holder1Id} INTEGER,
        ${TitleReignEventFields.holder1Name} TEXT,
        ${TitleReignEventFields.holder2Id} INTEGER,
        ${TitleReignEventFields.holder2Name} TEXT,
        ${TitleReignEventFields.teamId} INTEGER,
        ${TitleReignEventFields.teamName} TEXT,
        FOREIGN KEY (${TitleReignEventFields.titleId}) REFERENCES $tableTitles (${TitlesFields.id}) ON DELETE CASCADE,
        FOREIGN KEY (${TitleReignEventFields.matchId}) REFERENCES $tableMatches (${MatchRecordFields.id}) ON DELETE CASCADE
      )''');
      await db.execute('CREATE INDEX idx_reigns_title_start ON $tableReigns (${ReignsFields.titleId}, ${ReignsFields.yearStart}, ${ReignsFields.weekStart})');
      await db.execute('CREATE INDEX idx_title_events_match ON $tableTitleReignEvents (${TitleReignEventFields.matchId})');
    }

    if (oldVersion < 90) {
      final reignColumns = await db.rawQuery('PRAGMA table_info($tableReigns)');
      final existingReignColumns = reignColumns.map((row) => row['name'] as String).toSet();
      if (!existingReignColumns.contains(ReignsFields.teamId)) {
        await db.execute('ALTER TABLE $tableReigns ADD COLUMN ${ReignsFields.teamId} INTEGER');
      }
      if (!existingReignColumns.contains(ReignsFields.teamName)) {
        await db.execute('ALTER TABLE $tableReigns ADD COLUMN ${ReignsFields.teamName} TEXT');
      }
      final eventColumns = await db.rawQuery('PRAGMA table_info($tableTitleReignEvents)');
      final existingEventColumns = eventColumns.map((row) => row['name'] as String).toSet();
      if (!existingEventColumns.contains(TitleReignEventFields.teamId)) {
        await db.execute('ALTER TABLE $tableTitleReignEvents ADD COLUMN ${TitleReignEventFields.teamId} INTEGER');
      }
      if (!existingEventColumns.contains(TitleReignEventFields.teamName)) {
        await db.execute('ALTER TABLE $tableTitleReignEvents ADD COLUMN ${TitleReignEventFields.teamName} TEXT');
      }
    }

    if (oldVersion < 92) {
      final columns = await db.rawQuery('PRAGMA table_info($tableReigns)');
      final existing = columns.map((row) => row['name'] as String).toSet();
      if (!existing.contains(ReignsFields.dayStart)) {
        await db.execute('ALTER TABLE $tableReigns ADD COLUMN ${ReignsFields.dayStart} INTEGER NOT NULL DEFAULT 1');
      }
      if (!existing.contains(ReignsFields.dayEnd)) {
        await db.execute('ALTER TABLE $tableReigns ADD COLUMN ${ReignsFields.dayEnd} INTEGER');
      }
      // Restore exact days from the event ledger for reigns created before Lot 26.
      await db.execute('''UPDATE $tableReigns SET ${ReignsFields.dayStart} = COALESCE((
        SELECT CASE WHEN e.${TitleReignEventFields.dayOfWeek} BETWEEN 1 AND 7 THEN e.${TitleReignEventFields.dayOfWeek} ELSE 1 END FROM $tableTitleReignEvents e
        WHERE e.${TitleReignEventFields.titleId} = $tableReigns.${ReignsFields.titleId}
          AND e.${TitleReignEventFields.eventType} = 'change'
          AND e.${TitleReignEventFields.year} = $tableReigns.${ReignsFields.yearStart}
          AND e.${TitleReignEventFields.week} = $tableReigns.${ReignsFields.weekStart}
          AND (($tableReigns.${ReignsFields.startMatchId} IS NOT NULL AND e.${TitleReignEventFields.matchId} = $tableReigns.${ReignsFields.startMatchId}) OR ($tableReigns.${ReignsFields.startMatchId} IS NULL AND e.${TitleReignEventFields.matchId} IS NULL))
          AND (e.${TitleReignEventFields.holder1Id} = $tableReigns.${ReignsFields.holder1Id} OR (e.${TitleReignEventFields.holder1Id} IS NULL AND $tableReigns.${ReignsFields.holder1Id} IS NULL))
        ORDER BY CASE WHEN e.${TitleReignEventFields.dayOfWeek} BETWEEN 1 AND 7 THEN 0 ELSE 1 END, e.${TitleReignEventFields.dayOfWeek}, e.${TitleReignEventFields.matchOrder}, e.${TitleReignEventFields.id} LIMIT 1
      ), 1)''');
      await db.execute('''UPDATE $tableReigns SET ${ReignsFields.dayEnd} = (
        SELECT CASE WHEN e.${TitleReignEventFields.dayOfWeek} BETWEEN 1 AND 7 THEN e.${TitleReignEventFields.dayOfWeek} ELSE 1 END FROM $tableTitleReignEvents e
        WHERE e.${TitleReignEventFields.titleId} = $tableReigns.${ReignsFields.titleId}
          AND e.${TitleReignEventFields.year} = $tableReigns.${ReignsFields.yearEnd}
          AND e.${TitleReignEventFields.week} = $tableReigns.${ReignsFields.weekEnd}
          AND (( $tableReigns.${ReignsFields.endMatchId} IS NOT NULL AND e.${TitleReignEventFields.matchId} = $tableReigns.${ReignsFields.endMatchId})
            OR ($tableReigns.${ReignsFields.endMatchId} IS NULL AND $tableReigns.${ReignsFields.endReason} = 'vacated' AND e.${TitleReignEventFields.eventType} = 'vacated')
            OR ($tableReigns.${ReignsFields.endMatchId} IS NULL AND $tableReigns.${ReignsFields.endReason} = 'titleChange' AND e.${TitleReignEventFields.eventType} = 'change' AND e.${TitleReignEventFields.matchId} IS NULL))
        ORDER BY CASE WHEN e.${TitleReignEventFields.dayOfWeek} BETWEEN 1 AND 7 THEN 0 ELSE 1 END, e.${TitleReignEventFields.dayOfWeek}, e.${TitleReignEventFields.matchOrder}, e.${TitleReignEventFields.id} LIMIT 1
      ) WHERE ${ReignsFields.yearEnd} IS NOT NULL''');
    }
  }


  /// Ajoute le catalogue WWE 2K26 sans modifier les entrées déjà présentes.
  /// Les noms alternatifs/personas sont conservés comme entrées distinctes.
  Future<void> _seedWwe26Catalog(DatabaseExecutor db) async {
    const brandNames = ['Raw', 'SmackDown', 'NXT', 'AAA', 'ECW', 'WCW'];
    final brandIds = <String, int>{};
    for (final name in brandNames) {
      final rows = await db.query(tableBrands, columns: [BrandsFields.id],
          where: 'LOWER(${BrandsFields.name}) = LOWER(?)', whereArgs: [name], limit: 1);
      final id = rows.isNotEmpty ? rows.first[BrandsFields.id] as int :
          await db.insert(tableBrands, {BrandsFields.name: name}, conflictAlgorithm: ConflictAlgorithm.ignore);
      final refreshed = await db.query(tableBrands, columns: [BrandsFields.id],
          where: 'LOWER(${BrandsFields.name}) = LOWER(?)', whereArgs: [name], limit: 1);
      brandIds[name] = refreshed.isNotEmpty ? refreshed.first[BrandsFields.id] as int : id;
    }

    // Nom, brand. Les personnages historiques/DLC non rattachés à une brand
    // actuelle restent sans brand afin de ne pas inventer d'affiliation.
    const raw = <String>[
      'AJ Styles','AJ Styles ’16','AJ Lee','AJ Lee ’15','Akam','Akira Tozawa','Alba Fyre','Aleister Black','Alexa Bliss','Alexa Bliss ’25','Alicia Taylor','Alundra Blayze','Alundra Blayze ’94','Andre Chase','André the Giant','Angel','Angelo Dawkins','Apollo Crews','Asuka','Austin Theory','Ava','Axiom','B-Fab','Bayley','Becky Lynch','Berto','Bianca Belair','Big E','Blake Monroe','Bron Breakker','Bronson Reed','Brooks Jensen','Brutus Creed','Carmelo Hayes','Candice LeRae','Chad Gable','Channing Lorenzo','Charlie Dempsey','Charlotte Flair','Chelsea Green','Chris Sabin','CM Punk','Cody Rhodes','Cruz Del Toro','Damian Priest','Dexter Lumis','Dominik Mysterio','Dominik Mysterio (Masked)','Dragon Lee','Drew McIntyre','Drew McIntyre ’10','El Grande Americano','Elton Prince','Erick Rowan','Erik','Ethan Page','Fallon Henley','Finn Bálor','Giulia','Grayson Waller','Gunther','Hank Walker','Ilja Dragunov','Ivar','Ivy Nile','Iyo Sky','Izzi Dame','Jacob Fatu','Jacy Jayne','Jade Cargill','Jaida Parker','Jazmyn Nyx','JC Mateo','JD McDonagh','Je’Von Evans','Jey Uso','Jimmy Uso','Joaquin Wilde','Joe Gacy','Johnny Gargano','Jordynne Grace','Josh Briggs','Julius Creed','Kairi Sane','Karmen Petrovic','Kelani Jordan','Kiana James','Kit Wilson','Kofi Kingston','LA Knight','Lash Legend','Lexis King','Liv Morgan','Logan Paul','Lola Vice','Ludwig Kaiser','Lyra Valkyria','Maxxine Dupri','Michin','Montez Ford','Myles Borne','Naomi','Natalya','Nathan Frazer','Nia Jax','Nick Aldis','Nikki Bella','Nikki Cross','Nikkita Lyons','Noam Dar','Oba Femi','Omos','Otis','Penta','Pete Dunne','Piper Niven','R-Truth','Raquel Rodriguez','Randy Orton','Randy Orton ’11','Randy Orton ’14','Rey Fenix','Rey Mysterio','Rey Mysterio ’08','Rhea Ripley','Ricky Saints','Ridge Holland','Roman Reigns','Roxanne Perez','Rusev','Sami Zayn','Santos Escobar','Seth Rollins','Seth Rollins ’15','Seth Rollins ’25','Seth Rollins WM41','Shawn Spears','Sheamus','Shinsuke Nakamura','Sol Ruca','Solo Sikoa','Stephanie Vaquer','Talla Tonga','Tama Tonga','Tank Ledger','Tatum Paxley','Tavion Heights','The Miz','The Miz ’17','Thea Hail','Tiffany Stratton','Tommaso Ciampa','Tony D’Angelo','Trick Williams','Tyler Bate','Tyler Breeze','Wendy Choo','Wren Sinclair','Xavier Woods','Yoshiki Inamura','Zaria','Zelina Vega','Zoey Stark',
      'Abyss','Afa','“Badd Ass” Billy Gunn','Bam Bam Bigelow','Batista','Bobby Heenan','Boogeyman','Booker T','Booker T ’01','Bray Wyatt','Bret Hart','Brian Pillman','British Bulldog','Brock Lesnar','Brock Lesnar ’01','Brock Lesnar ’13','Bubba Ray Dudley','Bull Nakano','Cactus Jack','Captain Lou Albano','Chyna','Chyna ’97','CM Punk ’08','CM Punk ’11','CM Punk ’13','CM Punk Retro','CM Punk Bad Blood 2024','CM Punk WrestleMania 41','Crush','D-Von Dudley','D’Lo Brown','DDP','DDP ’98','“Demon” Finn Bálor','Diesel','Doink The Clown','Dude Love','Dusty Rhodes','Dusty Rhodes ’89','Earthquake','Eddie Guerrero','Eddie Guerrero ’97','Eric Bischoff','Eve Torres','Faarooq','The Fiend Bray Wyatt','The Fiend Bray Wyatt ’23','The Fiend Bray Wyatt (Burned)','Flammer','Goldberg','The Great Khali','The Great Muta','Haku','Hollywood Hogan','The Honky Tonk Man','Hulk Hogan','Hulk Hogan ’02','Hunter Hearst Helmsley','The Hurricane','The Iron Sheik','JBL','Jean Paul Levesque','Jeff Hardy','Jelly Roll','Jesse Ventura','Jim Neidhart','Jimmy Hart','Joe Hendry','John Cena','John Cena ’13','John Cena ’15','Kane','Kane ’08','Kane ’98','Kelly Kelly','Ken Shamrock','Kevin Nash','Kevin Owens','Kurt Angle','Kurt Angle ’19','La Parka','Lady Shani','Lex Luger','Lita','“Macho Man” Randy Savage','“Macho Man” Randy Savage ’98','Mankind','Mark Henry','Maryse','Matt Cardona','Matt Hardy','Michelle McCool','Mick Foley','Miss Elizabeth','Molly Holly','Mosh','Mr. Fuji','Mr. Iguana','Mr. Perfect','Paul Orndorff','New Jack','Octagon Jr.','Pagano','Pat McAfee','Paul Bearer','Paul Heyman','Psycho Clown','“Ravishing” Rick Rude','Razor Ramon','The Sandman','Scott Hall','Scott Steiner ’03','Scott Steiner ’93','Sensational Sherri','Shawn Michaels','Shawn Michaels ’05','Shawn Michaels ’94','Shawn Michaels ’97','Shawn Michaels DX','Sid Justice','Sika','Smash','Stacy Keibler','Stephanie McMahon','Stephanie McMahon-Helmsley','“Stone Cold” Steve Austin','“Superstar” Billy Graham','Syxx','Tama','Terry Funk','Thrasher','Tito Santana','Torrie Wilson','Triple H','Triple H ’08','Triple H ’14','Triple H ’98','Triple H ’99','Trish Stratus','Typhoon','Ultimate Warrior','Umaga','Uncle Howdy','Undertaker','Undertaker ’03','Undertaker ’13','Undertaker ’98','Vader','Victoria','William Regal','X-Pac','Yokozuna','Rocky Maivia','The Rock','The Rock ’01','The Rock ’13','The Rock ’99','Rowdy Roddy Piper','Rowdy Roddy Piper ’98','Road Dogg Jesse James','Rob Van Dam','Rob Van Dam ’97','Rikishi','Rosey','Royce Keys','Tonga Loa','Teddy Long','The Great Khali','The Lock','Original El Grande Americano'
    ];
    const extras = <String>[
      'Adam Pearce','Adam Pearce ’12','Adrian Butler','Armando Alejandro Estrada','Ax','Bobby Newton','Bronze Breakker','Buzz','Brother Love','Byron Saxton','The Captain','Carly Prime','Cathy Kelley','Chad Patton','Charles Robinson','Chase','Chip Danning','Chosen','CM Hart','Cole Quinn','Corey Graves','Crush','Dahlia Hex','Dallas Irvin','Dan Engler','Danilo Anfibio','Daphanie LaShaunn','The Dark Horse','Delilah Hex','Derek Sanders','El Mago Jr.','El Ordinario','Felix Hernandez','Gabriel Slade','Gary Wilson','Geneva Rose','Hector Flores','Hector Flores (Wyatt Sicks)','Jason Ayers','Jeremy Marcus','Jessika Carr','Joey Gonzales','Josie Jane','Juggernaut Grace','Justine','Justine ’99','La Congrejita Loca','LJ','Main Event R-Truth','Marshall Thompson','Meilee Fanny Fan','Michael Cole','Mike Rome','Moreno','Moreno (Wyatt Sicks)','MyRISE 2K22 Female Player','MyRISE 2K22 Male Player','Odette Beaumont','Odyssey Rift','Original El Grande Americano','Paragon Jay Pearce','Psycho Sally','Red','Road Dogg','Shawn Bennett','Slade','Tavish','Tre','Victoria D’Ericco','Wade Barrett','Rezar','Brie Bella','Akam','Afa','Sika','Tama','Tonga Loa','Talla Tonga'
    ];
    final superstarIds = <String, int>{};
    for (final name in [...raw, ...extras].toSet()) {
      final existing = await db.query(tableSuperstars, columns: [SuperstarsFields.id],
          where: 'LOWER(${SuperstarsFields.name}) = LOWER(?)', whereArgs: [name], limit: 1);
      int id;
      if (existing.isNotEmpty) {
        id = existing.first[SuperstarsFields.id] as int;
      } else {
        // Tweener est une valeur neutre de repli : l'alignement exact n'est pas
        // documenté de façon stable pour chaque personnage et reste éditable.
        id = await db.insert(tableSuperstars, {
          SuperstarsFields.name: name,
          SuperstarsFields.brand: null,
          SuperstarsFields.orientation: 'Tweener',
          SuperstarsFields.division: null,
          SuperstarsFields.photoUrl: null,
        });
      }
      superstarIds[name] = id;
    }

    const titles = <String>[
      'Undisputed WWE Championship','World Heavyweight Championship','WWE Intercontinental Championship','WWE United States Championship','WWE Tag Team Championship','World Tag Team Championship','WWE Women’s Championship','Women’s World Championship','Women’s Intercontinental Championship','Women’s United States Championship','Women’s Tag Team Championship','NXT Championship','NXT North American Championship','NXT Tag Team Championship','NXT Women’s Championship','NXT Women’s North American Championship','WWE Crown Jewel Championship','AAA Mega Championship','AAA Reina De Reinas Championship',
      'WWE Championship ’14-’22','WWE Universal Championship ’20-’22 (SmackDown)','WWE Universal Championship ’16-’19 (Raw)','World Heavyweight Championship ’02-’13','WWE Championship ’13-’14','WWE Championship ’05-’13','WWE Undisputed Championship','WWE Championship ’98-’02','WWE Championship ’88-’98','WWF Championship (’87 - Andre)','WWWF Heavyweight Championship','Raw Women’s Championship','SmackDown Women’s Championship','WWE Divas Championship','WWE Women’s Championship ’98-’10','WWE Cruiserweight Championship ’01-’07','WWE Light Heavyweight Championship','WWE European Championship','WWE Hardcore Championship','WWE 24/7 Championship','Raw Tag Team Championship','SmackDown Tag Team Championship','WWE Tag Team Championship ’10-’16','WWE Tag Team Championship ’02-’10','World Tag Team Championship ’02-’10','World Tag Team Championship ’97-’02','WWE Intercontinental Championship ’11-’19','WWE Intercontinental Championship ’98-’11','WWE Intercontinental Championship ’94','WWE Intercontinental Championship ’90','WWE United States Championship ’03-’20','WWE U.S. Championship (Spinner - John Cena)','NXT Championship ’22-’24','NXT Championship ’17-’21','NXT Championship ’12-’17','NXT Tag Team Championship ’13-’17','NXT Women’s Championship ’22-’24','NXT Women’s Championship ’17-’21','NXT Women’s Championship ’13-’17','NXT Women’s Tag Team Championship','NXT Cruiserweight Championship','WWE United Kingdom Championship','NXT United Kingdom Championship','NXT UK Tag Team Championship','NXT UK Women’s Championship','Smoking Skull WWE Championship','Brahma Bull WWE Championship','Million Dollar Championship','The Fiend Universal Championship',
      'ECW Championship ’08-’10 (WWE)','ECW Championship ’06-’08 (WWE)','ECW World Championship ’94-’01','ECW World Television Championship','ECW World Tag Team Championship','WCW World Championship ’91-’93','WCW nWo World Championship','WCW nWo Legacy Championship','WCW United States Championship','WCW Hardcore Championship','WCW Cruiserweight Championship','WCW World Tag Team Championship','WCW World Tag Team Championship ’91-’96','WCW Women’s Championship',
      'UpUpDownDown Championship','LeftRightLeftRight Championship','PC Championship (Performance Center)','John Cena Legacy Championship','Multiverse Infinite Championship','Multiverse Infinite Cardboard Championship','NXT Mutiny Championship','NXT Mutiny Championship (Destroyed)','NXT Mutiny Tag Team Championship','NXT Mutiny Women’s Championship','NXT Mutiny Women’s Tag Team Championship','NXT Unity North American Championship','NXT Unity Tag Championship','Unify Tag Team Championship','TBD Championship','The People’s Championship','WrestleMania 39 X WWE Championship (Snoop Dogg)','Archetype WWE Universal Championship','Archetype Raw Women’s Championship','One v. One Championship','Two v. Two Championship','Money in the Bank (Men)','Money in the Bank (Women)'
    ];
    const tagTitleNames = <String>{'WWE Tag Team Championship','World Tag Team Championship','Women’s Tag Team Championship','NXT Tag Team Championship','Raw Tag Team Championship','SmackDown Tag Team Championship','WWE Tag Team Championship ’10-’16','WWE Tag Team Championship ’02-’10','World Tag Team Championship ’02-’10','World Tag Team Championship ’97-’02','NXT Tag Team Championship ’13-’17','NXT Women’s Tag Team Championship','NXT UK Tag Team Championship','ECW World Tag Team Championship','WCW World Tag Team Championship','WCW World Tag Team Championship ’91-’96','NXT Mutiny Tag Team Championship','NXT Mutiny Women’s Tag Team Championship','NXT Unity Tag Championship','Unify Tag Team Championship','Two v. Two Championship'};
    for (final name in titles) {
      final existing = await db.query(tableTitles, columns: [TitlesFields.id],
          where: 'LOWER(${TitlesFields.name}) = LOWER(?)', whereArgs: [name], limit: 1);
      if (existing.isNotEmpty) continue;
      final brandName = name.startsWith('NXT') ? 'NXT' : name.startsWith('AAA') ? 'AAA' :
          (name.contains('Raw') ? 'Raw' : name.contains('SmackDown') ? 'SmackDown' : null);
      await db.insert(tableTitles, {
        TitlesFields.name: name,
        TitlesFields.tag: tagTitleNames.contains(name) ? 1 : 0,
        TitlesFields.brand: brandName == null ? null : brandIds[brandName],
        TitlesFields.holder1: null,
        TitlesFields.holder2: null,
      });
    }

    // Équipes dont les deux membres figurent dans le roster ci-dessus.
    const teams = <String, List<String>>{
      'The Usos':['Jey Uso','Jimmy Uso'],
      'The New Day':['Kofi Kingston','Xavier Woods','Big E'],
      'The Street Profits':['Angelo Dawkins','Montez Ford'],
      'The Creed Brothers':['Brutus Creed','Julius Creed'],
      'Pretty Deadly':['Elton Prince','Kit Wilson'],
      'The Motor City Machine Guns':['Alex Shelley','Chris Sabin'],
      'The Dudley Boyz':['Bubba Ray Dudley','D-Von Dudley'],
      'The Hardy Boyz':['Jeff Hardy','Matt Hardy'],
      'The Outsiders':['Kevin Nash','Scott Hall'],
      'Demolition':['Ax','Smash'],
      'The Authors of Pain':['Akam','Rezar'],
      'The Wyatt Sicks':['Uncle Howdy','Erick Rowan','Dexter Lumis'],
      'The Bloodline':['Roman Reigns','Jey Uso','Jimmy Uso'],
      'The Kabuki Warriors':['Asuka','Kairi Sane'],
      'Damage CTRL':['Iyo Sky','Asuka','Kairi Sane'],
      'DIY':['Johnny Gargano','Tommaso Ciampa'],
      'The Viking Raiders':['Erik','Ivar'],
      'The Bella Twins':['Nikki Bella','Brie Bella'],
      'The Natural Disasters':['Earthquake','Typhoon'],
      'The Brothers of Destruction':['Undertaker','Kane'],
    };
    for (final entry in teams.entries) {
      final ids = entry.value.map((name) => superstarIds[name]).whereType<int>().toList();
      if (ids.length < 2) continue;
      final existing = await db.query(tableTeams, columns: [TeamsFields.id],
          where: 'LOWER(${TeamsFields.name}) = LOWER(?)', whereArgs: [entry.key], limit: 1);
      if (existing.isNotEmpty) continue;
      await db.insert(tableTeams, {
        TeamsFields.name: entry.key,
        TeamsFields.member1: ids[0], TeamsFields.member2: ids[1],
        TeamsFields.member3: ids.length > 2 ? ids[2] : null,
        TeamsFields.member4: ids.length > 3 ? ids[3] : null,
        TeamsFields.member5: ids.length > 4 ? ids[4] : null,
      });
    }
  }

  Future<void> _seedMatchCatalog(DatabaseExecutor db) async {
    final formatRows = <Map<String, Object?>>[];
    void addFormat(String name, String category, int count, int sideCount, List<int> perSide) {
      formatRows.add({MatchFormatsFields.name:name, MatchFormatsFields.description:null,
        MatchFormatsFields.category:category, MatchFormatsFields.participantCount:count,
        MatchFormatsFields.sideCount:sideCount, MatchFormatsFields.participantsPerSide:'[${perSide.join(',')}]',
        MatchFormatsFields.isActive:1});
    }
    for (final n in [2,3,4,5,6,8]) {
      addFormat(n==2?'One on One':n==3?'Triple Threat':n==4?'Fatal 4-Way':'$n-Way','individual',n,n,List<int>.filled(n,1));
    }
    addFormat('Two on Two','team',4,2,[2,2]);
    addFormat('Two on Two - Mixed Tag','team',4,2,[2,2]);
    addFormat('Two on Two - Tornado Tag','team',4,2,[2,2]);
    addFormat('Three on Three','team',6,2,[3,3]);
    addFormat('Three on Three - Tornado Tag','team',6,2,[3,3]);
    addFormat('Four on Four','team',8,2,[4,4]);
    addFormat('Triple Threat Tornado Tag','team',6,3,[2,2,2]);
    addFormat('4-Way Tornado Tag','team',8,4,[2,2,2,2]);
    addFormat('One on Two - Tag','handicap',3,2,[1,2]);
    addFormat('One on Two - Tornado Tag','handicap',3,2,[1,2]);
    addFormat('One on Three - Tag','handicap',4,2,[1,3]);
    addFormat('Two on Three - Tag','handicap',5,2,[2,3]);
    for(final n in [10,20,30]) { addFormat('Royal Rumble - $n-Man','royalRumble',n,0,[]); }
    for(final n in [4,5,6,8,10,20,30]) { addFormat('Gauntlet - $n Entrants','gauntlet',n,0,[]); }
    for(final n in [4,5,6,8]) { addFormat(n==4?'Battle Royal - Fatal 4-Way':'Battle Royal - $n-Way','battleRoyal',n,0,[]); }
    addFormat('Elimination Chamber - 6-Way','custom',6,0,[]);
    addFormat('WarGames - Three on Three','custom',6,2,[3,3]);
    addFormat('WarGames - Four on Four','custom',8,2,[4,4]);
    for(final row in formatRows) { await db.insert(tableMatchFormats,row,conflictAlgorithm:ConflictAlgorithm.ignore); }

    const names=['Normal','Extreme Rules','Falls Count Anywhere','Hell in a Cell','Steel Cage','Table Match','Ladder Match','TLC','Submission Match','Last Man Standing','No Holds Barred','Iron Man','Casket Match','Ambulance Match','I Quit','Inferno Match','Dumpster Match','3 Stages of Hell','Elimination Chamber','WarGames','Battle Royal','Royal Rumble','Underground','Bloodline Rules','Backstage Brawl','Gauntlet Match','Gauntlet Turmoil','Gauntlet Eliminator','Special Guest Referee','One on One Tournament','Tag Team Tournament','Dusty Rhodes Classic','Mixed Match Challenge'];
    for(final name in names) {
      await db.insert(tableMatchTypes,{MatchTypesFields.name:name,MatchTypesFields.description:null,MatchTypesFields.category:'standard',MatchTypesFields.isActive:1},conflictAlgorithm:ConflictAlgorithm.ignore);
    }
    final fRows=await db.query(tableMatchFormats,columns:[MatchFormatsFields.id,MatchFormatsFields.name]);
    final fIds=<String,int>{for(final r in fRows) r[MatchFormatsFields.name] as String:r[MatchFormatsFields.id] as int};
    final tRows=await db.query(tableMatchTypes,columns:[MatchTypesFields.id,MatchTypesFields.name]);
    final tIds=<String,int>{for(final r in tRows) r[MatchTypesFields.name] as String:r[MatchTypesFields.id] as int};
    const singles=['One on One','Triple Threat','Fatal 4-Way','5-Way','6-Way','8-Way'];
    const tag=['Two on Two','Two on Two - Mixed Tag','Two on Two - Tornado Tag','Three on Three','Three on Three - Tornado Tag','Four on Four','Triple Threat Tornado Tag','4-Way Tornado Tag'];
    const handicap=['One on Two - Tag','One on Two - Tornado Tag','One on Three - Tag','Two on Three - Tag'];
    for(final entry in tIds.entries) {
      List<String> compatible=[...singles,...tag,...handicap];
      if(entry.key=='Royal Rumble') compatible=['Royal Rumble - 10-Man','Royal Rumble - 20-Man','Royal Rumble - 30-Man'];
      if(entry.key.startsWith('Gauntlet')) compatible=[4,5,6,8,10,20,30].map((n)=>'Gauntlet - $n Entrants').toList();
      if(entry.key=='Battle Royal') compatible=['Battle Royal - Fatal 4-Way','Battle Royal - 5-Way','Battle Royal - 6-Way','Battle Royal - 8-Way'];
      if(entry.key=='Elimination Chamber') compatible=['Elimination Chamber - 6-Way'];
      if(entry.key=='WarGames') compatible=['WarGames - Three on Three','WarGames - Four on Four'];
      if(entry.key=='Special Guest Referee') compatible=singles;
      if(entry.key=='Backstage Brawl') compatible=['One on One','Triple Threat','Fatal 4-Way','6-Way','8-Way','Two on Two','One on Two - Tag'];
      if(entry.key=='3 Stages of Hell') compatible=['One on One'];
      if(entry.key.contains('Tournament') || entry.key=='Dusty Rhodes Classic' || entry.key=='Mixed Match Challenge') compatible=['One on One','Two on Two','Two on Two - Mixed Tag'];
      for(final formatName in compatible) {
        final formatId=fIds[formatName];
        if(formatId!=null) await db.insert(tableMatchTypeFormats,{MatchTypeFormatsFields.matchTypeId:entry.value,MatchTypeFormatsFields.matchFormatId:formatId},conflictAlgorithm:ConflictAlgorithm.ignore);
      }
    }
  }

}
