import 'package:flutter/material.dart';

class UniverseShowsFormWidget extends StatelessWidget {
  final String? name;
  final int? year;
  final int? week;
  final String? summary;
  final ValueChanged<String> onChangedName;
  final ValueChanged<String> onChangedYear;
  final ValueChanged<String> onChangedWeek;
  final ValueChanged<String> onChangedSummary;


  const UniverseShowsFormWidget({
    Key? key,
    this.name = '',
    this.year,
    this.week,
    this.summary = '',
    required this.onChangedName,
    required this.onChangedYear,
    required this.onChangedWeek,
    required this.onChangedSummary,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildNom(),
          const SizedBox(height: 8),
          buildAnnee(),
          const SizedBox(height: 8),
          buildSemaine(),
          const SizedBox(height: 8),
          buildResume(),
        ],
      ),
    ),
  );

  Widget buildNom() => TextFormField(
    initialValue: name,
    style: const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 24,
    ),
    decoration: const InputDecoration(
      border: InputBorder.none,
      hintText: 'Nom du show',
    ),
    validator: (nom) =>
      nom != null && nom.isEmpty ? 'Le nom du show ne peut pas être vide' : null,
    onChanged: onChangedName,
  );


  Widget buildAnnee() => TextFormField(
    initialValue: year.toString(),
    style: const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 24,
    ),
    decoration: const InputDecoration(
      border: InputBorder.none,
      hintText: 'Annee du show',
    ),
    validator: (date) =>
      date != null && date.isEmpty ? 'La date du show ne peut pas être vide' : null,
    onChanged: onChangedYear,
  );

  Widget buildSemaine() => TextFormField(
    initialValue: year.toString(),
    style: const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 24,
    ),
    decoration: const InputDecoration(
      border: InputBorder.none,
      hintText: 'Semaine du show',
    ),
    validator: (date) =>
      date != null && date.isEmpty ? 'La date du show ne peut pas être vide' : null,
    onChanged: onChangedWeek,
  );
  
  Widget buildResume() => TextFormField(
    maxLines : null,
    initialValue: summary,
    style : const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 24,
    ),
    decoration : const InputDecoration(
      border: InputBorder.none,
      hintText: 'Résumé du show',
    ),
    onChanged: onChangedSummary,
  );
}