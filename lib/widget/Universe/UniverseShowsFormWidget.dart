import 'package:flutter/material.dart';

class UniverseShowsFormWidget extends StatelessWidget {
  final String? nom;
  final int? annee;
  final int? semaine;
  final String? resume;
  final ValueChanged<String> onChangedNom;
  final ValueChanged<String> onChangedAnnee;
  final ValueChanged<String> onChangedSemaine;
  final ValueChanged<String> onChangedResume;


  const UniverseShowsFormWidget({
    Key? key,
    this.nom = '',
    this.annee,
    this.semaine,
    this.resume = '',
    required this.onChangedNom,
    required this.onChangedAnnee,
    required this.onChangedSemaine,
    required this.onChangedResume,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildNom(),
          SizedBox(height: 8),
          buildAnnee(),
          SizedBox(height: 8),
          buildSemaine(),
          SizedBox(height: 8),
          buildResume(),
        ],
      ),
    ),
  );

  Widget buildNom() => TextFormField(
    // maxLines: 1,
    initialValue: nom,
    style: const TextStyle(
      // color: Colors.white70,
      fontWeight: FontWeight.bold,
      fontSize: 24,
    ),
    decoration: const InputDecoration(
      border: InputBorder.none,
      hintText: 'Nom du show',
      // hintStyle: TextStyle(color: Colors.white70),
    ),
    validator: (nom) =>
      nom != null && nom.isEmpty ? 'Le nom du show ne peut pas être vide' : null,
    onChanged: onChangedNom,
  );


  Widget buildAnnee() => TextFormField(
    // maxLines: 1,
    initialValue: annee.toString(),
    style: const TextStyle(
      // color: Colors.white70,
      fontWeight: FontWeight.bold,
      fontSize: 24,
    ),
    decoration: const InputDecoration(
      border: InputBorder.none,
      hintText: 'Annee du show',
      // hintStyle: TextStyle(color: Colors.white70),
    ),
    validator: (date) =>
      date != null && date.isEmpty ? 'La date du show ne peut pas être vide' : null,
    onChanged: onChangedAnnee,
  );

  Widget buildSemaine() => TextFormField(
    // maxLines: 1,
    initialValue: annee.toString(),
    style: const TextStyle(
      // color: Colors.white70,
      fontWeight: FontWeight.bold,
      fontSize: 24,
    ),
    decoration: const InputDecoration(
      border: InputBorder.none,
      hintText: 'Semaine du show',
      // hintStyle: TextStyle(color: Colors.white70),
    ),
    validator: (date) =>
      date != null && date.isEmpty ? 'La date du show ne peut pas être vide' : null,
    onChanged: onChangedSemaine,
  );
  
  Widget buildResume() => TextFormField(
    maxLines : null,
    initialValue: resume,
    style : const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 24,
    ),
    decoration : const InputDecoration(
      border: InputBorder.none,
      hintText: 'Résumé du show',
    ),
    onChanged: onChangedResume,
  );
}