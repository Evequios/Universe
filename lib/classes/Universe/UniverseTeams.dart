const String tableTeams = 'teams';

class TeamsFields {
  static final List<String> values = [
    id, nom, member1, member2, member3, member4, member5
  ];

  static const String id = '_id';
  static const String nom = 'nom';
  static const String member1 = 'member1';
  static const String member2 = 'member2';
  static const String member3 = 'member3';
  static const String member4 = 'member4';
  static const String member5 = 'member5';
}

class UniverseTeams{
  final int? id;
  final String nom;
  final int member1;
  final int member2;
  final int member3;
  final int member4;
  final int member5;

  const UniverseTeams({
    this.id,
    required this.nom,
    required this.member1,
    required this.member2,
    required this.member3,
    required this.member4,
    required this.member5,
  });

  UniverseTeams copy ({
    int? id,
    String? nom,
    int? member1,
    int? member2,
    int? member3,
    int? member4,
    int? member5,
  }) =>
    UniverseTeams(
      id : id ?? this.id,
      nom : nom ?? this.nom,
      member1: member1 ?? this.member1,
      member2: member2 ?? this.member2,
      member3: member3 ?? this.member3,
      member4: member4 ?? this.member4,
      member5: member5 ?? this.member5,
    );

  static UniverseTeams fromJson(Map<String, dynamic> json) => UniverseTeams(
    id: json[TeamsFields.id] as int ?,
    nom: json[TeamsFields.nom] as String,
    member1: json[TeamsFields.member1] as int,
    member2: json[TeamsFields.member2] as int,
    member3: json[TeamsFields.member3] as int,
    member4: json[TeamsFields.member4] as int,
    member5: json[TeamsFields.member5] as int,
  );

  Map<String, dynamic> toJson() => {
    TeamsFields.id: id,
    TeamsFields.nom: nom,
    TeamsFields.member1: member1,
    TeamsFields.member2: member2,
    TeamsFields.member3: member3,
    TeamsFields.member4: member4,
    TeamsFields.member5: member5,
  };
}