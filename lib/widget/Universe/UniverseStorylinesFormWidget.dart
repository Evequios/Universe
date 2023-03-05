import 'package:flutter/material.dart';

class UniverseStorylinesFormWidget extends StatelessWidget {
  final String? title;
  final String? text;
  final int? yearStart;
  final int? yearEnd;
  final int? start;
  final int? end;
  final ValueChanged<String?> onChangedTitle;
  final ValueChanged<String?> onChangedText;
  final ValueChanged<String?> onChangedYearStart;
  final ValueChanged<String?> onChangedYearEnd;
  final ValueChanged<String?> onChangedStart;
  final ValueChanged<String?> onChangedEnd;

  const UniverseStorylinesFormWidget({
    Key? key,
    this.title = '',
    this.text = '',
    this.yearStart,
    this.yearEnd,
    this.start,
    this.end,
    required this.onChangedTitle,
    required this.onChangedText,
    required this.onChangedYearStart,
    required this.onChangedYearEnd,
    required this.onChangedStart,
    required this.onChangedEnd,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildTitle(),
          const SizedBox(height: 8),
          buildText(),
          const SizedBox(height: 16),
          buildYearStart(),
          const SizedBox(height: 16),
          buildYearEnd(),
          const SizedBox(height: 16),
          buildStart(),
          const SizedBox(height: 8),
          buildEnd(),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );

  Widget buildTitle() => TextFormField(
    initialValue: title,
    style: const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 24,
    ),
    decoration: const InputDecoration(
      border: InputBorder.none,
      hintText: 'Title',
    ),
    validator: (title) =>
        title != null && title.isEmpty ? "The title can't be empty" : null,
    onChanged: onChangedTitle,
  );

  Widget buildText() => TextFormField(
    initialValue: text,
    style: const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 18
    ),
    decoration: const InputDecoration(
      border: InputBorder.none,
      hintText: 'Text',
    ),
    validator: (texte) => texte != null && texte.isEmpty
        ? "The text can't be empty"
        : null,
    onChanged: onChangedText,
  );

  Widget buildYearStart() => TextFormField(
    keyboardType: TextInputType.number,
    initialValue: yearStart.toString(),
    style: const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 18
    ),
    decoration: const InputDecoration(
      labelText: 'Starting year : ',
      labelStyle: TextStyle(decoration: TextDecoration.underline),
      border: InputBorder.none,
      hintText: 'Starting year',
    ),
    validator: (yearStart) =>
        yearStart != null && yearStart.isEmpty ? "The starting year can't be empty" : null,
    onChanged: onChangedYearStart,
  );

  Widget buildYearEnd() => TextFormField(
    initialValue: yearEnd.toString(),
    style: const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 18
    ),
    decoration: const InputDecoration(
      labelText: 'Ending year : ',
      labelStyle: TextStyle(decoration: TextDecoration.underline),
      border: InputBorder.none,
      hintText: 'Ending year',
    ),
    onChanged: onChangedYearEnd,
  );

  Widget buildStart() => TextFormField(
    initialValue: start.toString(),
    style: const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 18
    ),
    decoration: const InputDecoration(
      labelText: 'Starting week : ',
      labelStyle: TextStyle(decoration: TextDecoration.underline),
      border: InputBorder.none,
      hintText: 'Starting week',
    ),
    validator: (debut) =>
        debut != null && debut.isEmpty ? "The starting week can't be empty" : null,
    onChanged: onChangedStart,
  );

  Widget buildEnd() => TextFormField(
    initialValue: end.toString(),
    style: const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 18
    ),
    decoration: const InputDecoration(
      labelText: 'Ending week : ',
      labelStyle: TextStyle(decoration: TextDecoration.underline),
      border: InputBorder.none,
      hintText: 'Ending week',
    ),
    onChanged: onChangedEnd,
  );
}