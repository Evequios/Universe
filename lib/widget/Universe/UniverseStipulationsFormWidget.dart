import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/Universe/UniverseStipulations.dart';


class UniverseStipulationsFormWidget extends StatelessWidget {
  final String? type;
  final String? stipulation;
  final ValueChanged<String> onChangedType;
  final ValueChanged<String> onChangedStipulation;


  const UniverseStipulationsFormWidget({
    Key? key,
    this.type = '',
    this.stipulation,
    required this.onChangedType,
    required this.onChangedStipulation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildType(),
              SizedBox(height: 8),
              buildStipulation(),
              SizedBox(height: 16),
            ],
          ),
        ),
      );

  Widget buildType() => TextFormField(
        // maxLines: 1,
        initialValue: type,
        style: const TextStyle(
          // color: Colors.white70,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Type',
          // hintStyle: TextStyle(color: Colors.white70),
        ),
        validator: (titre) =>
            titre != null && titre.isEmpty ? 'Le type ne peut pas être vide' : null,
        onChanged: onChangedType,
      );

  Widget buildStipulation() => TextFormField(
        maxLines: 5,
        initialValue: stipulation,
        style: const TextStyle(color: Colors.black, fontSize: 18),
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Stipulation',
          hintStyle: TextStyle(color: Colors.black),
        ),
        validator: (texte) => texte != null && texte.isEmpty
            ? 'La stipulation ne peut pas être vide'
            : null,
        onChanged: onChangedStipulation,
      );
}