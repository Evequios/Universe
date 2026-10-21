import 'package:wwe_universe/classes/brands.dart';
import 'package:wwe_universe/database/brands_database_helper.dart';
import 'package:wwe_universe/database/superstars_database_helper.dart';

const String tableSuperstars = 'superstars';

class SuperstarsFields{
  static final List<String> values = [
    id, name, brand, orientation, ally1, ally2, ally3, ally4, ally5, rival1, rival2, rival3, rival4, rival5, division
  ];

  static const String id = '_id', 
    name = 'name', 
    brand = 'brand', 
    orientation = 'orientation', 
    ally1 = 'ally1', ally2 = 'ally2', ally3 = 'ally3', ally4 = 'ally4', ally5 = 'ally5', 
    rival1 = 'rival1', rival2 = 'rival2', rival3 = 'rival3', rival4 = 'rival4', rival5 = 'rival5', 
    division = 'division';
}

class Superstars{
  final int? id;
  final String name;
  final Brands? brand;
  final String orientation;
  final Superstars? ally1, ally2, ally3, ally4, ally5, rival1, rival2, rival3, rival4, rival5;
  final int? division;

  const Superstars({
    this.id,
    required this.name,
    this.brand,
    required this.orientation,
    this.ally1,
    this.ally2,
    this.ally3,
    this.ally4,
    this.ally5,
    this.rival1,
    this.rival2,
    this.rival3,
    this.rival4,
    this.rival5,
    this.division
  });

  Superstars copy({
    int? id,
    String? name,
    Brands? brand,
    String? orientation,
    Superstars? ally1,
    Superstars? ally2,
    Superstars? ally3,
    Superstars? ally4,
    Superstars? ally5,
    Superstars? rival1,
    Superstars? rival2,
    Superstars? rival3,
    Superstars? rival4,
    Superstars? rival5,
    int? division
  }) =>
      Superstars(
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
        rival5: rival5 ?? this.rival5,
        division: division ?? this.division,
      );

  static Future<Superstars> fromJson(Map<String, dynamic> json) async => Superstars(
        id: json[SuperstarsFields.id] as int?,
        name: json[SuperstarsFields.name] as String,
        brand: json[SuperstarsFields.brand] != null ? await BrandsDatabaseHelper.readBrand(json[SuperstarsFields.brand] as int) : null,
        orientation: json[SuperstarsFields.orientation] as String,
        ally1: json[SuperstarsFields.ally1] != null ? await SuperstarsDatabaseHelper.readSuperstar(json[SuperstarsFields.ally1] as int) : null,
        ally2: json[SuperstarsFields.ally2] != null ? await SuperstarsDatabaseHelper.readSuperstar(json[SuperstarsFields.ally2] as int) : null,
        ally3: json[SuperstarsFields.ally3] != null ? await SuperstarsDatabaseHelper.readSuperstar(json[SuperstarsFields.ally3] as int) : null,
        ally4: json[SuperstarsFields.ally4] != null ? await SuperstarsDatabaseHelper.readSuperstar(json[SuperstarsFields.ally4] as int) : null,
        ally5: json[SuperstarsFields.ally5] != null ? await SuperstarsDatabaseHelper.readSuperstar(json[SuperstarsFields.ally5] as int) : null,
        rival1: json[SuperstarsFields.rival1] != null ? await SuperstarsDatabaseHelper.readSuperstar(json[SuperstarsFields.rival1] as int) : null,
        rival2: json[SuperstarsFields.rival2] != null ? await SuperstarsDatabaseHelper.readSuperstar(json[SuperstarsFields.rival2] as int) : null,
        rival3: json[SuperstarsFields.rival3] != null ? await SuperstarsDatabaseHelper.readSuperstar(json[SuperstarsFields.rival3] as int) : null,
        rival4: json[SuperstarsFields.rival4] != null ? await SuperstarsDatabaseHelper.readSuperstar(json[SuperstarsFields.rival4] as int) : null,
        rival5: json[SuperstarsFields.rival5] != null ? await SuperstarsDatabaseHelper.readSuperstar(json[SuperstarsFields.rival5] as int) : null,
        division: json[SuperstarsFields.division] as int
      );

  Map<String, Object?> toJson() => {
        SuperstarsFields.id: id,
        SuperstarsFields.name : name,
        SuperstarsFields.brand: brand?.id,
        SuperstarsFields.orientation: orientation,
        SuperstarsFields.ally1: ally1?.id,
        SuperstarsFields.ally2: ally2?.id,
        SuperstarsFields.ally3: ally3?.id,
        SuperstarsFields.ally4: ally4?.id,
        SuperstarsFields.ally5: ally5?.id,
        SuperstarsFields.rival1: rival1?.id,
        SuperstarsFields.rival2: rival2?.id,
        SuperstarsFields.rival3: rival3?.id,
        SuperstarsFields.rival4: rival4?.id,
        SuperstarsFields.rival5: rival5?.id,
        SuperstarsFields.division: division
      };
}
