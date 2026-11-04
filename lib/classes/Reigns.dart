const String tableReigns = 'reigns';
const String tableTitleReignEvents = 'title_reign_events';

class ReignsFields {
  static const String id = '_id';
  static const String titleId = 'titleId';
  static const String holder1Id = 'holder1Id';
  static const String holder1Name = 'holder1Name';
  static const String holder2Id = 'holder2Id';
  static const String holder2Name = 'holder2Name';
  static const String teamId = 'teamId';
  static const String teamName = 'teamName';
  static const String yearStart = 'yearStart';
  static const String weekStart = 'weekStart';
  static const String dayStart = 'dayStart';
  static const String yearEnd = 'yearEnd';
  static const String weekEnd = 'weekEnd';
  static const String dayEnd = 'dayEnd';
  static const String endReason = 'endReason';
  static const String startMatchId = 'startMatchId';
  static const String endMatchId = 'endMatchId';
}

class TitleReignEventFields {
  static const String id = '_id';
  static const String titleId = 'titleId';
  static const String eventType = 'eventType';
  static const String year = 'year';
  static const String week = 'week';
  static const String dayOfWeek = 'dayOfWeek';
  static const String matchOrder = 'matchOrder';
  static const String matchId = 'matchId';
  static const String holder1Id = 'holder1Id';
  static const String holder1Name = 'holder1Name';
  static const String holder2Id = 'holder2Id';
  static const String holder2Name = 'holder2Name';
  static const String teamId = 'teamId';
  static const String teamName = 'teamName';
}

class Reigns {
  final int? id;
  final int titleId;
  final int? holder1Id;
  final String holder1Name;
  final int? holder2Id;
  final String? holder2Name;
  final int? teamId;
  final String? teamName;
  final int yearStart;
  final int weekStart;
  final int dayStart;
  final int? yearEnd;
  final int? weekEnd;
  final int? dayEnd;
  final String? endReason;
  final int? startMatchId;
  final int? endMatchId;

  const Reigns({this.id, required this.titleId, this.holder1Id,
    required this.holder1Name, this.holder2Id, this.holder2Name,
    this.teamId, this.teamName, required this.yearStart, required this.weekStart, this.dayStart = 1, this.yearEnd,
    this.weekEnd, this.dayEnd, this.endReason, this.startMatchId, this.endMatchId});

  bool get isCurrent => yearEnd == null && weekEnd == null;

  factory Reigns.fromMap(Map<String, Object?> map) => Reigns(
    id: map[ReignsFields.id] as int?,
    titleId: map[ReignsFields.titleId] as int,
    holder1Id: map[ReignsFields.holder1Id] as int?,
    holder1Name: map[ReignsFields.holder1Name] as String,
    holder2Id: map[ReignsFields.holder2Id] as int?,
    holder2Name: map[ReignsFields.holder2Name] as String?,
    teamId: map[ReignsFields.teamId] as int?,
    teamName: map[ReignsFields.teamName] as String?,
    yearStart: map[ReignsFields.yearStart] as int,
    weekStart: map[ReignsFields.weekStart] as int,
    dayStart: (map[ReignsFields.dayStart] as int?) ?? 1,
    yearEnd: map[ReignsFields.yearEnd] as int?,
    weekEnd: map[ReignsFields.weekEnd] as int?,
    dayEnd: map[ReignsFields.dayEnd] as int?,
    endReason: map[ReignsFields.endReason] as String?,
    startMatchId: map[ReignsFields.startMatchId] as int?,
    endMatchId: map[ReignsFields.endMatchId] as int?,
  );
}
