const String tableStorylineEvents = 'storyline_events';

class StorylineEventFields {
  static const String id = '_id';
  static const String storylineId = 'storyline_id';
  static const String type = 'event_type';
  static const String title = 'title';
  static const String description = 'description';
  static const String year = 'year';
  static const String week = 'week';
  static const String dayOfWeek = 'day_of_week';
  static const String position = 'position';
  static const String matchId = 'match_id';
  static const String newsId = 'news_id';
}

class StorylineEventType {
  static const String segment = 'segment';
  static const String match = 'match';
  static const String news = 'news';
  static String label(String value) {
    switch (value) {
      case match: return 'Match';
      case news: return 'Actualité';
      default: return 'Segment';
    }
  }
}

class StorylineEvent {
  final int? id;
  final int storylineId;
  final String type;
  final String title;
  final String description;
  final int year;
  final int week;
  final int dayOfWeek;
  final int position;
  final int? matchId;
  final int? newsId;

  const StorylineEvent({this.id, required this.storylineId, this.type = StorylineEventType.segment,
    required this.title, this.description = '', required this.year, required this.week,
    this.dayOfWeek = 1, this.position = 0, this.matchId, this.newsId});

  factory StorylineEvent.fromJson(Map<String, Object?> json) => StorylineEvent(
    id: json[StorylineEventFields.id] as int?,
    storylineId: json[StorylineEventFields.storylineId] as int,
    type: json[StorylineEventFields.type] as String? ?? StorylineEventType.segment,
    title: json[StorylineEventFields.title] as String,
    description: json[StorylineEventFields.description] as String? ?? '',
    year: json[StorylineEventFields.year] as int,
    week: json[StorylineEventFields.week] as int,
    dayOfWeek: json[StorylineEventFields.dayOfWeek] as int? ?? 1,
    position: json[StorylineEventFields.position] as int? ?? 0,
    matchId: json[StorylineEventFields.matchId] as int?,
    newsId: json[StorylineEventFields.newsId] as int?,
  );

  Map<String, Object?> toJson() => {
    StorylineEventFields.id: id,
    StorylineEventFields.storylineId: storylineId,
    StorylineEventFields.type: type,
    StorylineEventFields.title: title,
    StorylineEventFields.description: description,
    StorylineEventFields.year: year,
    StorylineEventFields.week: week,
    StorylineEventFields.dayOfWeek: dayOfWeek,
    StorylineEventFields.position: position,
    StorylineEventFields.matchId: matchId,
    StorylineEventFields.newsId: newsId,
  };
}
