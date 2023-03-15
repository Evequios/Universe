import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  UniverseStorylinesFormWidget({
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

  final regexInt = RegExp(r"^[0-9]*$");
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
          const SizedBox(height: 24),
          buildYearStart(),
          const SizedBox(height: 8),
          buildStart(),
          const SizedBox(height: 24),
          buildYearEnd(),
          const SizedBox(height: 8),
          buildEnd(),
        ],
      ),
    ),
  );

  Widget buildTitle() => TextFormField(
    initialValue: title,
    style: const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 18,
    ),
    decoration: InputDecoration(
      labelText: "Title",
      labelStyle: TextStyle(color: Colors.black87.withOpacity(0.5), fontSize: 18, ),
      border: const OutlineInputBorder(),
    ),
    validator: (title) =>
        title != null && title.isEmpty ? "The title can't be empty" : null,
    onChanged: onChangedTitle,
  );

  Widget buildText() => TextFormField(
    maxLines: null,
    initialValue: text,
    style: const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 18
    ),
    decoration: InputDecoration(
      labelText: "Text",
      labelStyle: TextStyle(color: Colors.black87.withOpacity(0.5), fontSize: 18, ),
      border: const OutlineInputBorder(),
    ),
    validator: (text) => text != null && text.isEmpty
        ? "The text can't be empty"
        : null,
    onChanged: onChangedText,
  );

  Widget buildYearStart() => TextFormField(
    keyboardType: TextInputType.number,
    inputFormatters: [
      FilteringTextInputFormatter.digitsOnly
    ],
    initialValue: yearStart == 0 ? '' : yearStart.toString(),
    style: const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 18
    ),
    decoration: InputDecoration(
      labelText: 'Starting year',
      labelStyle: TextStyle(color: Colors.black87.withOpacity(0.5)),
      border: const OutlineInputBorder(),
    ),
    validator: (yearStart) =>
        yearStart != null && yearStart.isEmpty ? "The starting year can't be empty" : null,
    onChanged: onChangedYearStart,
  );

  Widget buildYearEnd() => TextFormField(
    keyboardType: TextInputType.number,
    inputFormatters: [
      FilteringTextInputFormatter.digitsOnly
    ],
    initialValue: yearEnd == 0 ? '' : yearEnd.toString(),
    style: const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 18
    ),
    decoration: InputDecoration(
      labelText: 'Ending year',
      labelStyle: TextStyle(color: Colors.black87.withOpacity(0.5)),
      border: const OutlineInputBorder(),
    ),
    onChanged: onChangedYearEnd,
  );

  Widget buildStart() => TextFormField(
    keyboardType: TextInputType.number,
    inputFormatters: [
      FilteringTextInputFormatter.digitsOnly
    ],
    initialValue: start == 0 ? '' : start.toString(),
    style: const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 18
    ),
    decoration: InputDecoration(
      labelText: 'Starting week',
      labelStyle: TextStyle(color: Colors.black87.withOpacity(0.5)),
      border: const OutlineInputBorder(),
    ),
    validator: (debut) =>
        debut != null && debut.isEmpty ? "The starting week can't be empty" : null,
    onChanged: onChangedStart,
  );

  Widget buildEnd() => TextFormField(
    keyboardType: TextInputType.number,
    inputFormatters: [
      FilteringTextInputFormatter.digitsOnly
    ],
    initialValue: end == 0 ? '' : end.toString(),
    style: const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 18
    ),
    decoration: InputDecoration(
      labelText: 'Ending week',
      labelStyle: TextStyle(color: Colors.black87.withOpacity(0.5)),
      border: const OutlineInputBorder(),
    ),
    onChanged: onChangedEnd,
  );
}