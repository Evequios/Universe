
import 'package:wwe_universe/classes/match_participants.dart';

const String tableMatchSides = 'match_sides';

class MatchSidesFields {
  static const String id = '_id';
  static const String matchId = 'matchId';
  static const String sideOrder = 'sideOrder';
  static const String name = 'name';
  static const String teamId = 'teamId';

  static const List<String> values = [
    id,
    matchId,
    sideOrder,
    name,
    teamId,
  ];
}

class MatchSides {
  final int? id;
  final int? matchId;
  final int sideOrder;
  final String name;
  final int? teamId;
  final List<MatchParticipants> participants;

  const MatchSides({
    this.id,
    this.matchId,
    required this.sideOrder,
    required this.name,
    this.teamId,
    this.participants = const [],
  });

  MatchSides copy({
    int? id,
    int? matchId,
    int? sideOrder,
    String? name,
    int? teamId,
    bool clearTeam = false,
    List<MatchParticipants>? participants,
  }) {
    return MatchSides(
      id: id ?? this.id,
      matchId: matchId ?? this.matchId,
      sideOrder: sideOrder ?? this.sideOrder,
      name: name ?? this.name,
      teamId: clearTeam ? null : teamId ?? this.teamId,
      participants: participants ?? this.participants,
    );
  }

  Map<String, Object?> toJson() {
    return {
      MatchSidesFields.id: id,
      MatchSidesFields.matchId: matchId,
      MatchSidesFields.sideOrder: sideOrder,
      MatchSidesFields.name: name,
      MatchSidesFields.teamId: teamId,
    };
  }
}
