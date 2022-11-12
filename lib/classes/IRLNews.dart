import 'package:cloud_firestore/cloud_firestore.dart';

class IRLNewsFields {
  static final List<String> values = [
    /// Add all fields
    id, titre, texte, time, categorie
  ];

  static final String id = '_id';
  static final String titre = 'titre';
  static final String texte = 'texte';
  static final String time = 'time';
  static final String categorie = 'categorie';
}

class IRLNews{
  final String? id;
  final String titre;
  final String texte;
  final Timestamp createdTime;
  final String categorie;

  const IRLNews({
    this.id,
    required this.titre,
    required this.texte,
    required this.createdTime,
    required this.categorie,
  });

  static IRLNews fromJson(Map<String, dynamic> json) => IRLNews(
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
