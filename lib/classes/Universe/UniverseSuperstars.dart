const String tableSuperstars = 'superstars';

class SuperstarsFields{
  static final List<String> values = [
    id, nom, brand, orientation, rival1
  ];

  static const String id = '_id';
  static const String nom = 'nom';
  static const String brand = 'brand';
  static const String orientation = 'orientation';
  static const String rival1 = 'rival1';
}

class UniverseSuperstars{
  final int? id;
  final String nom;
  final int brand;
  final String orientation;
  final int rival1;

  const UniverseSuperstars({
    this.id,
    required this.nom,
    required this.brand,
    required this.orientation,
    required this.rival1
  });

  UniverseSuperstars copy({
    int? id,
    String? nom,
    int? brand,
    String? orientation,
    int? rival1
  }) =>
      UniverseSuperstars(
        id: id ?? this.id,
        nom: nom ?? this.nom,
        brand: brand ?? this.brand,
        orientation: orientation ?? this.orientation,
        rival1: rival1 ?? this.rival1
      );

  static UniverseSuperstars fromJson(Map<String, dynamic> json) => UniverseSuperstars(
        id: json[SuperstarsFields.id] as int ?,
        nom: json[SuperstarsFields.nom] as String,
        brand: json[SuperstarsFields.brand] as int,
        orientation: json[SuperstarsFields.orientation] as String,
        rival1: json[SuperstarsFields.rival1] as int
      );

  Map<String, Object?> toJson() => {
        SuperstarsFields.id: id,
        SuperstarsFields.nom : nom,
        SuperstarsFields.brand: brand,
        SuperstarsFields.orientation: orientation,
        SuperstarsFields.rival1: rival1
      };
}
