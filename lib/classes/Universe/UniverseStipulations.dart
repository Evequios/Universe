import 'package:cloud_firestore/cloud_firestore.dart';

class UniverseStipulations{
  final String id;
  final String type;
  final String stipulation;

  const UniverseStipulations({
    required this.id,
    required this.type,
    required this.stipulation,
  });

  static UniverseStipulations fromJson(Map<String, dynamic> json) => UniverseStipulations(
        id: json['id'],
        type: json['type'],
        stipulation: json['stipulation'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'stipulation': stipulation,
      };
}
