import 'package:wwe_universe/classes/brands.dart';
import 'package:wwe_universe/classes/superstars.dart';

const String tableTitles = 'titles';

class TitlesFields {
  static final List<String> values = [
    id, name, tag, brand, holder1, holder2
  ];

  static const String id = '_id';
  static const String name = 'name';
  static const String tag = 'tag';
  static const String brand = 'brand';
  static const String holder1 = 'holder1';
  static const String holder2 = 'holder2';
}
class Titles{
  final int? id;
  final String name;
  final int tag;
  final Brands? brand;
  final Superstars? holder1;
  final Superstars? holder2;

  const Titles({
    this.id,
    required this.name,
    required this.tag,
    required this.brand,
    required this.holder1,
    required this.holder2,
  });

   Titles copy ({
    int? id,
    String? name,
    int? tag,
    Brands? brand,
    Superstars? holder1,
    Superstars? holder2,
  }) =>
    Titles(
      id : id ?? this.id,
      name: name ?? this.name,
      tag: tag ?? this.tag,
      brand: brand ?? this.brand,
      holder1: holder1 ?? this.holder1,
      holder2: holder2 ?? this.holder2
    );

  static Titles fromJson(Map<String, dynamic> json) => Titles(
    id: json[TitlesFields.id] as int ?,
    name: json[TitlesFields.name] as String,
    tag: json[TitlesFields.tag] as int,
    brand: json[TitlesFields.brand] as Brands,
    holder1: json[TitlesFields.holder1] as Superstars,
    holder2: json[TitlesFields.holder2] as Superstars,
  );

  Map<String, dynamic> toJson() => {
    TitlesFields.id: id,
    TitlesFields.name: name,
    TitlesFields.tag: tag,
    TitlesFields.brand: brand,
    TitlesFields.holder1: holder1,
    TitlesFields.holder2: holder2
  };
}
