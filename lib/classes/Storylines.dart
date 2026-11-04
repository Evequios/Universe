const String tableStorylines = 'storylines';

class StorylinesFields {
  static const String id = '_id';
  static const String title = 'title';
  static const String text = 'text';
  static const String yearStart = 'yearStart';
  static const String yearEnd = 'yearEnd';
  static const String start = 'start';
  static const String end = 'end';
  static const String dayStart = 'dayStart';
  static const String dayEnd = 'dayEnd';
  static const String status = 'status';

  static const List<String> values = [
    id, title, text, yearStart, yearEnd, start, end, dayStart, dayEnd, status
  ];
}

class StorylineStatus {
  static const String upcoming = 'upcoming';
  static const String ongoing = 'ongoing';
  static const String completed = 'completed';
  static const String cancelled = 'cancelled';
  static const List<String> values = [upcoming, ongoing, completed, cancelled];

  static String label(String value) {
    switch (value) {
      case upcoming: return 'Upcoming';
      case ongoing: return 'Ongoing';
      case completed: return 'Completed';
      case cancelled: return 'Cancelled';
      default: return 'Ongoing';
    }
  }
}

class Storylines{
  final int? id;
  final String title;
  final String text;
  final int yearStart;
  final int yearEnd;
  final int start;
  final int end;
  final int dayStart;
  final int dayEnd;
  final String status;

  const Storylines({
    this.id,
    required this.title,
    required this.text,
    required this.yearStart,
    required this.yearEnd,
    required this.start,
    required this.end,
    this.dayStart = 1,
    this.dayEnd = 1,
    this.status = 'ongoing'
  });

  Storylines copy({
    int? id,
    String? title,
    String? text,
    int? yearStart,
    int? yearEnd,
    int? start,
    int? end,
    int? dayStart,
    int? dayEnd,
    String? status,
  }) {
    return Storylines(
      id: id ?? this.id,
      title: title ?? this.title,
      text: text ?? this.text,
      yearStart : yearStart ?? this.yearStart,
        yearEnd : yearEnd ?? this.yearEnd,
        start: start ?? this.start,
        end: end ?? this.end,
        dayStart: dayStart ?? this.dayStart,
        dayEnd: dayEnd ?? this.dayEnd,
        status: status ?? this.status,
      );
  }

  static Storylines fromJson(Map<String, dynamic> json) {
    return Storylines(
        id: json[StorylinesFields.id] as int ?,
        title: json[StorylinesFields.title] as String,
        text: json[StorylinesFields.text] as String,
        yearStart : json[StorylinesFields.yearStart] as int,
        yearEnd : json[StorylinesFields.yearEnd] as int,
        start: json[StorylinesFields.start] as int,
        end: json[StorylinesFields.end] as int,
        dayStart: json[StorylinesFields.dayStart] as int? ?? 1,
        dayEnd: json[StorylinesFields.dayEnd] as int? ?? 1,
        status: json[StorylinesFields.status] as String? ?? 'ongoing',
      );
  }

  Map<String, Object?> toJson() { 
    return {
      StorylinesFields.id: id,
      StorylinesFields.title: title,
      StorylinesFields.text: text,
      StorylinesFields.yearStart : yearStart,
      StorylinesFields.yearEnd : yearEnd,
      StorylinesFields.start: start,
      StorylinesFields.end: end,
      StorylinesFields.dayStart: dayStart,
      StorylinesFields.dayEnd: dayEnd,
      StorylinesFields.status: status,
    };
  }
}
