import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

const List<String> listStipulations = <String>['1v1 Normal', '2v2 Normal', '3v3 Normal', '1v1 Extreme Rules', '2v2 Tornado Tag'];



class IRLMatchesFormWidget extends StatelessWidget {
  final String? stipulation;
  final String? s1;
  final String? s2;
  final String? s3;
  final String? s4;
  final String? s5;
  final String? s6;
  final String? s7;
  final String? s8;
  final String? s9;
  final String? s10;
  final String? gagnant;
  final String? showId;
  final ValueChanged<String?> onChangedStipulation;
  final ValueChanged<String?> onChangedS1;
  final ValueChanged<String?> onChangedS2;
  final ValueChanged<String?> onChangedS3;
  final ValueChanged<String?> onChangedS4;
  final ValueChanged<String?> onChangedS5;
  final ValueChanged<String?> onChangedS6;
  final ValueChanged<String?> onChangedS7;
  final ValueChanged<String?> onChangedS8;
  final ValueChanged<String?> onChangedS9;
  final ValueChanged<String?> onChangedS10;
  final ValueChanged<String?> onChangedGagnant;


  const IRLMatchesFormWidget({
    Key? key,
    this.stipulation = '',
    this.s1= '',
    this.s2= '',
    this.s3= '',
    this.s4= '',
    this.s5= '',
    this.s6= '',
    this.s7= '',
    this.s8= '',
    this.s9= '',
    this.s10= '',
    this.gagnant= '',
    this.showId,

    required this.onChangedStipulation,
    required this.onChangedS1,
    required this.onChangedS2,
    required this.onChangedS3,
    required this.onChangedS4,
    required this.onChangedS5,
    required this.onChangedS6,
    required this.onChangedS7,
    required this.onChangedS8,
    required this.onChangedS9,
    required this.onChangedS10,
    required this.onChangedGagnant,

  }) : super(key: key);
  

