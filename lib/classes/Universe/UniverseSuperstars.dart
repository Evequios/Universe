final String tableSuperstars = 'superstars';

class SuperstarsFields{
  static final List<String> values = [
    id, nom, show, orientation
  ];

  static final String id = '_id';
  static final String nom = 'nom';
  static final String show = 'show';
  static final String orientation = 'orientation';
}

class UniverseSuperstars{
  final int? id;
  final String nom;
  final String show;
  final String orientation;

  const UniverseSuperstars({
    this.id,
    required this.nom,
    required this.show,
    required this.orientation
  });

  UniverseSuperstars copy({
    int? id,
    String? nom,
    String? show,
    String? orientation
  }) =>
      UniverseSuperstars(
        id: id ?? this.id,
        nom: nom ?? this.nom,
        show: show ?? this.show,
        orientation: orientation ?? this.orientation,
      );

  static UniverseSuperstars fromJson(Map<String, dynamic> json) => UniverseSuperstars(
        id: json[SuperstarsFields.id] as int ?,
        nom: json[SuperstarsFields.nom] as String,
        show: json[SuperstarsFields.show] as String,
        orientation: json[SuperstarsFields.orientation] as String,
      );

  Map<String, Object?> toJson() => {
        SuperstarsFields.id: id,
        SuperstarsFields.nom : nom,
        SuperstarsFields.show: show,
        SuperstarsFields.orientation: orientation,
      };
}
