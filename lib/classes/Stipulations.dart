
const String tableStipulations = 'stipulations';

class StipulationsFields {
  static const String id = '_id';
  static const String type = 'type';
  static const String stipulation = 'stipulation';

  static const List<String> values = [
    id,
    type,
    stipulation,
  ];
}

class Stipulations {
  final int? id;

  // Champ conservé temporairement pour la compatibilité.
  final String type;

  // Nom de la stipulation.
  final String stipulation;

  const Stipulations({
    this.id,
    this.type = '',
    required this.stipulation,
  });

  Stipulations copy({
    int? id,
    String? type,
    String? stipulation,
  }) {
    return Stipulations(
      id: id ?? this.id,
      type: type ?? this.type,
      stipulation: stipulation ?? this.stipulation,
    );
  }

  factory Stipulations.fromJson(Map<String, dynamic> json) {
    return Stipulations(
      id: json[StipulationsFields.id] as int?,
      type: json[StipulationsFields.type] as String? ?? '',
      stipulation: json[StipulationsFields.stipulation] as String,
    );
  }

  Map<String, Object?> toJson() {
    return {
      StipulationsFields.id: id,
      StipulationsFields.type: type,
      StipulationsFields.stipulation: stipulation,
    };
  }
}
