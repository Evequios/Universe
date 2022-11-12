class IRLStorylinesFields {
  static final List<String> values = [
    /// Add all fields
    id, titre, texte, debut, fin
  ];

  static final String id = '_id';
  static final String titre = 'titre';
  static final String texte = 'texte';
  static final String debut = 'debut';
  static final String fin = 'fin';
}

class IRLStorylines{
  final String id;
  final String titre;
  final String texte;
  final String debut;
  final String fin;

  const IRLStorylines({
    required this.id,
    required this.titre,
    required this.texte,
    required this.debut,
    required this.fin
  });

  IRLStorylines copy({
    String? id,
    String? titre,
    String? texte,
    String? debut,
    String? fin,
  }) =>
      IRLStorylines(
        id: id ?? this.id,
        titre: titre ?? this.titre,
        texte: texte ?? this.texte,
        debut: debut ?? this.debut,
        fin: fin ?? this.fin,
      );

  static IRLStorylines fromJson(Map<String, dynamic> json) => IRLStorylines(
        id: json['id'],
        titre: json['titre'],
        texte: json['texte'],
        debut: json['debut'],
        fin: json['fin'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'titre': titre,
        'texte': texte,
        'debut': debut,
        'fin': fin,
      };
}
