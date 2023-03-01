import 'package:flutter/material.dart';

const List<String> listOrientations = <String>['Face', 'Tweener', 'Heel'];
const List<String> listShows = <String>['Aucun', 'Raw', 'SmackDown', 'NXT'];

class IRLSuperstarsFormWidget extends StatelessWidget {
  final String? prenom;
  final String? nom;
  final String? show;
  final String? orientation;
  final String? titre;
  final ValueChanged<String> onChangedPrenom;
  final ValueChanged<String> onChangedNom;
  final ValueChanged<String?> onChangedShow;
  final ValueChanged<String?> onChangedOrientation;
  final ValueChanged<String?> onChangedTitre;

  const IRLSuperstarsFormWidget({
    Key? key,
    this.prenom = '',
    this.nom = '',
    this.show = '',
    this.orientation = '',
    this.titre = '',
    required this.onChangedPrenom,
    required this.onChangedNom,
    required this.onChangedShow,
    required this.onChangedOrientation, 
    required this.onChangedTitre,
  }) : super(key: key);

  @override
  Widget build(BuildContext context){ 
  return Scaffold(
    body: 
        Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildPrenom(),
              SizedBox(height: 8,),
              buildNom(),
              SizedBox(height: 8,),
              buildShow(),
              SizedBox(height: 16,),
              buildOrientation(),
            ],
          ),
        ),
  );
  }
  Widget buildPrenom() => TextFormField(
        // maxLines: 1,
        initialValue: prenom,
        style: const TextStyle(color: Colors.black, fontSize: 18),
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Prénom',
          hintStyle: TextStyle(color: Colors.black),
          labelText: 'Prénom : ',
          labelStyle: TextStyle(decoration: TextDecoration.underline, color: Colors.black)
        ),
        validator: (prenom) => prenom != null && prenom.isEmpty ? 'Le prénom ne peut pas être vide' : null,
        onChanged: onChangedPrenom,
      );

  Widget buildNom() => TextFormField(
        // maxLines: 5,
        initialValue: nom,
        style: const TextStyle(color: Colors.black, fontSize: 18),
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Nom',
          hintStyle: TextStyle(color: Colors.black),
          labelText: 'Nom : ',
          labelStyle: TextStyle(decoration: TextDecoration.underline, color: Colors.black)
        ),
        // validator: (nom) => nom != null && nom.isEmpty ? 'Le nom ne peut pas être vide': null,
        onChanged: onChangedNom,
      );

    Widget buildShow() => Container(alignment: Alignment.bottomLeft, child: DropdownButtonFormField(
      decoration: const InputDecoration(
        labelText: 'Show : ',
        labelStyle: TextStyle(decoration: TextDecoration.underline, color: Colors.black)),
      // hint: Text("Show"),
      value: show == "" ? null : show,
      onChanged : onChangedShow, 
      items: listShows.map((show){
        return DropdownMenuItem<String>(
          child: Text(show),
          value: show == "" ? null : show,);
      }).toList(),
    ));

    Widget buildOrientation() => Container(alignment: Alignment.bottomLeft,child: DropdownButtonFormField(
      decoration : const InputDecoration(
        labelText: 'Orientation : ',
        labelStyle: TextStyle(decoration: TextDecoration.underline, color: Colors.black)),
      // hint: Text("Orientation"),
      value: orientation == "" ? null : orientation,
      onChanged : onChangedOrientation, 
      items: listOrientations.map((orientation){
        return DropdownMenuItem<String>(
          value: orientation == "" ? null : orientation,
          child: Text(orientation));
      }).toList(),
    ),);
}