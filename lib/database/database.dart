
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
      version: 80,
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

  Future<void> _updateDB(Database db, int oldVersion, int newVersion) async {
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
