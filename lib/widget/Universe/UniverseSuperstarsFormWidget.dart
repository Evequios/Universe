import 'package:flutter/material.dart';

const List<String> listOrientations = <String>['Face', 'Tweener', 'Heel'];
const List<String> listShows = <String>['Raw', 'SmackDown', 'NXT'];

class UniverseSuperstarsFormWidget extends StatelessWidget {
  final String? nom;
  final String? show;
  final String? orientation;
  final ValueChanged<String> onChangedNom;
  final ValueChanged<String?> onChangedShow;
  final ValueChanged<String?> onChangedOrientation;

  const UniverseSuperstarsFormWidget({
    Key? key,
    this.nom = '',
    this.show = '',
    this.orientation = '',
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
              buildNom(),
              buildShow(),
              buildOrientation(),
            ],
          ),
        ),
      )
  );
  }


  Widget buildNom() => TextFormField(
        // maxLines: 5,
        initialValue: nom,
        style: const TextStyle(color: Colors.black, fontSize: 18),
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Nom',
          hintStyle: TextStyle(color: Colors.black),
        ),
        // validator: (nom) => nom != null && nom.isEmpty ? 'Le nom ne peut pas être vide': null,
        onChanged: onChangedNom,
      );

    Widget buildShow() => Container(child: DropdownButton(
      hint: Text("Show"),
      value: show == "" ? null : show,
      onChanged : onChangedShow, 
      items: listShows.map((show){
        return DropdownMenuItem<String>(
          child: Text(show),
          value: show == "" ? null : show,);
      }).toList(),
    ),
    alignment: Alignment.bottomLeft);

    Widget buildOrientation() => Container(alignment: Alignment.bottomLeft,child: DropdownButton(
      hint: Text("Orientation"),
      value: orientation == "" ? null : orientation,
      onChanged : onChangedOrientation, 
      items: listOrientations.map((orientation){
        return DropdownMenuItem<String>(
          value: orientation == "" ? null : orientation,
          child: Text(orientation));
      }).toList(),
    ),);
  
}