
const String tableMatchParticipants = 'match_participants';

class MatchParticipantsFields {
  static const String id = '_id';
  static const String matchId = 'matchId';
  static const String sideId = 'sideId';
  static const String position = 'position';
  static const String superstarId = 'superstarId';
  static const String superstarName = 'superstarName';

  static const List<String> values = [
    id,
    matchId,
    sideId,
    position,
    superstarId,
    superstarName,
  ];
}

class MatchParticipants {
  final int? id;
  final int? matchId;
  final int? sideId;
  final int position;
  final int? superstarId;
  final String superstarName;

  const MatchParticipants({
    this.id,
    this.matchId,
    this.sideId,
    required this.position,
    this.superstarId,
    required this.superstarName,
  });

  MatchParticipants copy({
    int? id,
    int? matchId,
    int? sideId,
    int? position,
    int? superstarId,
    bool clearSuperstar = false,
    String? superstarName,
  }) {
    return MatchParticipants(
      id: id ?? this.id,
      matchId: matchId ?? this.matchId,
      sideId: sideId ?? this.sideId,
      position: position ?? this.position,
      superstarId:
          clearSuperstar ? null : superstarId ?? this.superstarId,
      superstarName: superstarName ?? this.superstarName,
    );
  }

  Map<String, Object?> toJson({
    int? assignedMatchId,
    int? assignedSideId,
  }) {
    return {
      MatchParticipantsFields.id: id,
      MatchParticipantsFields.matchId: assignedMatchId ?? matchId,
      MatchParticipantsFields.sideId: assignedSideId ?? sideId,
      MatchParticipantsFields.position: position,
      MatchParticipantsFields.superstarId: superstarId,
      MatchParticipantsFields.superstarName: superstarName,
    };
  }
}
