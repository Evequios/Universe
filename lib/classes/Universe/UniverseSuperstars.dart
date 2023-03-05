const String tableSuperstars = 'superstars';

class SuperstarsFields{
  static final List<String> values = [
    id, name, brand, orientation, ally1, ally2, ally3, ally4, ally5, rival1, rival2, rival3, rival4, rival5
  ];

  static const String id = '_id';
  static const String name = 'name';
  static const String brand = 'brand';
  static const String orientation = 'orientation';
  static const String ally1 = 'ally1';
  static const String ally2 = 'ally2';
  static const String ally3 = 'ally3';
  static const String ally4 = 'ally4';
  static const String ally5 = 'ally5';
  static const String rival1 = 'rival1';
  static const String rival2 = 'rival2';
  static const String rival3 = 'rival3';
  static const String rival4 = 'rival4';
  static const String rival5 = 'rival5';
}

class UniverseSuperstars{
  final int? id;
  final String name;
  final int brand;
  final String orientation;
  final int ally1, ally2, ally3, ally4, ally5, rival1, rival2, rival3, rival4, rival5;

  const UniverseSuperstars({
    this.id,
    required this.name,
    required this.brand,
    required this.orientation,
    required this.ally1,
    required this.ally2,
    required this.ally3,
    required this.ally4,
    required this.ally5,
    required this.rival1,
    required this.rival2,
    required this.rival3,
    required this.rival4,
    required this.rival5
  });

  UniverseSuperstars copy({
    int? id,
    String? name,
    int? brand,
    String? orientation,
    int? ally1,
    int? ally2,
    int? ally3,
    int? ally4,
    int? ally5,
    int? rival1,
    int? rival2,
    int? rival3,
    int? rival4,
    int? rival5
  }) =>
      UniverseSuperstars(
        id: id ?? this.id,
        name: name ?? this.name,
        brand: brand ?? this.brand,
        orientation: orientation ?? this.orientation,
        ally1: ally1 ?? this.ally1,
        ally2: ally2 ?? this.ally2,
        ally3: ally3 ?? this.ally3,
        ally4: ally4 ?? this.ally4,
        ally5: ally5 ?? this.ally5,
        rival1: rival1 ?? this.rival1,
        rival2: rival2 ?? this.rival2,
        rival3: rival3 ?? this.rival3,
        rival4: rival4 ?? this.rival4,
        rival5: rival5 ?? this.rival5
      );

  static UniverseSuperstars fromJson(Map<String, dynamic> json) => UniverseSuperstars(
        id: json[SuperstarsFields.id] as int ?,
        name: json[SuperstarsFields.name] as String,
        brand: json[SuperstarsFields.brand] as int,
        orientation: json[SuperstarsFields.orientation] as String,
        ally1: json[SuperstarsFields.ally1] as int,
        ally2: json[SuperstarsFields.ally2] as int,
        ally3: json[SuperstarsFields.ally3] as int,
        ally4: json[SuperstarsFields.ally4] as int,
        ally5: json[SuperstarsFields.ally5] as int,
        rival1: json[SuperstarsFields.rival1] as int,
        rival2: json[SuperstarsFields.rival2] as int,
        rival3: json[SuperstarsFields.rival3] as int,
        rival4: json[SuperstarsFields.rival4] as int,
        rival5: json[SuperstarsFields.rival5] as int
      );

  Map<String, Object?> toJson() => {
        SuperstarsFields.id: id,
        SuperstarsFields.name : name,
        SuperstarsFields.brand: brand,
        SuperstarsFields.orientation: orientation,
        SuperstarsFields.ally1: ally1,
        SuperstarsFields.ally2: ally2,
        SuperstarsFields.ally3: ally3,
        SuperstarsFields.ally4: ally4,
        SuperstarsFields.ally5: ally5,
        SuperstarsFields.rival1: rival1,
        SuperstarsFields.rival2: rival2,
        SuperstarsFields.rival3: rival3,
        SuperstarsFields.rival4: rival4,
        SuperstarsFields.rival5: rival5
      };
}
