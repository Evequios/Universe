import 'package:wwe_universe/classes/brands.dart';

const String tableSuperstars = 'superstars';

class SuperstarsFields{
  static const String id = '_id', 
    name = 'name', 
    brand = 'brand', 
    orientation = 'orientation', 
    division = 'division';
  
  static const List<String> values = [
    id, name, brand, orientation, division
  ];
}

class Superstars{
  final int? id;
  final String name;
  final Brands? brand;
  final String orientation;
  final int? division;

  const Superstars({
    this.id,
    required this.name,
    this.brand,
    required this.orientation,
    this.division
  });

  Superstars copy({
    int? id,
    String? name,
    Brands? brand,
    String? orientation,
    int? division
  }) {
    return Superstars(
        id: id ?? this.id,
        name: name ?? this.name,
        brand: brand ?? this.brand,
        orientation: orientation ?? this.orientation,
        division: division ?? this.division,
      );
  }

  // static Future<Superstars> fromJson(Map<String, dynamic> json) async => Superstars(
  //       id: json[SuperstarsFields.id] as int?,
  //       name: json[SuperstarsFields.name] as String,
  //       brand: json[SuperstarsFields.brand] != null ? await BrandsDatabaseHelper.readBrand(json[SuperstarsFields.brand] as int) : null,
  //       orientation: json[SuperstarsFields.orientation] as String,
  //       division: json[SuperstarsFields.division] as int
  //     );

  Map<String, Object?> toJson() => {
        SuperstarsFields.id: id,
        SuperstarsFields.name : name,
        SuperstarsFields.brand: brand?.id,
        SuperstarsFields.orientation: orientation,
        SuperstarsFields.division: division
      };
}
