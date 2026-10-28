import 'package:wwe_universe/classes/brands.dart';
import 'package:wwe_universe/classes/superstars.dart';

const String tableTitles = 'titles';

class TitlesFields {
  static const String id = '_id';
  static const String name = 'name';
  static const String tag = 'tag';
  static const String brand = 'brand';
  static const String holder1 = 'holder1';
  static const String holder2 = 'holder2';

  static const List<String> values = [
    id, name, tag, brand, holder1, holder2
  ];
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
  }) {
    return Titles(
      id : id ?? this.id,
      name: name ?? this.name,
      tag: tag ?? this.tag,
      brand: brand ?? this.brand,
      holder1: holder1 ?? this.holder1,
      holder2: holder2 ?? this.holder2
    );
  }

  Map<String, dynamic> toJson() => {
    TitlesFields.id: id,
    TitlesFields.name: name,
    TitlesFields.tag: tag,
    TitlesFields.brand: brand?.id,
    TitlesFields.holder1: holder1?.id,
    TitlesFields.holder2: holder2?.id,
  };
}
