import 'package:wwe_universe/classes/show.dart';
import 'package:wwe_universe/classes/stipulations.dart';
import 'package:wwe_universe/classes/superstars.dart';
import 'package:wwe_universe/classes/titles.dart';

const String tableMatches = 'matches';

class MatchesFields {
  static const String id = '_id', 
  stipulation = 'stipulation', 
  s1 = 's1', s2 = 's2', s3 = 's3', s4 = 's4', s5 = 's5', s6 = 's6', s7 = 's7';
  static const String s8 = 's8';
  static const String winner = 'winner';
  static const String matchOrder = 'matchOrder';
  static const String showId = 'showId';
  static const String titleId = 'titleId';

  static const List<String> values = [
    id, stipulation, s1, s2, s3, s4, s5, s6, s7, s8, winner, matchOrder, showId, titleId
  ];
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
  final Superstars? winner;
  final int matchOrder;
  final Show? show;
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
    this.winner,
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
    Show? show,
    Titles? title
  }) {
    return Matches(
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
  }

  Map<String, Object?> toJson() {
    return {
      MatchesFields.id: id,
      MatchesFields.stipulation: stipulation.id,
      MatchesFields.s1: s1.id,
      MatchesFields.s2: s2.id,
      MatchesFields.s3: s3?.id,
      MatchesFields.s4: s4?.id,
      MatchesFields.s5: s5?.id,
      MatchesFields.s6: s6?.id,
      MatchesFields.s7: s7?.id,
      MatchesFields.s8: s8?.id,
      MatchesFields.winner: winner?.id,
      MatchesFields.matchOrder: matchOrder,
      MatchesFields.showId: show?.id,
      MatchesFields.titleId : title?.id
    };
  }
} 
