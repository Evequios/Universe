
import 'package:wwe_universe/classes/match_formats.dart';
import 'package:wwe_universe/classes/match_sides.dart';
import 'package:wwe_universe/classes/stipulations.dart';
import 'package:wwe_universe/classes/show.dart';
import 'package:wwe_universe/classes/titles.dart';

const String tableMatches = 'matches';

class MatchRecordFields {
  static const String id = '_id';
  static const String formatId = 'formatId';
  static const String formatName = 'formatName';
  static const String stipulationId = 'stipulationId';
  static const String stipulationName = 'stipulationName';
  static const String resultStatus = 'resultStatus';
  static const String winnerSideOrder = 'winnerSideOrder';
  static const String winnerSuperstarId = 'winnerSuperstarId';
  static const String matchOrder = 'matchOrder';
  static const String showId = 'showId';
  static const String titleId = 'titleId';
  static const String winnerName = 'winnerName';

  static const List<String> values = [
    id,
    formatId,
    formatName,
    stipulationId,
    stipulationName,
    resultStatus,
    winnerSideOrder,
    winnerSuperstarId,
    winnerName,
    matchOrder,
    showId,
    titleId,
  ];
}

class MatchResultStatus {
  static const String pending = 'pending';
  static const String winner = 'winner';
  static const String draw = 'draw';
  static const String noContest = 'noContest';

  static const List<String> values = [
    pending,
    winner,
    draw,
    noContest,
  ];
}

class MatchRecord {
  final int? id;
  final MatchFormats? format;
  final String formatName;
  final Stipulations? stipulation;
  final String stipulationName;
  final List<MatchSides> sides;
  final String resultStatus;
  final int? winnerSideOrder;
  final int? winnerSuperstarId;
  final int matchOrder;
  final Show show;
  final Titles? title;
  final String? winnerName;

  const MatchRecord({
    this.id,
    this.format,
    required this.formatName,
    this.stipulation,
    required this.stipulationName,
    this.sides = const [],
    this.resultStatus = MatchResultStatus.pending,
    this.winnerSideOrder,
    this.winnerSuperstarId,
    required this.matchOrder,
    required this.show,
    this.title,
    this.winnerName,
  });

  MatchRecord copy({
    int? id,
    MatchFormats? format,
    bool clearFormat = false,
    String? formatName,
    Stipulations? stipulation,
    bool clearStipulation = false,
    String? stipulationName,
    List<MatchSides>? sides,
    String? resultStatus,
    int? winnerSideOrder,
    bool clearWinnerSide = false,
    int? winnerSuperstarId,
    bool clearWinnerSuperstar = false,
    int? matchOrder,
    Show? show,
    Titles? title,
    bool clearTitle = false,
    String? winnerName,
    bool clearWinnerName = false,
  }) {
    return MatchRecord(
      id: id ?? this.id,
      format: clearFormat ? null : format ?? this.format,
      formatName: formatName ?? this.formatName,
      stipulation:
          clearStipulation ? null : stipulation ?? this.stipulation,
      stipulationName: stipulationName ?? this.stipulationName,
      sides: sides ?? this.sides,
      resultStatus: resultStatus ?? this.resultStatus,
      winnerSideOrder:
          clearWinnerSide ? null : winnerSideOrder ?? this.winnerSideOrder,
      winnerSuperstarId: clearWinnerSuperstar
          ? null
          : winnerSuperstarId ?? this.winnerSuperstarId,
      matchOrder: matchOrder ?? this.matchOrder,
      show: show ?? this.show,
      title: clearTitle ? null : title ?? this.title,
      winnerName: clearWinnerName ? null : winnerName ?? this.winnerName,
    );
  }

  Map<String, Object?> toJson() {
    return {
      MatchRecordFields.id: id,
      MatchRecordFields.formatId: format?.id,
      MatchRecordFields.formatName: formatName,
      MatchRecordFields.stipulationId: stipulation?.id,
      MatchRecordFields.stipulationName: stipulationName,
      MatchRecordFields.resultStatus: resultStatus,
      MatchRecordFields.winnerSideOrder: winnerSideOrder,
      MatchRecordFields.winnerSuperstarId: winnerSuperstarId,
      MatchRecordFields.matchOrder: matchOrder,
      MatchRecordFields.showId: show.id,
      MatchRecordFields.titleId: title?.id,
      MatchRecordFields.winnerName: winnerName
    };
  }
}
