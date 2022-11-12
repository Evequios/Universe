class IRLShowsFields {
  static final List<String> values = [
    /// Add all fields
    id, nom, date
  ];

  static final String id = '_id';
  static final String nom = 'nom';
  static final String date = 'date';
}

class IRLShows{
  final String id;
  final String nom;
  final String date;

  const IRLShows({
    required this.id,
    required this.nom,
    required this.date
  });

  IRLShows copy({
    String? id,
    String? nom,
    String? date,
  }) =>
      IRLShows(
        id: id ?? this.id,
        nom: nom ?? this.nom,
        date: date ?? this.date,
      );

  static IRLShows fromJson(Map<String, dynamic> json) => IRLShows(
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
