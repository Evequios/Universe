import 'package:flutter/material.dart';

class IRLStorylinesFormWidget extends StatelessWidget {
  final String? titre;
  final String? texte;
  final String? debut;
  final String? fin;
  final ValueChanged<String> onChangedTitre;
  final ValueChanged<String> onChangedTexte;
  final ValueChanged<String> onChangedDebut;
  final ValueChanged<String> onChangedFin;

  const IRLStorylinesFormWidget({
    Key? key,
    this.titre = '',
    this.texte = '',
    this.debut = '',
    this.fin = '',
    required this.onChangedTitre,
    required this.onChangedTexte,
    required this.onChangedDebut,
    required this.onChangedFin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildTitre(),
              const SizedBox(height: 8),
              buildTexte(),
              const SizedBox(height: 16),
              buildDebut(),
              const SizedBox(height: 8),
              buildFin(),
              const SizedBox(height: 8),
            ],
          ),
        ),
      );

  Widget buildTitre() => TextFormField(
        // maxLines: 1,
        initialValue: titre,
        style: const TextStyle(
          // color: Colors.white70,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Titre',
          // hintStyle: TextStyle(color: Colors.white70),
        ),
        validator: (titre) =>
            titre != null && titre.isEmpty ? 'Le titre ne peut pas être vide' : null,
        onChanged: onChangedTitre,
      );

  Widget buildTexte() => TextFormField(
        // maxLines: 5,
        initialValue: texte,
        style: const TextStyle(color: Colors.black, fontSize: 18),
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Texte',
          hintStyle: TextStyle(color: Colors.black),
        ),
        validator: (texte) => texte != null && texte.isEmpty
            ? 'Le texte ne peut pas être vide'
            : null,
        onChanged: onChangedTexte,
      );



    Widget buildDebut() => TextFormField(
        // maxLines: 1,
        initialValue: debut,
        style: const TextStyle(
          // color: Colors.white70,
          fontWeight: FontWeight.bold,
          fontSize: 18
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Date de début en format DD/MM/YYYY',
          // hintStyle: TextStyle(color: Colors.white70),
        ),
        validator: (debut) =>
            debut != null && debut.isEmpty ? 'La date de début ne peut pas être vide' : null,
        onChanged: onChangedDebut,
      );

      Widget buildFin() => TextFormField(
        // maxLines: 1,
        initialValue: fin,
        style: const TextStyle(
          // color: Colors.white70,
          fontWeight: FontWeight.bold,
          fontSize: 18
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Date de fin en format DD/MM/YYYY',
          // hintStyle: TextStyle(color: Colors.white70),
        ),
        onChanged: onChangedFin,
      );
}