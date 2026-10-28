
const String tableBrands = 'brands';

class BrandsFields {
  static const List<String> values = [
    id,
    name,
  ];

  static const String id = '_id';
  static const String name = 'name';
}

class Brands {
  final int? id;
  final String name;

  const Brands({
    this.id,
    required this.name,
  });

  Brands copy({
    int? id,
    String? name,
  }) {
    return Brands(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  factory Brands.fromJson(Map<String, dynamic> json) {
    return Brands(
      id: json[BrandsFields.id] as int?,
      name: json[BrandsFields.name] as String,
    );
  }

  Map<String, Object?> toJson() {
    return {
      BrandsFields.id: id,
      BrandsFields.name: name,
    };
  }
}
