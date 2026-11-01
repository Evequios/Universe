import 'dart:convert';
const String tableMatchFormats = 'match_formats';
class MatchFormatsFields {
  static const id = '_id', name = 'name', description = 'description', category = 'category', participantCount = 'participantCount', sideCount = 'sideCount', participantsPerSide = 'participantsPerSide', isActive = 'isActive';
}
class MatchFormats {
  final int? id;
  final String name;
  final String? description;
  final String category;
  final int participantCount;
  final int sideCount;
  final List<int> participantsPerSide;
  final bool isActive;
  const MatchFormats({this.id, required this.name, this.description, this.category='individual', this.participantCount=2, this.sideCount=2, this.participantsPerSide=const [1,1], this.isActive=true});
  bool get usesSides => sideCount > 0;
  bool get isSpecial => !usesSides;
  MatchFormats copy({int? id, String? name, String? description, String? category, int? participantCount, int? sideCount, List<int>? participantsPerSide, bool? isActive}) => MatchFormats(
    id:id ?? this.id, name:name ?? this.name, description:description ?? this.description, category:category ?? this.category,
    participantCount:participantCount ?? this.participantCount, sideCount:sideCount ?? this.sideCount,
    participantsPerSide:participantsPerSide ?? this.participantsPerSide, isActive:isActive ?? this.isActive);
  factory MatchFormats.fromJson(Map<String,Object?> j) {
    final raw = j[MatchFormatsFields.participantsPerSide] as String?;
    final sides = raw == null || raw.isEmpty ? const [1,1] : (jsonDecode(raw) as List).map((e)=>e as int).toList();
    return MatchFormats(id:j[MatchFormatsFields.id] as int?, name:j[MatchFormatsFields.name] as String,
      description:j[MatchFormatsFields.description] as String?, category:j[MatchFormatsFields.category] as String? ?? 'individual',
      participantCount:j[MatchFormatsFields.participantCount] as int? ?? 2, sideCount:j[MatchFormatsFields.sideCount] as int? ?? 2,
      participantsPerSide:sides, isActive:(j[MatchFormatsFields.isActive] as int? ?? 1)==1);
  }
  Map<String,Object?> toJson() => {MatchFormatsFields.id:id, MatchFormatsFields.name:name, MatchFormatsFields.description:description,
    MatchFormatsFields.category:category, MatchFormatsFields.participantCount:participantCount, MatchFormatsFields.sideCount:sideCount,
    MatchFormatsFields.participantsPerSide:jsonEncode(participantsPerSide), MatchFormatsFields.isActive:isActive ? 1 : 0};
}
