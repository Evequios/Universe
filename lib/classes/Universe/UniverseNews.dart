final String tableNews = 'news';

class NewsFields {
  static final List<String> values = [
    id, titre, texte, createdTime, categorie
  ];

  static final String id = '_id';
  static final String titre = 'titre';
  static final String texte = 'texte';
  static final String createdTime = 'createdTime';
  static final String categorie = 'categorie';
}

class UniverseNews{
  final int? id;
  final String titre;
  final String texte;
  final DateTime createdTime;
  final String categorie;

  const UniverseNews({
    this.id,
    required this.titre,
    required this.texte,
    required this.createdTime,
    required this.categorie,
  });

  UniverseNews copy ({
    int? id,
    String? titre,
    String? texte,
    DateTime? createdTime,
    String? categorie
  }) =>
    UniverseNews(
      id : id ?? this.id,
      titre: titre ?? this.titre,
      texte: texte ?? this.texte,
      createdTime: createdTime ?? this.createdTime,
      categorie: categorie ?? this.categorie
    );

  static UniverseNews fromJson(Map<String, dynamic> json) => UniverseNews(
        id: json[NewsFields.id] as int ?,
        titre: json[NewsFields.titre] as String,
        texte: json[NewsFields.texte] as String, 
        // createdTime: DateTime.parse(json['time']),
        createdTime: DateTime.parse(json[NewsFields.createdTime] as String),
        categorie: json[NewsFields.categorie] as String
      );

  Map<String, dynamic> toJson() => {
        NewsFields.id: id,
        NewsFields.titre: titre,
        NewsFields.texte: texte,
        // 'time': createdTime.toIso8601String(),
        NewsFields.createdTime: createdTime.toIso8601String(),
        NewsFields.categorie: categorie
      };
}
