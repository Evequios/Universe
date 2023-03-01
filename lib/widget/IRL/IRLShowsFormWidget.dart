import 'package:flutter/material.dart';

class IRLShowsFormWidget extends StatelessWidget {
  final String? nom;
  final String? date;
  final String? resume;
  final ValueChanged<String> onChangedNom;
  final ValueChanged<String> onChangedDate;
  final ValueChanged<String> onChangedResume;


  const IRLShowsFormWidget({
    Key? key,
    this.nom = '',
    this.date = '',
    this.resume = '',
    required this.onChangedNom,
    required this.onChangedDate,
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
          buildDate(),
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


  Widget buildDate() => TextFormField(
    // maxLines: 1,
    initialValue: date,
    style: const TextStyle(
      // color: Colors.white70,
      fontWeight: FontWeight.bold,
      fontSize: 24,
    ),
    decoration: const InputDecoration(
      border: InputBorder.none,
      hintText: 'Date en format DD/MM/YYYY',
      // hintStyle: TextStyle(color: Colors.white70),
    ),
    validator: (date) =>
      date != null && date.isEmpty ? 'La date du show ne peut pas être vide' : null,
    onChanged: onChangedDate,
  );
  
  Widget buildResume() => TextFormField(
    // maxLines: 1,
    maxLines: null,
    initialValue: resume,
    style: const TextStyle(
      // color: Colors.white70,
      fontWeight: FontWeight.bold,
      fontSize: 24,
    ),
    decoration: const InputDecoration(
      border: InputBorder.none,
      hintText: 'Résumé du show',
      // hintStyle: TextStyle(color: Colors.white70),
    ),
    onChanged: onChangedResume,
  );
}