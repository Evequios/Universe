import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ShowsFormWidget extends StatelessWidget {
  final String? name;
  final int? year;
  final int? week;
  final int? dayOfWeek;
  final String? summary;
  final ValueChanged<String> onChangedName;
  final ValueChanged<String> onChangedYear;
  final ValueChanged<String> onChangedWeek;
  final ValueChanged<String> onChangedDayOfWeek;
  final ValueChanged<String> onChangedSummary;


  const ShowsFormWidget({
    super.key,
    this.name = '',
    this.year,
    this.week,
    this.dayOfWeek,
    this.summary = '',
    required this.onChangedName,
    required this.onChangedYear,
    required this.onChangedWeek,
    required this.onChangedDayOfWeek,
    required this.onChangedSummary,
  });

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
          buildDayOfWeek(),
          const SizedBox(height: 8),
          buildResume(),
        ],
      ),
    ),
  );

  Widget buildNom() => TextFormField(
    textCapitalization: TextCapitalization.sentences,
    initialValue: name,
    style: const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 18,
    ),
    decoration: InputDecoration(
      labelText: "Name",
      labelStyle: TextStyle(color: Colors.black87.withOpacity(0.5), fontSize: 18, ),
      border: const OutlineInputBorder(),
    ),
    validator: (nom) =>
      nom == null || nom.isEmpty ? "The show's name can't be empty" : null,
    onChanged: onChangedName,
  );


  Widget buildAnnee() => TextFormField(
    keyboardType: TextInputType.number,
    inputFormatters: [
      FilteringTextInputFormatter.digitsOnly
    ],
    initialValue: year == 0 ? '' : year.toString(),
    style: const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 18,
    ),
    decoration: InputDecoration(
      labelText: "Year",
      labelStyle: TextStyle(color: Colors.black87.withOpacity(0.5)),
      border: const OutlineInputBorder(),
    ),
    validator: (year) =>
      year == null || year.isEmpty ? "The show's year can't be empty" : null,
    onChanged: onChangedYear,
  );

  Widget buildSemaine() => TextFormField(
    keyboardType: TextInputType.number,
    inputFormatters: [
      FilteringTextInputFormatter.digitsOnly
    ],
    initialValue: week == 0 ? '' : week.toString(),
    style: const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 18,
    ),
    decoration: InputDecoration(
      labelText: "Week",
      labelStyle: TextStyle(color: Colors.black87.withOpacity(0.5), fontSize: 18),
      border: const OutlineInputBorder(),
    ),
    validator: (week) =>
      week == null || week.isEmpty ? "The show's week can't be empty" : null,
    onChanged: onChangedWeek,
  );

  Widget buildDayOfWeek() => ButtonTheme(
    child: DropdownButtonFormField<int>(
      initialValue: dayOfWeek ?? 1,
      decoration: InputDecoration(
        labelText: "Day of the week",
        labelStyle: TextStyle(color: Colors.black87.withOpacity(0.5), fontSize: 18),
        border: const OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(value: 1, child: Text("Monday")),
        DropdownMenuItem(value: 2, child: Text("Tuesday")),
        DropdownMenuItem(value: 3, child: Text("Wednesday")),
        DropdownMenuItem(value: 4, child: Text("Thursday")),
        DropdownMenuItem(value: 5, child: Text("Friday")),
        DropdownMenuItem(value: 6, child: Text("Saturday")),
        DropdownMenuItem(value: 7, child: Text("Sunday")),
      ],
      onChanged: (value) {
        if (value != null) {
          onChangedDayOfWeek(value.toString());
        }
      },
    ),
  );
  
  Widget buildResume() => TextFormField(
    textCapitalization: TextCapitalization.sentences,
    maxLines : null,
    initialValue: summary,
    style : const TextStyle(
      fontWeight: FontWeight.bold,
      color : Colors.black,
      fontSize: 18,
    ),
    decoration : InputDecoration(
      labelText: "Summary",
      labelStyle: TextStyle(color: Colors.black87.withOpacity(0.5), fontSize: 18),
      border: const OutlineInputBorder(),
    ),
    onChanged: onChangedSummary,
  );
}