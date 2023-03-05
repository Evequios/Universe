import 'package:flutter/material.dart';


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
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildType(),
          const SizedBox(height: 8),
          buildStipulation(),
        ],
      ),
    ),
  );

  Widget buildType() => TextFormField(
    initialValue: type,
    style: const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 24,
    ),
    decoration: const InputDecoration(
      border: InputBorder.none,
      hintText: 'Type',
    ),
    validator: (type) =>
        type != null && type.isEmpty ? "The type can't be empty" : null,
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
        ? "The stipulation can't be empty"
        : null,
    onChanged: onChangedStipulation,
  );
}