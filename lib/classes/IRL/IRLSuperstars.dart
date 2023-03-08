class IRLSuperstars{
  final String id;
  final String prenom;
  final String nom;
  final String show;
  final String orientation;
  final String titre;

  const IRLSuperstars({
    required this.id,
    required this.prenom,
    required this.nom,
    required this.show,
    required this.orientation,
    required this.titre
  });

  IRLSuperstars copy({
    String? id,
    String? prenom,
    String? nom,
    String? show,
    String? orientation,
    String? titre
  }) =>
      IRLSuperstars(
        id: id ?? this.id,
        prenom: prenom ?? this.prenom,
        nom: nom ?? this.nom,
        show: show ?? this.show,
        orientation: orientation ?? this.orientation,
        titre: titre ?? this.titre,
      );

  static IRLSuperstars fromJson(Map<String, dynamic> json) => IRLSuperstars(
        id: json['id'],
        nom: json['nom'],
        prenom: json['prenom'],
        show: json['show'],
        orientation: json['orientation'],
        titre: json['titre'],
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'prenom': prenom,
        'nom': nom,
        'show': show,
        'orientation': orientation,
        'titre': titre,
      };
}
