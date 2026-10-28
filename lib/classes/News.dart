const String tableNews = 'news';

class NewsFields {
  static const String id = '_id';
  static const String title = 'title';
  static const String text = 'text';
  static const String createdTime = 'createdTime';
  static const String type = 'type';

  static const List<String> values = [
    id, title, text, createdTime, type
  ];
}

class News{
  final int? id;
  final String title;
  final String text;
  final DateTime createdTime;
  final String type;

  const News({
    this.id,
    required this.title,
    required this.text,
    required this.createdTime,
    required this.type,
  });

  News copy ({
    int? id,
    String? title,
    String? text,
    DateTime? createdTime,
    String? type
  }) {
    return News(
      id : id ?? this.id,
      title: title ?? this.title,
      text: text ?? this.text,
      createdTime: createdTime ?? this.createdTime,
      type: type ?? this.type
    );
  }

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
        id: json[NewsFields.id] as int?,
        title: json[NewsFields.title] as String,
        text: json[NewsFields.text] as String, 
        createdTime: DateTime.parse(json[NewsFields.createdTime] as String),
        type: json[NewsFields.type] as String
      );
  }

  Map<String, Object?> toJson() {
    return {
        NewsFields.id: id,
        NewsFields.title: title,
        NewsFields.text: text,
        NewsFields.createdTime: createdTime.toIso8601String(),
        NewsFields.type: type
    };
  }
}
