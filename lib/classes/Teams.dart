import 'package:wwe_universe/classes/superstars.dart';

const String tableTeams = 'teams';

class TeamsFields {
  static final List<String> values = [
    id, name, member1, member2, member3, member4, member5
  ];

  static const String id = '_id';
  static const String name = 'name';
  static const String member1 = 'member1';
  static const String member2 = 'member2';
  static const String member3 = 'member3';
  static const String member4 = 'member4';
  static const String member5 = 'member5';
}

class Teams{
  final int? id;
  final String name;
  final Superstars member1;
  final Superstars member2;
  final Superstars member3;
  final Superstars member4;
  final Superstars member5;

  const Teams({
    this.id,
    required this.name,
    required this.member1,
    required this.member2,
    required this.member3,
    required this.member4,
    required this.member5,
  });

  Teams copy ({
    int? id,
    String? name,
    Superstars? member1,
    Superstars? member2,
    Superstars? member3,
    Superstars? member4,
    Superstars? member5,
  }) =>
    Teams(
      id : id ?? this.id,
      name : name ?? this.name,
      member1: member1 ?? this.member1,
      member2: member2 ?? this.member2,
      member3: member3 ?? this.member3,
      member4: member4 ?? this.member4,
      member5: member5 ?? this.member5,
    );

  static Teams fromJson(Map<String, dynamic> json) => Teams(
    id: json[TeamsFields.id] as int ?,
    name: json[TeamsFields.name] as String,
    member1: json[TeamsFields.member1] as Superstars,
    member2: json[TeamsFields.member2] as Superstars,
    member3: json[TeamsFields.member3] as Superstars,
    member4: json[TeamsFields.member4] as Superstars,
    member5: json[TeamsFields.member5] as Superstars,
  );

  Map<String, dynamic> toJson() => {
    TeamsFields.id: id,
    TeamsFields.name: name,
    TeamsFields.member1: member1,
    TeamsFields.member2: member2,
    TeamsFields.member3: member3,
    TeamsFields.member4: member4,
    TeamsFields.member5: member5,
  };
}