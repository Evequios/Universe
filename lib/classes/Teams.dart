import 'package:wwe_universe/classes/superstars.dart';

const String tableTeams = 'teams';

class TeamsFields {
  static const String id = '_id';
  static const String name = 'name';
  static const String member1 = 'member1';
  static const String member2 = 'member2';
  static const String member3 = 'member3';
  static const String member4 = 'member4';
  static const String member5 = 'member5';

  static const List<String> values = [
    id, name, member1, member2, member3, member4, member5
  ];
}

class Teams{
  final int? id;
  final String name;
  final Superstars member1;
  final Superstars member2;
  final Superstars? member3;
  final Superstars? member4;
  final Superstars? member5;

  const Teams({
    this.id,
    required this.name,
    required this.member1,
    required this.member2,
    this.member3,
    this.member4,
    this.member5,
  });

  Teams copy ({
    int? id,
    String? name,
    Superstars? member1,
    Superstars? member2,
    Superstars? member3,
    Superstars? member4,
    Superstars? member5,
  }) {
    return Teams(
      id : id ?? this.id,
      name : name ?? this.name,
      member1: member1 ?? this.member1,
      member2: member2 ?? this.member2,
      member3: member3 ?? this.member3,
      member4: member4 ?? this.member4,
      member5: member5 ?? this.member5,
    );
  }

  Map<String, Object?> toJson() { 
    return {
      TeamsFields.id: id,
      TeamsFields.name: name,
      TeamsFields.member1: member1.id,
      TeamsFields.member2: member2.id,
      TeamsFields.member3: member3?.id,
      TeamsFields.member4: member4?.id,
      TeamsFields.member5: member5?.id,
    };
  }
}