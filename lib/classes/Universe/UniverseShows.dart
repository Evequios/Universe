const String tableShows = 'shows';

class ShowFields{
  static final List<String> values = [
    id, name, year, week, summary
  ];

  static const String id = '_id';
  static const String name = 'name';
  static const String year = 'year';
  static const String week = 'week';
  static const String summary = 'summary';
}

class UniverseShows{
  final int? id;
  final String name;
  final int year;
  final int week;
  final String summary;

  const UniverseShows({
    this.id,
    required this.name,
    required this.year,
    required this.week,
    required this.summary
  });

  UniverseShows copy({
    int? id,
    String? name,
    int? year,
    int? week,
    String? summary
  }) =>
      UniverseShows(
        id: id ?? this.id,
        name: name ?? this.name,
        year: year ?? this.year,
        week: week ?? this.week,
        summary : summary ?? this.summary
      );

  static UniverseShows fromJson(Map<String, dynamic> json) => UniverseShows(
        id: json[ShowFields.id] as int ?,
        name: json[ShowFields.name] as String,
        year: json[ShowFields.year] as int,
        week: json[ShowFields.week] as int,
        summary: json[ShowFields.summary] as String,
      );

  Map<String, dynamic> toJson() => {
        ShowFields.id: id,
        ShowFields.name: name,
        ShowFields.year: year,
        ShowFields.week: week,
        ShowFields.summary: summary,
      };
}
