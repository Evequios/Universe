import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const List<String> listCategories = <String>['Annonce', 'Blessure', 'Retour', 'Autre'];

class IRLNewsFormWidget extends StatelessWidget {
  final String? titre;
  final String? texte;
  final String? categorie;
  final ValueChanged<String> onChangedTitre;
  final ValueChanged<String> onChangedTexte;
  final ValueChanged<String?> onChangedCategorie;


  const IRLNewsFormWidget({
    Key? key,
    this.titre = '',
    this.texte = '',
    this.categorie = '',
    required this.onChangedTitre,
    required this.onChangedTexte,
    required this.onChangedCategorie
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
        initialValue: titre,
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
        onChanged: onChangedTitre,
      );

  Widget buildTexte() => TextFormField(
        maxLines: 5,
        initialValue: texte,
        style: const TextStyle(color: Colors.black, fontSize: 18),
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Texte',
          hintStyle: TextStyle(color: Colors.black),
        ),
        validator: (texte) => texte != null && texte.isEmpty
            ? 'Le texte ne peut pas être vide'
            : null,
        onChanged: onChangedTexte,
      );



    Widget buildCategorie() => Container(alignment: Alignment.bottomLeft,child: DropdownButton(
      value: categorie != '' && categorie != null ? categorie : listCategories[0],
      onChanged : onChangedCategorie, 
      items: listCategories.map((categorie){
        return DropdownMenuItem<String>(
          value: categorie != '' && categorie != null ? categorie : listCategories[0],
          child: Text(categorie),);
      }).toList(),
    ),);
}