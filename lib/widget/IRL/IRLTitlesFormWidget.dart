import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

const List<String> listTag = <String>['true', 'false'];

class IRLTitlesFormWidget extends StatelessWidget {
  final String? nom;
  final String? show;
  final String? tag;
  final String? holder1;
  final String? holder2;
  final ValueChanged<String> onChangedNom;
  final ValueChanged<String> onChangedShow;
  final ValueChanged<String?> onChangedTag;
  final ValueChanged<String?> onChangedHolder1; 
  final ValueChanged<String?> onChangedHolder2;


  const IRLTitlesFormWidget({
    Key? key,
    this.nom = '',
    this.show = '',
    this.tag = '',
    this.holder1 = '',
    this.holder2 = '',
    required this.onChangedNom,
    required this.onChangedShow,
    required this.onChangedTag,
    required this.onChangedHolder1,
    required this.onChangedHolder2,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildNom(),
              const SizedBox(height: 8),
              buildShow(),
              const SizedBox(height: 16),
              buildTag(),
              const SizedBox(height: 8),
              buildHolder1(),
              buildHolder2(),
            ],
          ),
        ),
      );

  Widget buildNom() => TextFormField(
        // maxLines: 1,
        initialValue: nom,
        style: const TextStyle(
          // color: Colors.white70,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Nom',
          // hintStyle: TextStyle(color: Colors.white70),
        ),
        validator: (nom) =>
            nom != null && nom.isEmpty ? 'Le nom ne peut pas être vide' : null,
        onChanged: onChangedNom,
      );

  Widget buildShow() => TextFormField(
        maxLines: 5,
        initialValue: show,
        style: const TextStyle(color: Colors.black, fontSize: 18),
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Show',
          hintStyle: TextStyle(color: Colors.black),
        ),
        validator: (texte) => texte != null && texte.isEmpty
            ? 'Le show ne peut pas être vide'
            : null,
        onChanged: onChangedShow,
      );

    Widget buildTag() => Container(alignment: Alignment.bottomLeft,child: DropdownButton(
      hint: const Text("Tag"),
      value: tag == "" ? null : tag,
      onChanged : onChangedTag, 
      items: listTag.map((tag){
        return DropdownMenuItem<String>(
          value: tag == "" ? null : tag,
          child: Text(tag.toString()));
      }).toList(),
    ),);

    Widget buildHolder1() => StreamBuilder(
      stream: FirebaseFirestore.instance.collection('IRLSuperstars').orderBy('prenom').snapshots(),
      builder : (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        return DropdownButton(
          hint: const Text('Champion'),
          value: holder1 == "" ? null : holder1,
          items:
          snapshot.data?.docs.map((DocumentSnapshot document){
            return DropdownMenuItem(
              value: '${document['prenom']} ${document['nom']}',
              child: Text('${document['prenom']} ${document['nom']}'),
            );
          }).toList(),
          onChanged: onChangedHolder1,
        );
      });


    Widget buildHolder2() => StreamBuilder(
      stream: FirebaseFirestore.instance.collection('IRLSuperstars').orderBy('prenom').snapshots(),
      builder : (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        return DropdownButton(
          hint: const Text('Champion 2'),
          value: holder2 == "" ? null : holder2,
          items:
          snapshot.data?.docs.map((DocumentSnapshot document){
            return DropdownMenuItem(
              value: '${document['prenom']} ${document['nom']}',
              child: Text('${document['prenom']} ${document['nom']}'),
            );
          }).toList(),
          onChanged: onChangedHolder2,
        );
      });
}