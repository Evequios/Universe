import 'package:flutter/material.dart';

class BrandsFormWidget extends StatelessWidget {
  final String? name;
  final ValueChanged<String> onChangedName;


  const BrandsFormWidget({
    super.key,
    this.name = '',
    required this.onChangedName
  });

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildName()
            ],
          ),
        ),
      );

  Widget buildName() => TextFormField(
    textCapitalization: TextCapitalization.sentences,
    initialValue: name,
    style: const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 18,
    ),
    decoration: InputDecoration(
      filled: true,
      fillColor: Colors.white,
      labelText: "Name",
      labelStyle: TextStyle(color: Colors.black87.withOpacity(0.5), fontSize: 18, ),
      border: const OutlineInputBorder(),
    ),
    validator: (name) =>
      name == null || name.isEmpty ? "The show's name can't be empty" : null,
    onChanged: onChangedName,
  );
}