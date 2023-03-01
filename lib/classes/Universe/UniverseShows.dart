final String tableShows = 'shows';

class ShowFields{
  static final List<String> values = [
    id, nom, annee, semaine, resume
  ];

  static final String id = '_id';
  static final String nom = 'nom';
  static final String annee = 'annee';
  static final String semaine = 'semaine';
  static final String resume = 'resume';
}

class UniverseShows{
  final int? id;
  final String nom;
  final int annee;
  final int semaine;
  final String resume;

  const UniverseShows({
    this.id,
    required this.nom,
    required this.annee,
    required this.semaine,
    required this.resume
  });

  UniverseShows copy({
    int? id,
    String? nom,
    int? annee,
    int? semaine,
    String? resume
  }) =>
      UniverseShows(
        id: id ?? this.id,
        nom: nom ?? this.nom,
        annee: annee ?? this.annee,
        semaine: semaine ?? this.semaine,
        resume : resume ?? this.resume
      );

  static UniverseShows fromJson(Map<String, dynamic> json) => UniverseShows(
        id: json[ShowFields.id] as int ?,
        nom: json[ShowFields.nom] as String,
        annee: json[ShowFields.annee] as int,
        semaine: json[ShowFields.semaine] as int,
        resume: json[ShowFields.resume] as String,
      );

  Map<String, dynamic> toJson() => {
        ShowFields.id: id,
        ShowFields.nom: nom,
        ShowFields.annee: annee,
        ShowFields.semaine: semaine,
        ShowFields.resume: resume,
      };
}
