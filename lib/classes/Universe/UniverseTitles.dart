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
class UniverseTitles{
  final int? id;
  final String name;
  final int tag;
  final int brand;
  final int holder1;
  final int holder2;

  const UniverseTitles({
    this.id,
    required this.name,
    required this.tag,
    required this.brand,
    required this.holder1,
    required this.holder2,
  });

   UniverseTitles copy ({
    int? id,
    String? name,
    int? tag,
    int? brand,
    int? holder1,
    int? holder2,
  }) =>
    UniverseTitles(
      id : id ?? this.id,
      name: name ?? this.name,
      tag: tag ?? this.tag,
      brand: brand ?? this.brand,
      holder1: holder1 ?? this.holder1,
      holder2: holder2 ?? this.holder2
    );

  static UniverseTitles fromJson(Map<String, dynamic> json) => UniverseTitles(
    id: json[TitlesFields.id] as int ?,
    name: json[TitlesFields.name] as String,
    tag: json[TitlesFields.tag] as int,
    brand: json[TitlesFields.brand] as int,
    holder1: json[TitlesFields.holder1] as int,
    holder2: json[TitlesFields.holder2] as int,
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
