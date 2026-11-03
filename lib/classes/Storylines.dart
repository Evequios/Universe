const String tableStorylines = 'storylines';

class StorylinesFields {
  static const String id = '_id';
  static const String title = 'title';
  static const String text = 'text';
  static const String yearStart = 'yearStart';
  static const String yearEnd = 'yearEnd';
  static const String start = 'start';
  static const String end = 'end';
  static const String status = 'status';

  static const List<String> values = [
    id, title, text, yearStart, yearEnd, start, end, status
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
      case upcoming: return 'À venir';
      case ongoing: return 'En cours';
      case completed: return 'Terminée';
      case cancelled: return 'Annulée';
      default: return 'En cours';
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
  final String status;

  const Storylines({
    this.id,
    required this.title,
    required this.text,
    required this.yearStart,
    required this.yearEnd,
    required this.start,
    required this.end,
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
      StorylinesFields.status: status,
    };
  }
}
