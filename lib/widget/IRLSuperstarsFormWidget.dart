import 'package:flutter/material.dart';

const List<String> listOrientations = <String>['Face', 'Tweener', 'Heel'];
const List<String> listShows = <String>['Raw', 'SmackDown', 'NXT'];

class IRLSuperstarsFormWidget extends StatelessWidget {
  final String? prenom;
  final String? nom;
  final String? show;
  final String? orientation;
  final ValueChanged<String> onChangedPrenom;
  final ValueChanged<String> onChangedNom;
  final ValueChanged<String?> onChangedShow;
  final ValueChanged<String?> onChangedOrientation;

  const IRLSuperstarsFormWidget({
    Key? key,
    this.prenom = '',
    this.nom = '',
    this.show = '',
    this.orientation = '',
    required this.onChangedPrenom,
    required this.onChangedNom,
    required this.onChangedShow,
    required this.onChangedOrientation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context){ 
  return Scaffold(
    body: Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildPrenom(),
              buildNom(),
              buildShow(),
              buildOrientation(),
            ],
          ),
        ),
      )
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
        ),
        // validator: (prenom) => prenom != null && prenom.isEmpty ? 'Le prénom ne peut pas être vide' : null,
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
        ),
        validator: (nom) => nom != null && nom.isEmpty ? 'Le nom ne peut pas être vide': null,
        onChanged: onChangedNom,
      );

    Widget buildShow() => Container(child: DropdownButton(
      value: show != '' && show != null ? show : listShows[0],
      onChanged : onChangedShow, 
      items: listShows.map((show){
        return DropdownMenuItem<String>(
          child: Text(show),
          value: show != '' && show != null ? show : listShows[0],);
      }).toList(),
    ),
    alignment: Alignment.bottomLeft);

    Widget buildOrientation() => Container(alignment: Alignment.bottomLeft,child: DropdownButton(
      value: orientation != '' && orientation != null ? orientation : listOrientations[0],
      onChanged : onChangedOrientation, 
      items: listOrientations.map((orientation){
        return DropdownMenuItem<String>(
          value: orientation != '' && orientation != null ? orientation : listOrientations[0],
          child: Text(orientation),);
      }).toList(),
    ),);
  
}