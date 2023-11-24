const String tableReigns = 'reigns';

class ReignsFields {
  static final List<String> values = [
    id, holder1, holder2, titleId, yearDebut, weekDebut, yearEnd, weekEnd
  ];

  static const String id = '_id';
  static const String holder1 = 'holder1';
  static const String holder2 = 'holder2';
  static const String titleId = 'titleId';
  static const String yearDebut = 'yearDebut';
  static const String weekDebut = 'weekDebut';
  static const String yearEnd = 'yearEnd';
  static const String weekEnd = 'weekEnd';
}

class UniverseReigns{
  final int? id;
  final int holder1;
  final int holder2;
  final int titleId;
  final int yearDebut;
  final int weekDebut;
  final int yearEnd;
  final int weekEnd;

  const UniverseReigns({
    this.id,
    required this.holder1,
    required this.holder2,
    required this.titleId,
    required this.yearDebut,
    required this.weekDebut,
    required this.yearEnd,
    required this.weekEnd
  });

  UniverseReigns copy({
    int? id,
    int? holder1,
    int? holder2,
    int? titleId,
    int? yearDebut,
    int? weekDebut,
    int? yearEnd,
    int? weekEnd
  }) =>
      UniverseReigns(
        id: id ?? this.id,
        holder1: holder1 ?? this.holder1,
        holder2: holder2 ?? this.holder2,
        titleId: titleId ?? this.titleId,
        yearDebut: yearDebut ?? this.yearDebut,
        weekDebut: weekDebut ?? this.weekDebut,
        yearEnd: yearEnd ?? this.yearEnd,
        weekEnd: weekEnd ?? this.weekEnd
      );

  static UniverseReigns fromJson(Map<String, dynamic> json) => UniverseReigns(
        id: json[ReignsFields.id]as int ?,
        holder1: json[ReignsFields.holder1] as int,
        holder2: json[ReignsFields.holder2] as int,
        titleId: json[ReignsFields.titleId] as int,
        yearDebut: json[ReignsFields.yearDebut] as int,
        weekDebut: json[ReignsFields.weekDebut] as int,
        yearEnd: json[ReignsFields.yearEnd] as int,
        weekEnd: json[ReignsFields.weekEnd] as int,
      );

  Map<String, dynamic> toJson() => {
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
