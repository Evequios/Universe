const String tableBrands = 'brands';

class BrandsFields {
  static final List<String> values = [
    id, nom
  ];

  static const String id = '_id';
  static const String nom = 'nom';
}

class UniverseBrands {
  final int? id;
  final String nom;

  const UniverseBrands({
    this.id,
    required this.nom
  });

  UniverseBrands copy ({
    int? id,
    String? nom
  }) =>
    UniverseBrands(
      id : id ?? this.id,
      nom : nom ?? this.nom
    );
  
  static UniverseBrands fromJson (Map<String, dynamic> json) => UniverseBrands(
    id : json[BrandsFields.id] as int ?,
    nom : json[BrandsFields.nom] as String
  );

  Map<String, dynamic> toJson() => {
    BrandsFields.id : id,
    BrandsFields.nom : nom,
  };
}