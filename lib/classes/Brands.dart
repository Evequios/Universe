const String tableBrands = 'brands';

class BrandsFields {
  static final List<String> values = [
    id, name
  ];

  static const String id = '_id';
  static const String name = 'name';
}

class Brands {
  final int? id;
  final String name;

  const Brands({
    this.id,
    required this.name
  });

  Brands copy ({
    int? id,
    String? name
  }) =>
    Brands(
      id : id ?? this.id,
      name : name ?? this.name
    );
  
  static Brands fromJson (Map<String, dynamic> json) => Brands(
    id : json[BrandsFields.id] as int ?,
    name : json[BrandsFields.name] as String
  );

  Map<String, dynamic> toJson() => {
    BrandsFields.id : id,
    BrandsFields.name : name,
  };
}