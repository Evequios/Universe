import 'package:cloud_firestore/cloud_firestore.dart';

class UniverseNews{
  final String? id;
  final String titre;
  final String texte;
  final Timestamp createdTime;
  final String categorie;

  const UniverseNews({
    this.id,
    required this.titre,
    required this.texte,
    required this.createdTime,
    required this.categorie,
  });

  static UniverseNews fromJson(Map<String, dynamic> json) => UniverseNews(
        id: json['id'],
        titre: json['titre'],
        texte: json['texte'],
        // createdTime: DateTime.parse(json['time']),
        createdTime: json['time'],
        categorie: json['categorie']
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'titre': titre,
        'texte': texte,
        // 'time': createdTime.toIso8601String(),
        'time': createdTime,
        'categorie': categorie
      };
}
