
import 'dart:convert';

import 'package:wwe_universe/classes/match_formats.dart';
import 'package:wwe_universe/classes/match_types.dart';
import 'package:wwe_universe/classes/match_sides.dart';
import 'package:wwe_universe/classes/match_participants.dart';
import 'package:wwe_universe/classes/stipulations.dart';
import 'package:wwe_universe/classes/show.dart';
import 'package:wwe_universe/classes/titles.dart';

const String tableMatches = 'matches';

class MatchRecordFields {
  static const String id = '_id';
  static const String formatId = 'formatId';
  static const String formatName = 'formatName';
  static const String formatCategory = 'formatCategory';
  static const String formatParticipantCount = 'formatParticipantCount';
  static const String formatSideCount = 'formatSideCount';
  static const String formatParticipantsPerSide = 'formatParticipantsPerSide';
  static const String matchTypeId = 'matchTypeId';
  static const String matchTypeName = 'matchTypeName';
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
    formatCategory,
    formatParticipantCount,
    formatSideCount,
    formatParticipantsPerSide,
    matchTypeId,
    matchTypeName,
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

  // Snapshot du format au moment de la création du combat.
  final String? formatCategory;
  final int? formatParticipantCount;
  final int? formatSideCount;
  final List<int>? formatParticipantsPerSide;

  final MatchTypes? matchType;
  final String matchTypeName;

  // Champs transitoires conservés pour compatibilité.
  final Stipulations? stipulation;
  final String stipulationName;

  final List<MatchSides> sides;
  final List<MatchParticipants> specialParticipants;

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
    this.formatCategory,
    this.formatParticipantCount,
    this.formatSideCount,
    this.formatParticipantsPerSide,
    this.matchType,
    this.matchTypeName = '',
    this.stipulation,
    this.stipulationName = '',
    this.sides = const [],
    this.specialParticipants = const [],
    this.resultStatus = MatchResultStatus.pending,
    this.winnerSideOrder,
    this.winnerSuperstarId,
    required this.matchOrder,
    required this.show,
    this.title,
    this.winnerName,
  });

  List<MatchParticipants> get allParticipants => [
        ...sides.expand((side) => side.participants),
        ...specialParticipants,
      ];

  // Ces getters permettent également de gérer les combats antérieurs
  // à la migration, ou ceux dont le format avait déjà été supprimé.

  String get snapshotCategory {
    if (formatCategory != null) return formatCategory!;
    if (format != null) return format!.category;

    if (sides.isEmpty) return 'special';

    if (sides.every((side) => side.participants.length <= 1)) {
      return 'individual';
    }

    return 'team';
  }

  int get snapshotParticipantCount {
    return formatParticipantCount ??
        format?.participantCount ??
        allParticipants.length;
  }

  int get snapshotSideCount {
    return formatSideCount ?? format?.sideCount ?? sides.length;
  }

  List<int> get snapshotParticipantsPerSide {
    if (formatParticipantsPerSide != null) {
      return formatParticipantsPerSide!;
    }

    if (format != null) {
      return format!.participantsPerSide;
    }

    final orderedSides = List<MatchSides>.from(sides)
      ..sort((a, b) => a.sideOrder.compareTo(b.sideOrder));

    return orderedSides
        .map((side) => side.participants.length)
        .toList();
  }

  bool get snapshotUsesSides => snapshotSideCount > 0;

  MatchRecord copy({
    int? id,
    MatchFormats? format,
    bool clearFormat = false,
    String? formatName,
    String? formatCategory,
    int? formatParticipantCount,
    int? formatSideCount,
    List<int>? formatParticipantsPerSide,
    MatchTypes? matchType,
    bool clearMatchType = false,
    String? matchTypeName,
    Stipulations? stipulation,
    bool clearStipulation = false,
    String? stipulationName,
    List<MatchSides>? sides,
    List<MatchParticipants>? specialParticipants,
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
  }) =>
      MatchRecord(
        id: id ?? this.id,
        format: clearFormat ? null : format ?? this.format,
        formatName: formatName ?? this.formatName,
        formatCategory: formatCategory ?? this.formatCategory,
        formatParticipantCount:
            formatParticipantCount ?? this.formatParticipantCount,
        formatSideCount: formatSideCount ?? this.formatSideCount,
        formatParticipantsPerSide:
            formatParticipantsPerSide ?? this.formatParticipantsPerSide,
        matchType: clearMatchType ? null : matchType ?? this.matchType,
        matchTypeName: matchTypeName ?? this.matchTypeName,
        stipulation: clearStipulation ? null : stipulation ?? this.stipulation,
        stipulationName: stipulationName ?? this.stipulationName,
        sides: sides ?? this.sides,
        specialParticipants: specialParticipants ?? this.specialParticipants,
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

  Map<String, Object?> toJson() => {
        MatchRecordFields.id: id,
        MatchRecordFields.formatId: format?.id,
        MatchRecordFields.formatName: formatName,
        MatchRecordFields.formatCategory: snapshotCategory,
        MatchRecordFields.formatParticipantCount: snapshotParticipantCount,
        MatchRecordFields.formatSideCount: snapshotSideCount,
        MatchRecordFields.formatParticipantsPerSide:
            jsonEncode(snapshotParticipantsPerSide),
        MatchRecordFields.matchTypeId: matchType?.id,
        MatchRecordFields.matchTypeName: matchTypeName,
        MatchRecordFields.stipulationId: stipulation?.id,
        MatchRecordFields.stipulationName: stipulationName,
        MatchRecordFields.resultStatus: resultStatus,
        MatchRecordFields.winnerSideOrder: winnerSideOrder,
        MatchRecordFields.winnerSuperstarId: winnerSuperstarId,
        MatchRecordFields.matchOrder: matchOrder,
        MatchRecordFields.showId: show.id,
        MatchRecordFields.titleId: title?.id,
        MatchRecordFields.winnerName: winnerName,
      };
}
