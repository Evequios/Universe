const String tableMatchTypes = 'match_types';
class MatchTypesFields {
  static const id = '_id', name = 'name', description = 'description', category = 'category', isActive = 'isActive';
}
class MatchTypes {
  final int? id;
  final String name;
  final String? description;
  final String category;
  final bool isActive;
  const MatchTypes({this.id, required this.name, this.description, this.category = 'standard', this.isActive = true});
  factory MatchTypes.fromJson(Map<String, Object?> j) => MatchTypes(
    id: j[MatchTypesFields.id] as int?, name: j[MatchTypesFields.name] as String,
    description: j[MatchTypesFields.description] as String?, category: j[MatchTypesFields.category] as String? ?? 'standard',
    isActive: (j[MatchTypesFields.isActive] as int? ?? 1) == 1);
  Map<String, Object?> toJson() => {MatchTypesFields.id:id, MatchTypesFields.name:name, MatchTypesFields.description:description, MatchTypesFields.category:category, MatchTypesFields.isActive:isActive ? 1 : 0};
  MatchTypes copy({int? id, String? name, String? description, String? category, bool? isActive}) => MatchTypes(
    id:id ?? this.id, name:name ?? this.name, description:description ?? this.description,
    category:category ?? this.category, isActive:isActive ?? this.isActive);
}