  @override
  Widget build(BuildContext context){
  return Scaffold(
    body: SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildStipulation(),
              buildS1(),
              buildS2(),
              buildS3(),
              buildS4(),
              buildS5(),
              buildS6(),
              buildS7(),
              buildS8(),
              buildS9(),
              buildS10(),
              buildGagnant(),
            ],
          ),
        ),
      )
    )
  );
  }

  Widget buildStipulation() => Container(alignment: Alignment.bottomLeft,child: DropdownButton(
      value: stipulation != '' && stipulation != null ? stipulation : listStipulations[0],
      onChanged : onChangedStipulation,
      items: listStipulations.map((stipulation){
        return DropdownMenuItem<String>(
          value: stipulation != '' && stipulation != null ? stipulation : listStipulations[0],
          child: Text(stipulation),);
      }).toList(),
    ),);

  Widget buildS1() => StreamBuilder(
      stream: FirebaseFirestore.instance.collection('IRLSuperstars').snapshots(),
      builder : (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        return DropdownButton(
          hint: Text('Superstar 1'),
          value: s1 == "" ? null : s1,
          items:
          snapshot.data?.docs.map((DocumentSnapshot document){
            return DropdownMenuItem(
              value: '${document['prenom']} ${document['nom']}',
              child: Text('${document['prenom']} ${document['nom']}'),
            );
          }).toList(),
          onChanged: onChangedS1,
        );
      });

      Widget buildS2() => StreamBuilder(
      stream: FirebaseFirestore.instance.collection('IRLSuperstars').snapshots(),
      builder : (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        return DropdownButton(
          hint: Text('Superstar 2'),
          value: s2 == "" ? null : s2,
          items:
          snapshot.data?.docs.map((DocumentSnapshot document){
            return DropdownMenuItem(
              value: '${document['prenom']} ${document['nom']}',
              child: Text('${document['prenom']} ${document['nom']}'),
            );
          }).toList(),
          onChanged: onChangedS2,
        );
      });

    Widget buildS3() => StreamBuilder(
      stream: FirebaseFirestore.instance.collection('IRLSuperstars').snapshots(),
      builder : (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        return DropdownButton(
          hint: Text('Superstar 3'),
          value: s3 == "" ? null : s3,
          items:
          snapshot.data?.docs.map((DocumentSnapshot document){
            return DropdownMenuItem(
              value: '${document['prenom']} ${document['nom']}',
              child: Text('${document['prenom']} ${document['nom']}'),
            );
          }).toList(),
          onChanged: onChangedS3,
        );
      });
  
    Widget buildS4() => StreamBuilder(
      stream: FirebaseFirestore.instance.collection('IRLSuperstars').snapshots(),
      builder : (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        return DropdownButton(
          hint: Text('Superstar 4'),
          value: s4 == "" ? null : s4,
          items:
          snapshot.data?.docs.map((DocumentSnapshot document){
            return DropdownMenuItem(
              value: '${document['prenom']} ${document['nom']}',
              child: Text('${document['prenom']} ${document['nom']}'),
            );
          }).toList(),
          onChanged: onChangedS4,
        );
      });

    Widget buildS5() => StreamBuilder(
      stream: FirebaseFirestore.instance.collection('IRLSuperstars').snapshots(),
      builder : (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        return DropdownButton(
          hint: Text('Superstar 5'),
          value: s5 == "" ? null : s5,
          items:
          snapshot.data?.docs.map((DocumentSnapshot document){
            return DropdownMenuItem(
              value: '${document['prenom']} ${document['nom']}',
              child: Text('${document['prenom']} ${document['nom']}'),
            );
          }).toList(),
          onChanged: onChangedS5,
        );
      });

    Widget buildS6() => StreamBuilder(
      stream: FirebaseFirestore.instance.collection('IRLSuperstars').snapshots(),
      builder : (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        return DropdownButton(
          hint: Text('Superstar 6'),
          value: s6 == "" ? null : s6,
          items:
          snapshot.data?.docs.map((DocumentSnapshot document){
            return DropdownMenuItem(
              value: '${document['prenom']} ${document['nom']}',
              child: Text('${document['prenom']} ${document['nom']}'),
            );
          }).toList(),
          onChanged: onChangedS6,
        );
      });

    Widget buildS7() => StreamBuilder(
      stream: FirebaseFirestore.instance.collection('IRLSuperstars').snapshots(),
      builder : (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        return DropdownButton(
          hint: Text('Superstar 7'),
          value: s7 == "" ? null : s7,
          items:
          snapshot.data?.docs.map((DocumentSnapshot document){
            return DropdownMenuItem(
              value: '${document['prenom']} ${document['nom']}',
              child: Text('${document['prenom']} ${document['nom']}'),
            );
          }).toList(),
          onChanged: onChangedS7,
        );
      });

    Widget buildS8() => StreamBuilder(
      stream: FirebaseFirestore.instance.collection('IRLSuperstars').snapshots(),
      builder : (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        return DropdownButton(
          hint: Text('Superstar 8'),
          value: s8 == "" ? null : s8,
          items:
          snapshot.data?.docs.map((DocumentSnapshot document){
            return DropdownMenuItem(
              value: '${document['prenom']} ${document['nom']}',
              child: Text('${document['prenom']} ${document['nom']}'),
            );
          }).toList(),
          onChanged: onChangedS8,
        );
      });

  Widget buildS9() => StreamBuilder(
      stream: FirebaseFirestore.instance.collection('IRLSuperstars').snapshots(),
      builder : (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        return DropdownButton(
          hint: Text('Superstar 9'),
          value: s9 == "" ? null : s9,
          items:
          snapshot.data?.docs.map((DocumentSnapshot document){
            return DropdownMenuItem(
              value: '${document['prenom']} ${document['nom']}',
              child: Text('${document['prenom']} ${document['nom']}'),
            );
          }).toList(),
          onChanged: onChangedS9,
        );
      });

    Widget buildS10() => StreamBuilder(
      stream: FirebaseFirestore.instance.collection('IRLSuperstars').snapshots(),
      builder : (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        return DropdownButton(
          hint: Text('Superstar 10'),
          value: s10 == "" ? null : s10,
          items:
          snapshot.data?.docs.map((DocumentSnapshot document){
            return DropdownMenuItem(
              value: '${document['prenom']} ${document['nom']}',
              child: Text('${document['prenom']} ${document['nom']}'),
            );
          }).toList(),
          onChanged: onChangedS10,
        );
      });

    Widget buildGagnant() => StreamBuilder(
      stream: FirebaseFirestore.instance.collection('IRLSuperstars').snapshots(),
      builder : (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        return DropdownButton(
          hint: Text('Gagnant'),
          value: gagnant == "" ? null : gagnant,
          items:
          snapshot.data?.docs.map((DocumentSnapshot document){
            return DropdownMenuItem(
              value: '${document['prenom']} ${document['nom']}',
              child: Text('${document['prenom']} ${document['nom']}'),
            );
          }).toList(),
          onChanged: onChangedGagnant,
        );
      });
}