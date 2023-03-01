class IRLShows{
  final String id;
  final String nom;
  final String date;
  final String resume;

  const IRLShows({
    required this.id,
    required this.nom,
    required this.date,
    required this.resume
  });

  IRLShows copy({
    String? id,
    String? nom,
    String? date,
    String? resume
  }) =>
      IRLShows(
        id: id ?? this.id,
        nom: nom ?? this.nom,
        date: date ?? this.date,
        resume: resume ?? this.resume
      );

  static IRLShows fromJson(Map<String, dynamic> json) => IRLShows(
        id: json['id'],
        nom: json['nom'],
        date: json['date'],
        resume: json ['resume'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nom': nom,
        'date': date,
        'resume': resume,
      };
}
