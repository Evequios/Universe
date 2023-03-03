final String tableSuperstars = 'superstars';

class SuperstarsFields{
  static final List<String> values = [
    id, nom, brand, orientation
  ];

  static final String id = '_id';
  static final String nom = 'nom';
  static final String brand = 'brand';
  static final String orientation = 'orientation';
}

class UniverseSuperstars{
  final int? id;
  final String nom;
  final int brand;
  final String orientation;

  const UniverseSuperstars({
    this.id,
    required this.nom,
    required this.brand,
    required this.orientation
  });

  UniverseSuperstars copy({
    int? id,
    String? nom,
    int? brand,
    String? orientation
  }) =>
      UniverseSuperstars(
        id: id ?? this.id,
        nom: nom ?? this.nom,
        brand: brand ?? this.brand,
        orientation: orientation ?? this.orientation,
      );

  static UniverseSuperstars fromJson(Map<String, dynamic> json) => UniverseSuperstars(
        id: json[SuperstarsFields.id] as int ?,
        nom: json[SuperstarsFields.nom] as String,
        brand: json[SuperstarsFields.brand] as int,
        orientation: json[SuperstarsFields.orientation] as String,
      );

  Map<String, Object?> toJson() => {
        SuperstarsFields.id: id,
        SuperstarsFields.nom : nom,
        SuperstarsFields.brand: brand,
        SuperstarsFields.orientation: orientation,
      };
}
