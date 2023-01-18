import 'package:wwe_universe/classes/Universe/UniverseShows.dart';

class UniverseSuperstars{
  final String id;
  final String prenom;
  final String nom;
  final String show;
  final String orientation;
  final String titre;

  const UniverseSuperstars({
    required this.id,
    required this.prenom,
    required this.nom,
    required this.show,
    required this.orientation,
    required this.titre
  });

  UniverseSuperstars copy({
    String? id,
    String? prenom,
    String? nom,
    String? show,
    String? orientation,
    String? titre
  }) =>
      UniverseSuperstars(
        id: id ?? this.id,
        prenom: prenom ?? this.prenom,
        nom: nom ?? this.nom,
        show: show ?? this.show,
        orientation: orientation ?? this.orientation,
        titre: titre ?? this.titre,
      );

  static UniverseSuperstars fromJson(Map<String, dynamic> json) => UniverseSuperstars(
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
