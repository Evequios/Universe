
const String tableMatchFormats = 'match_formats';

class MatchFormatsFields {
  static const String id = '_id';
  static const String name = 'name';
  static const String description = 'description';

  static const List<String> values = [
    id,
    name,
    description,
  ];
}

class MatchFormats {
  final int? id;
  final String name;
  final String? description;

  const MatchFormats({
    this.id,
    required this.name,
    this.description,
  });

  MatchFormats copy({
    int? id,
    String? name,
    String? description,
  }) {
    return MatchFormats(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }

  factory MatchFormats.fromJson(Map<String, dynamic> json) {
    return MatchFormats(
      id: json[MatchFormatsFields.id] as int?,
      name: json[MatchFormatsFields.name] as String,
      description: json[MatchFormatsFields.description] as String?,
    );
  }

  Map<String, Object?> toJson() {
    return {
      MatchFormatsFields.id: id,
      MatchFormatsFields.name: name,
      MatchFormatsFields.description: description,
    };
  }
}
