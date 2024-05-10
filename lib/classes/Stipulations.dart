const String tableStipulations = 'stipulations';

class StipulationsFields {
  static final List<String> values = [
    id, type, stipulation
  ];

  static const String id = '_id';
  static const String type = 'type';
  static const String stipulation = 'stipulation';
}
class Stipulations{
  final int? id;
  final String type;
  final String stipulation;

  const Stipulations({
    this.id,
    required this.type,
    required this.stipulation,
  });

  Stipulations copy ({
    int? id,
    String? type,
    String? stipulation,
  }) =>
    Stipulations(
      id : id ?? this.id,
      type: type ?? this.type,
      stipulation: stipulation ?? this.stipulation,
    );

  static Stipulations fromJson(Map<String, dynamic> json) => Stipulations(
        id: json[StipulationsFields.id] as int ?,
        type: json[StipulationsFields.type] as String,
        stipulation: json[StipulationsFields.stipulation] as String,
      );

  Map<String, dynamic> toJson() => {
        StipulationsFields.id: id,
        StipulationsFields.type: type,
        StipulationsFields.stipulation: stipulation,
      };
}
