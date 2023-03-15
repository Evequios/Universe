import 'package:flutter/material.dart';

const List<String> listCategories = <String>['Announcement', 'Injury', 'Return', 'Other'];

class UniverseNewsFormWidget extends StatelessWidget {
  final String? title;
  final String? text;
  final String? type;
  final ValueChanged<String> onChangedTitle;
  final ValueChanged<String> onChangedText;
  final ValueChanged<String?> onChangedType;


  const UniverseNewsFormWidget({
    Key? key,
    this.title = '',
    this.text = '',
    this.type = '',
    required this.onChangedTitle,
    required this.onChangedText,
    required this.onChangedType
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
              buildCategorie()
            ],
          ),
        ),
      );

  Widget buildTitre() => TextFormField(
    textCapitalization: TextCapitalization.sentences,
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
        title == null || title.isEmpty ? "The news' title can't be empty" : null,
    onChanged: onChangedTitle,
  );

  Widget buildTexte() => TextFormField(
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

    Widget buildCategorie() => 
    ButtonTheme( 
      alignedDropdown: true, 
      child: DropdownButtonFormField(
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: 'Type',
        labelStyle: TextStyle(color: Colors.black87.withOpacity(0.5)),
      ),
        value: type != '' && type != null ? type : listCategories[0],
        onChanged: onChangedType,
        items: listCategories.map((type){
        return DropdownMenuItem(
          value: type != '' ? type : listCategories[0],
          child: Text(type));
      }).toList(),
      ));
}