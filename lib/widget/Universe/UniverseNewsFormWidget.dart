import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const List<String> listCategories = <String>['Annonce', 'Blessure', 'Retour', 'Autre'];

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
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildTitre(),
              SizedBox(height: 8),
              buildTexte(),
              SizedBox(height: 16),
              buildCategorie()
            ],
          ),
        ),
      );

  Widget buildTitre() => TextFormField(
        // maxLines: 1,
        initialValue: title,
        style: const TextStyle(
          // color: Colors.white70,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Titre',
          // hintStyle: TextStyle(color: Colors.white70),
        ),
        validator: (titre) =>
            titre != null && titre.isEmpty ? 'Le titre ne peut pas être vide' : null,
        onChanged: onChangedTitle,
      );

  Widget buildTexte() => TextFormField(
        maxLines: 5,
        initialValue: text,
        style: const TextStyle(color: Colors.black, fontSize: 18),
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Texte',
          hintStyle: TextStyle(color: Colors.black),
        ),
        validator: (texte) => texte != null && texte.isEmpty
            ? 'Le texte ne peut pas être vide'
            : null,
        onChanged: onChangedText,
      );



    Widget buildCategorie() => Container(alignment: Alignment.bottomLeft,child: DropdownButton(
      value: type != '' && type != null ? type : listCategories[0],
      onChanged : onChangedType, 
      items: listCategories.map((categorie){
        return DropdownMenuItem<String>(
          value: categorie != '' && categorie != null ? categorie : listCategories[0],
          child: Text(categorie),);
      }).toList(),
    ),);
}