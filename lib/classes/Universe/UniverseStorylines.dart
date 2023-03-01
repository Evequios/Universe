final String tableStorylines = 'storylines';

class StorylinesFields {
  static final List<String> values = [
    id, titre, texte, debut, fin
  ];

  static final String id = '_id';
  static final String titre = 'titre';
  static final String texte = 'texte';
  static final String debut = 'debut';
  static final String fin = 'fin';

}

class UniverseStorylines{
  final int? id;
  final String titre;
  final String texte;
  final String debut;
  final String fin;

  const UniverseStorylines({
    this.id,
    required this.titre,
    required this.texte,
    required this.debut,
    required this.fin
  });

  UniverseStorylines copy({
    int? id,
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
        id: json[StorylinesFields.id] as int ?,
        titre: json[StorylinesFields.titre] as String,
        texte: json[StorylinesFields.texte] as String,
        debut: json[StorylinesFields.debut] as String,
        fin: json[StorylinesFields.fin] as String,
      );

  Map<String, dynamic> toJson() => {
        StorylinesFields.id: id,
        StorylinesFields.titre: titre,
        StorylinesFields.texte: texte,
        StorylinesFields.debut: debut,
        StorylinesFields.fin: fin,
      };
}
