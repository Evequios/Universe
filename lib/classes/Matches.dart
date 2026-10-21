import 'package:wwe_universe/classes/shows.dart';
import 'package:wwe_universe/classes/stipulations.dart';
import 'package:wwe_universe/classes/superstars.dart';
import 'package:wwe_universe/classes/titles.dart';

const String tableMatches = 'matches';

class MatchesFields {
  static final List<String> values = [
    id, stipulation, s1, s2, s3, s4, s5, s6, s7, s8, winner, matchOrder, showId, titleId
  ];

  static const String id = '_id', 
  stipulation = 'stipulation', 
  s1 = 's1', s2 = 's2', s3 = 's3', s4 = 's4', s5 = 's5', s6 = 's6', s7 = 's7';
  static const String s8 = 's8';
  static const String winner = 'winner';
  static const String matchOrder = 'matchOrder';
  static const String showId = 'showId';
  static const String titleId = 'titleId';
}

class Matches{
  final int? id;
  final Stipulations stipulation;
  final Superstars s1;
  final Superstars s2;
  final Superstars? s3;
  final Superstars? s4;
  final Superstars? s5;
  final Superstars? s6;
  final Superstars? s7;
  final Superstars? s8;
  final Superstars winner;
  final int matchOrder;
  final Shows? show;
  final Titles? title;

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
    required this.show,
    required this.title,
  });

  Matches copy({
    int? id,
    Stipulations? stipulation,
    Superstars? s1,
    Superstars? s2,
    Superstars? s3,
    Superstars? s4,
    Superstars? s5,
    Superstars? s6,
    Superstars? s7,
    Superstars? s8,
    Superstars? winner,
    int? matchOrder,
    Shows? show,
    Titles? title
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
        show: show ?? this.show,
        title: title ?? this.title
      );

  static Matches fromJson(Map<String, dynamic> json) => Matches(
        id: json[MatchesFields.id]as int ?,
        stipulation: json[MatchesFields.stipulation] as Stipulations,
        s1: json[MatchesFields.s1] as Superstars,
        s2: json[MatchesFields.s2] as Superstars,
        s3: json[MatchesFields.s3] as Superstars,
        s4: json[MatchesFields.s4] as Superstars,
        s5: json[MatchesFields.s5] as Superstars,
        s6: json[MatchesFields.s6] as Superstars,
        s7: json[MatchesFields.s7] as Superstars,
        s8: json[MatchesFields.s8] as Superstars,
        winner: json[MatchesFields.winner] as Superstars,
        matchOrder: json[MatchesFields.matchOrder] as int,
        show: json[MatchesFields.showId] as Shows,
        title: json[MatchesFields.titleId] as Titles,
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
        MatchesFields.showId: show,
        MatchesFields.titleId : title
      };
}
