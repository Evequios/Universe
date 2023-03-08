import 'package:flutter/material.dart';

class UniverseBrandsFormWidget extends StatelessWidget {
  final String? name;
  final ValueChanged<String> onChangedName;


  const UniverseBrandsFormWidget({
    Key? key,
    this.name = '',
    required this.onChangedName
  }) : super(key: key);

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
        initialValue: name,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Name',
        ),
        validator: (name) =>
            name != null && name.isEmpty ? 'The show must have a name' : null,
        onChanged: onChangedName,
      );
}