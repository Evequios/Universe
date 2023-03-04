const String tableBrands = 'brands';

class BrandsFields {
  static final List<String> values = [
    id, name
  ];

  static const String id = '_id';
  static const String name = 'name';
}

class UniverseBrands {
  final int? id;
  final String name;

  const UniverseBrands({
    this.id,
    required this.name
  });

  UniverseBrands copy ({
    int? id,
    String? name
  }) =>
    UniverseBrands(
      id : id ?? this.id,
      name : name ?? this.name
    );
  
  static UniverseBrands fromJson (Map<String, dynamic> json) => UniverseBrands(
    id : json[BrandsFields.id] as int ?,
    name : json[BrandsFields.name] as String
  );

  Map<String, dynamic> toJson() => {
    BrandsFields.id : id,
    BrandsFields.name : name,
  };
}