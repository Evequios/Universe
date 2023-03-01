final String tableMatches = 'matches';

class MatchesFields {
  static final List<String> values = [
    id, stipulation, s1, s2, s3, s4, s5, s6, s7, s8, gagnant, ordre, showId
  ];

  static final String id = '_id';
  static final String stipulation = 'stipulation';
  static final String s1 = 's1';
  static final String s2= 's2';
  static final String s3= 's3';
  static final String s4= 's4';
  static final String s5= 's5';
  static final String s6= 's6';
  static final String s7= 's7';
  static final String s8= 's8';
  static final String gagnant= 'gagnant';
  static final String ordre= 'ordre';
  static final String showId= 'showId';
}

class UniverseMatches{
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
  final int gagnant;
  final int ordre;
  final int? showId;

  const UniverseMatches({
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
    required this.gagnant,
    required this.ordre,
    required this.showId
  });

  UniverseMatches copy({
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
    int? gagnant,
    int? ordre,
    int? showId
  }) =>
      UniverseMatches(
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
        gagnant: gagnant ?? this.gagnant,
        ordre: ordre ?? this.ordre,
        showId: showId ?? this.showId
      );

  static UniverseMatches fromJson(Map<String, dynamic> json) => UniverseMatches(
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
        gagnant: json[MatchesFields.gagnant] as int,
        ordre: json[MatchesFields.ordre] as int,
        showId: json[MatchesFields.showId] as int,
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
        MatchesFields.gagnant: gagnant,
        MatchesFields.ordre : ordre,
        MatchesFields.showId: showId
      };
}
