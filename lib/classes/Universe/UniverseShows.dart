class UniverseShows{
  final String id;
  final String nom;
  final String date;

  const UniverseShows({
    required this.id,
    required this.nom,
    required this.date
  });

  UniverseShows copy({
    String? id,
    String? nom,
    String? date,
  }) =>
      UniverseShows(
        id: id ?? this.id,
        nom: nom ?? this.nom,
        date: date ?? this.date,
      );

  static UniverseShows fromJson(Map<String, dynamic> json) => UniverseShows(
        id: json['id'],
        nom: json['nom'],
        date: json['date'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nom': nom,
        'date': date
      };
}
