import 'package:wwe_universe/classes/superstars.dart';

const String tableReigns = 'reigns';

class ReignsFields {
  static const String id = '_id';
  static const String holder1 = 'holder1';
  static const String holder2 = 'holder2';
  static const String titleId = 'titleId';
  static const String yearDebut = 'yearDebut';
  static const String weekDebut = 'weekDebut';
  static const String yearEnd = 'yearEnd';
  static const String weekEnd = 'weekEnd';

  static final List<String> values = [
    id, holder1, holder2, titleId, yearDebut, weekDebut, yearEnd, weekEnd
  ];
}

class Reigns{
  final int? id;
  final Superstars holder1;
  final Superstars? holder2;
  final int titleId;
  final int yearDebut;
  final int weekDebut;
  final int? yearEnd;
  final int? weekEnd;

  const Reigns({
    this.id,
    required this.holder1,
    this.holder2,
    required this.titleId,
    required this.yearDebut,
    required this.weekDebut,
    this.yearEnd,
    this.weekEnd
  });

  Reigns copy({
    int? id,
    Superstars? holder1,
    Superstars? holder2,
    int? titleId,
    int? yearDebut,
    int? weekDebut,
    int? yearEnd,
    int? weekEnd
  }) {
    return Reigns(
        id: id ?? this.id,
        holder1: holder1 ?? this.holder1,
        holder2: holder2 ?? this.holder2,
        titleId: titleId ?? this.titleId,
        yearDebut: yearDebut ?? this.yearDebut,
        weekDebut: weekDebut ?? this.weekDebut,
        yearEnd: yearEnd ?? this.yearEnd,
        weekEnd: weekEnd ?? this.weekEnd
      );
    }

  Map<String, Object?> toJson() { 
    return {
        ReignsFields.id: id,
        ReignsFields.holder1: holder1,
        ReignsFields.holder2: holder2,
        ReignsFields.titleId: titleId,
        ReignsFields.yearDebut: yearDebut,
        ReignsFields.weekDebut: weekDebut,
        ReignsFields.yearEnd: yearEnd,
        ReignsFields.weekEnd: weekEnd
    };
  }
}
