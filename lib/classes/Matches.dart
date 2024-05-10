const String tableMatches = 'matches';

class MatchesFields {
  static final List<String> values = [
    id, stipulation, s1, s2, s3, s4, s5, s6, s7, s8, winner, matchOrder, showId, titleId
  ];

  static const String id = '_id';
  static const String stipulation = 'stipulation';
  static const String s1 = 's1';
  static const String s2 = 's2';
  static const String s3 = 's3';
  static const String s4 = 's4';
  static const String s5 = 's5';
  static const String s6 = 's6';
  static const String s7 = 's7';
  static const String s8 = 's8';
  static const String winner = 'winner';
  static const String matchOrder = 'matchOrder';
  static const String showId = 'showId';
  static const String titleId = 'titleId';
}

class Matches{
  final int? id;
  final int stipulation;
  final int s1;
  final int s2;
  final int s3;
  final int s4;
  final int s5;
  final int s6;
  final int s7;
  final int s8;
  final int winner;
  final int matchOrder;
  final int? showId;
  final int? titleId;

  const Matches({
    this.id,
    required this.stipulation,
    required this.s1,
    required this.s2,
    required this.s3,
    required this.s4,
    required this.s5,
    required this.s6,
    required this.s7,
    required this.s8,
    required this.winner,
    required this.matchOrder,
    required this.showId,
    required this.titleId,
  });

  Matches copy({
    int? id,
    int? stipulation,
    int? s1,
    int? s2,
    int? s3,
    int? s4,
    int? s5,
    int? s6,
    int? s7,
    int? s8,
    int? winner,
    int? matchOrder,
    int? showId,
    int? titleId
  }) =>
      Matches(
        id: id ?? this.id,
        stipulation: stipulation ?? this.stipulation,
        s1: s1 ?? this.s1,
        s2: s2 ?? this.s2,
        s3: s3 ?? this.s3,
        s4: s4 ?? this.s4,
        s5: s5 ?? this.s5,
        s6: s6 ?? this.s6,
        s7: s7 ?? this.s7,
        s8: s8 ?? this.s8,
        winner: winner ?? this.winner,
        matchOrder: matchOrder ?? this.matchOrder,
        showId: showId ?? this.showId,
        titleId: titleId ?? this.titleId
      );

  static Matches fromJson(Map<String, dynamic> json) => Matches(
        id: json[MatchesFields.id]as int ?,
        stipulation: json[MatchesFields.stipulation] as int,
        s1: json[MatchesFields.s1] as int,
        s2: json[MatchesFields.s2] as int,
        s3: json[MatchesFields.s3] as int,
        s4: json[MatchesFields.s4] as int,
        s5: json[MatchesFields.s5] as int,
        s6: json[MatchesFields.s6] as int,
        s7: json[MatchesFields.s7] as int,
        s8: json[MatchesFields.s8] as int,
        winner: json[MatchesFields.winner] as int,
        matchOrder: json[MatchesFields.matchOrder] as int,
        showId: json[MatchesFields.showId] as int,
        titleId: json[MatchesFields.titleId] as int,
      );

  Map<String, dynamic> toJson() => {
        MatchesFields.id: id,
        MatchesFields.stipulation: stipulation,
        MatchesFields.s1: s1,
        MatchesFields.s2: s2,
        MatchesFields.s3: s3,
        MatchesFields.s4: s4,
        MatchesFields.s5: s5,
        MatchesFields.s6: s6,
        MatchesFields.s7: s7,
        MatchesFields.s8: s8,
        MatchesFields.winner: winner,
        MatchesFields.matchOrder: matchOrder,
        MatchesFields.showId: showId,
        MatchesFields.titleId : titleId
      };
}
