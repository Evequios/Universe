import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wwe_universe/classes/IRL/IRLStipulations.dart';

class IRLMatches{
  final String id;
  final String stipulation;
  final String s1;
  final String s2;
  final String s3;
  final String s4;
  final String s5;
  final String s6;
  final String s7;
  final String s8;
  final String s9;
  final String s10;
  final String gagnant;
  final String ordre;
  final String showId;

  const IRLMatches({
    required this.id,
    required this.stipulation,
    required this.s1,
    required this.s2,
    required this.s3,
    required this.s4,
    required this.s5,
    required this.s6,
    required this.s7,
    required this.s8,
    required this.s9,
    required this.s10,
    required this.gagnant,
    required this.ordre,
    required this.showId
  });

  IRLMatches copy({
    String? id,
    String? stipulation,
    String? s1,
    String? s2,
    String? s3,
    String? s4,
    String? s5,
    String? s6,
    String? s7,
    String? s8,
    String? s9,
    String? s10,
    String? gagnant,
    String? ordre,
    String? showId
  }) =>
      IRLMatches(
        id: id ?? this.id,
        stipulation: stipulation ?? this.stipulation,
        s1: s1 ?? this.s1,
        s2: s1 ?? this.s2,
        s3: s1 ?? this.s3,
        s4: s1 ?? this.s4,
        s5: s1 ?? this.s5,
        s6: s1 ?? this.s6,
        s7: s1 ?? this.s7,
        s8: s1 ?? this.s8,
        s9: s1 ?? this.s9,
        s10: s1 ?? this.s10,
        gagnant: gagnant ?? this.gagnant,
        ordre: ordre ?? this.ordre,
        showId: showId ?? this.showId
      );

  static IRLMatches fromJson(Map<String, dynamic> json) => IRLMatches(
        id: json['id'],
        stipulation: json['stipulation'],
        s1: json['s1'],
        s2: json['s2'],
        s3: json['s3'],
        s4: json['s4'],
        s5: json['s5'],
        s6: json['s6'],
        s7: json['s7'],
        s8: json['s8'],
        s9: json['s9'],
        s10: json['s10'],
        gagnant: json['gagnant'],
        ordre: json['ordre'].toString(),
        showId: json['showId'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'stipulation': stipulation,
        's1': s1,
        's2': s2,
        's3': s3,
        's4': s4,
        's5': s5,
        's6': s6,
        's7': s7,
        's8': s8,
        's9': s9,
        's10': s10,
        'gagnant': gagnant,
        'ordre' : int.parse(ordre),
        'showId': showId
      };
}
