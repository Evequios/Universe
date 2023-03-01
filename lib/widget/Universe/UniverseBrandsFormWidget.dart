import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class UniverseBrandsFormWidget extends StatelessWidget {
  final String? nom;
  final ValueChanged<String> onChangedNom;


  const UniverseBrandsFormWidget({
    Key? key,
    this.nom = '',
    required this.onChangedNom
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildNom()
            ],
          ),
        ),
      );

  Widget buildNom() => TextFormField(
        initialValue: nom,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Nom',
        ),
        validator: (nom) =>
            nom != null && nom.isEmpty ? 'The show must have a name' : null,
        onChanged: onChangedNom,
      );
}