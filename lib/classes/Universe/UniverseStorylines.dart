const String tableStorylines = 'storylines';

class StorylinesFields {
  static final List<String> values = [
    id, title, text, yearStart, yearEnd, start, end
  ];

  static const String id = '_id';
  static const String title = 'title';
  static const String text = 'text';
  static const String yearStart = 'yearStart';
  static const String yearEnd = 'yearEnd';
  static const String start = 'start';
  static const String end = 'end';

}

class UniverseStorylines{
  final int? id;
  final String title;
  final String text;
  final int yearStart;
  final int yearEnd;
  final int start;
  final int end;

  const UniverseStorylines({
    this.id,
    required this.title,
    required this.text,
    required this.yearStart,
    required this.yearEnd,
    required this.start,
    required this.end
  });

  UniverseStorylines copy({
    int? id,
    String? title,
    String? text,
    int? yearStart,
    int? yearEnd,
    int? start,
    int? end,
  }) =>
      UniverseStorylines(
        id: id ?? this.id,
        title: title ?? this.title,
        text: text ?? this.text,
        yearStart : yearStart ?? this.yearStart,
        yearEnd : yearEnd ?? this.yearEnd,
        start: start ?? this.start,
        end: end ?? this.end,
      );

  static UniverseStorylines fromJson(Map<String, dynamic> json) => UniverseStorylines(
        id: json[StorylinesFields.id] as int ?,
        title: json[StorylinesFields.title] as String,
        text: json[StorylinesFields.text] as String,
        yearStart : json[StorylinesFields.yearStart] as int,
        yearEnd : json[StorylinesFields.yearEnd] as int,
        start: json[StorylinesFields.start] as int,
        end: json[StorylinesFields.end] as int,
      );

  Map<String, dynamic> toJson() => {
        StorylinesFields.id: id,
        StorylinesFields.title: title,
        StorylinesFields.text: text,
        StorylinesFields.yearStart : yearStart,
        StorylinesFields.yearEnd : yearEnd,
        StorylinesFields.start: start,
        StorylinesFields.end: end,
      };
}
