class UniverseStorylines{
  final String id;
  final String titre;
  final String texte;
  final String debut;
  final String fin;

  const UniverseStorylines({
    required this.id,
    required this.titre,
    required this.texte,
    required this.debut,
    required this.fin
  });

  UniverseStorylines copy({
    String? id,
    String? titre,
    String? texte,
    String? debut,
    String? fin,
  }) =>
      UniverseStorylines(
        id: id ?? this.id,
        titre: titre ?? this.titre,
        texte: texte ?? this.texte,
        debut: debut ?? this.debut,
        fin: fin ?? this.fin,
      );

  static UniverseStorylines fromJson(Map<String, dynamic> json) => UniverseStorylines(
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
