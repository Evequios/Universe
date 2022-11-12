class IRLSuperstarsFields {
  static final List<String> values = [
    /// Add all fields
    id, prenom, nom, show, orientation
  ];

  static final String id = '_id';
  static final String prenom = 'prenom';
  static final String nom = 'nom';
  static final String show = 'show';
  static final String orientation = 'orientation';
}

class IRLSuperstars{
  final String id;
  final String prenom;
  final String nom;
  final String show;
  final String orientation;

  const IRLSuperstars({
    required this.id,
    required this.prenom,
    required this.nom,
    required this.show,
    required this.orientation,
  });

  IRLSuperstars copy({
    String? id,
    String? prenom,
    String? nom,
    String? show,
    String? orientation
  }) =>
      IRLSuperstars(
        id: id ?? this.id,
        prenom: prenom ?? this.prenom,
        nom: nom ?? this.nom,
        show: show ?? this.show,
        orientation: orientation ?? this.orientation,
      );

  static IRLSuperstars fromJson(Map<String, dynamic> json) => IRLSuperstars(
        id: json['id'],
        nom: json['nom'],
        prenom: json['prenom'],
        show: json['show'],
        orientation: json['orientation'],
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'prenom': prenom,
        'nom': nom,
        'show': show,
        'orientation': orientation,
      };
}
