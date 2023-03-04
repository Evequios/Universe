const String tableNews = 'news';

class NewsFields {
  static final List<String> values = [
    id, title, text, createdTime, type
  ];

  static const String id = '_id';
  static const String title = 'title';
  static const String text = 'text';
  static const String createdTime = 'createdTime';
  static const String type = 'type';
}

class UniverseNews{
  final int? id;
  final String title;
  final String text;
  final DateTime createdTime;
  final String type;

  const UniverseNews({
    this.id,
    required this.title,
    required this.text,
    required this.createdTime,
    required this.type,
  });

  UniverseNews copy ({
    int? id,
    String? title,
    String? text,
    DateTime? createdTime,
    String? type
  }) =>
    UniverseNews(
      id : id ?? this.id,
      title: title ?? this.title,
      text: text ?? this.text,
      createdTime: createdTime ?? this.createdTime,
      type: type ?? this.type
    );

  static UniverseNews fromJson(Map<String, dynamic> json) => UniverseNews(
        id: json[NewsFields.id] as int ?,
        title: json[NewsFields.title] as String,
        text: json[NewsFields.text] as String, 
        createdTime: DateTime.parse(json[NewsFields.createdTime] as String),
        type: json[NewsFields.type] as String
      );

  Map<String, dynamic> toJson() => {
        NewsFields.id: id,
        NewsFields.title: title,
        NewsFields.text: text,
        NewsFields.createdTime: createdTime.toIso8601String(),
        NewsFields.type: type
      };
}
