import 'package:cloud_firestore/cloud_firestore.dart';

class IRLStipulations{
  final String id;
  final String type;
  final String stipulation;

  const IRLStipulations({
    required this.id,
    required this.type,
    required this.stipulation,
  });

  static IRLStipulations fromJson(Map<String, dynamic> json) => IRLStipulations(
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
