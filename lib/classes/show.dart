const String tableShows = 'shows';

class ShowFields{
  static const String id = '_id';
  static const String name = 'name';
  static const String year = 'year';
  static const String week = 'week';
  static const String dayOfWeek = 'dayOfWeek';
  static const String summary = 'summary';
  static const String isCompleted = 'isCompleted';

  static const List<String> values = [
    id, name, year, week, dayOfWeek, summary, isCompleted
  ];
}

class Show{
  final int? id;
  final String name;
  final int year;
  final int week;
  final int dayOfWeek;
  final String summary;
  final bool isCompleted;

  const Show({
    this.id,
    required this.name,
    required this.year,
    required this.week,
    required this.dayOfWeek,
    required this.summary,
    this.isCompleted = false,
  });

  // Returns the month of the show based on the week number
  int get month => (week - 1) ~/ 4 + 1;

  // Returns the week of the month based on the week number
  int get weekofMonth => (week - 1) % 4 + 1;

  Show copy({
    int? id,
    String? name,
    int? year,
    int? week,
    int? dayOfWeek,
    String? summary,
    bool? isCompleted,
  }) {
    return Show(
      id: id ?? this.id,
      name: name ?? this.name,
      year: year ?? this.year,
      week: week ?? this.week,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      summary: summary ?? this.summary,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  factory Show.fromJson(Map<String, dynamic> json) {
    return Show(
      id: json[ShowFields.id] as int?,
      name: json[ShowFields.name] as String,
      year: json[ShowFields.year] as int,
      week: json[ShowFields.week] as int,
      dayOfWeek: json[ShowFields.dayOfWeek] as int,
      summary: json[ShowFields.summary] as String,
      isCompleted: (json[ShowFields.isCompleted] as int? ?? 0) == 1,
    );
  }

  Map<String, Object?> toJson() {
    return {
      ShowFields.id: id,
      ShowFields.name: name,
      ShowFields.year: year,
      ShowFields.week: week,
      ShowFields.dayOfWeek: dayOfWeek,
      ShowFields.summary: summary,
      ShowFields.isCompleted: isCompleted ? 1 : 0,
    };
  }
}
