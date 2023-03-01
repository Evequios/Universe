import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
  final String? ordre;
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
  final ValueChanged<String?> onChangedOrdre;


  IRLMatchesFormWidget({
    Key? key,
    this.stipulation,
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
    this.ordre= '',
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
    required this.onChangedOrdre,
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
              SizedBox(height: 8,),
              buildS1(),
              SizedBox(height: 8,),
              buildS2(),
              SizedBox(height: 8,),
              buildS3(),
              SizedBox(height: 8,),
              buildS4(),
              SizedBox(height: 8,),
              buildS5(),
              SizedBox(height: 8,),
              buildS6(),
              SizedBox(height: 8,),
              buildS7(),
              SizedBox(height: 8,),
              buildS8(),
              SizedBox(height: 8,),
              buildS9(),
              SizedBox(height: 8,),
              buildS10(),
              SizedBox(height: 8,),
              buildGagnant(),
              SizedBox(height: 8,),
              buildOrdre(),
            ],
          ),
        ),
      )
    )
  );
  }

  Widget buildStipulation() => StreamBuilder(
    stream: FirebaseFirestore.instance.collection('IRLStipulations').orderBy('stipulation').snapshots(),
    builder : (context, AsyncSnapshot<QuerySnapshot> snapshot) {
    return ButtonTheme( 
      alignedDropdown: true, 
      child: DropdownButtonFormField(
        decoration: InputDecoration(
        labelText: 'Stipulation : ',
        labelStyle: TextStyle(decoration: TextDecoration.underline, color: Colors.black),
      ),
        // hint: Text('Stipulation'),
        value: stipulation == "" ? null : stipulation,
        items:
          snapshot.data?.docs.map((DocumentSnapshot document){
            return DropdownMenuItem(
              value: '${document['type']} ${document['stipulation']}',
              child: Text('${document['type']} ${document['stipulation']}'),
            );
          }).toList(),
        onChanged: 
        onChangedStipulation,
      )
    );
  });

  Widget buildS1() => StreamBuilder(
    stream: FirebaseFirestore.instance.collection('IRLSuperstars').orderBy('prenom').snapshots(),
    builder : (context, AsyncSnapshot<QuerySnapshot> snapshot) {
    return ButtonTheme(
      alignedDropdown: true, 
      child : DropdownButtonFormField(
        isExpanded: true,
        decoration: InputDecoration(
          labelText: 'Superstar 1 : ',
          labelStyle: TextStyle(decoration: TextDecoration.underline, color: Colors.black),
        ),
      // hint: Text('Superstar 1'),
      value: s1 == "" ? null : s1,
      items:
        snapshot.data?.docs.map((DocumentSnapshot document){
          return DropdownMenuItem(
            value: '${document['prenom']} ${document['nom']}',
            child: Text('${document['prenom']} ${document['nom']}'),
          );
        }).toList(),
      onChanged: onChangedS1,
      menuMaxHeight: 500,
      )
    );
  });

      Widget buildS2() => StreamBuilder(
      stream: FirebaseFirestore.instance.collection('IRLSuperstars').orderBy('prenom').snapshots(),
      builder : (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        return ButtonTheme(alignedDropdown: true, child: DropdownButtonFormField(
          isExpanded: true,
          decoration: InputDecoration(
            labelText: 'Superstar 2 : ',
            labelStyle: TextStyle(decoration: TextDecoration.underline, color: Colors.black),
          ),
          // hint: Text('Superstar 2'),
          value: s2 == "" ? null : s2,
          items:
          snapshot.data?.docs.map((DocumentSnapshot document){
            return DropdownMenuItem(
              value: '${document['prenom']} ${document['nom']}',
              child: Text('${document['prenom']} ${document['nom']}'),
            );
          }).toList(),
          onChanged: onChangedS2,
          menuMaxHeight: 500,
        ));
      });

    Widget buildS3() => StreamBuilder(
      stream: FirebaseFirestore.instance.collection('IRLSuperstars').orderBy('prenom').snapshots(),
      builder : (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if(!stipulation!.contains('1v1')){
        return ButtonTheme(alignedDropdown: true, child: DropdownButtonFormField(
          isExpanded: true,
          decoration: InputDecoration(
            labelText: 'Superstar 3 : ',
            labelStyle: TextStyle(decoration: TextDecoration.underline, color: Colors.black),
          ),
          // hint: Text('Superstar 3'),
          value: s3 == "" ? null : s3,
          items:
          snapshot.data?.docs.map((DocumentSnapshot document){
            return DropdownMenuItem(
              value: '${document['prenom']} ${document['nom']}',
              child: Text('${document['prenom']} ${document['nom']}'),
            );
          }).toList(),
          onChanged: onChangedS3,
          menuMaxHeight: 500,
        ));}
        else return SizedBox(height: 0);
      });
  
    Widget buildS4() => StreamBuilder(
      stream: FirebaseFirestore.instance.collection('IRLSuperstars').orderBy('prenom').snapshots(),
      builder : (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if((!stipulation!.contains('1v1')) && !stipulation!.contains('Triple Threat')){
        return ButtonTheme(alignedDropdown: true, child: DropdownButtonFormField(
          isExpanded: true,
          decoration: InputDecoration(
            labelText: 'Superstar 4 : ',
            labelStyle: TextStyle(decoration: TextDecoration.underline, color: Colors.black),
          ),
          // hint: Text('Superstar 4'),
          value: s4 == "" ? null : s4,
          items:
          snapshot.data?.docs.map((DocumentSnapshot document){
            return DropdownMenuItem(
              value: '${document['prenom']} ${document['nom']}',
              child: Text('${document['prenom']} ${document['nom']}'),
            );
          }).toList(),
          onChanged: onChangedS4,
          menuMaxHeight: 500,
        ));}
        else return SizedBox(height: 0,);
      });

    Widget buildS5() => StreamBuilder(
      stream: FirebaseFirestore.instance.collection('IRLSuperstars').orderBy('prenom').snapshots(),
      builder : (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if((!stipulation!.contains('1v1')) && !stipulation!.contains('Triple Threat') && !stipulation!.contains('2v2') && !stipulation!.contains('Fatal 4-Way')){
        return ButtonTheme(alignedDropdown: true, child: DropdownButtonFormField(
          isExpanded: true,
          decoration: InputDecoration(
            labelText: 'Superstar 5 : ',
            labelStyle: TextStyle(decoration: TextDecoration.underline, color: Colors.black),
          ),
          // hint: Text('Superstar 5'),
          value: s5 == "" ? null : s5,
          items:
          snapshot.data?.docs.map((DocumentSnapshot document){
            return DropdownMenuItem(
              value: '${document['prenom']} ${document['nom']}',
              child: Text('${document['prenom']} ${document['nom']}'),
            );
          }).toList(),
          onChanged: onChangedS5,
          menuMaxHeight: 500,
        ));}
        else return SizedBox(height: 0,);
      });

    Widget buildS6() => StreamBuilder(
      stream: FirebaseFirestore.instance.collection('IRLSuperstars').orderBy('prenom').snapshots(),
      builder : (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if((!stipulation!.contains('1v1')) && !stipulation!.contains('Triple Threat') && !stipulation!.contains('2v2') && !stipulation!.contains('Fatal 4-Way')){
        return ButtonTheme(alignedDropdown: true, child: DropdownButtonFormField(
          isExpanded: true,
          decoration: InputDecoration(
            labelText: 'Superstar 6 : ',
            labelStyle: TextStyle(decoration: TextDecoration.underline, color: Colors.black),
          ),
          // hint: Text('Superstar 6'),
          value: s6 == "" ? null : s6,
          items:
          snapshot.data?.docs.map((DocumentSnapshot document){
            return DropdownMenuItem(
              value: '${document['prenom']} ${document['nom']}',
              child: Text('${document['prenom']} ${document['nom']}'),
            );
          }).toList(),
          onChanged: onChangedS6,
          menuMaxHeight: 500,
        ));}
        else return SizedBox(height: 0);
      });

    Widget buildS7() => StreamBuilder(
      stream: FirebaseFirestore.instance.collection('IRLSuperstars').orderBy('prenom').snapshots(),
      builder : (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if((!stipulation!.contains('1v1')) && !stipulation!.contains('Triple Threat') && !stipulation!.contains('2v2') && !stipulation!.contains('Fatal 4-Way') && !stipulation!.contains('3v3') && !stipulation!.contains('2v2v2')){
        return ButtonTheme(alignedDropdown: true, child: DropdownButtonFormField(
          isExpanded: true,
          decoration: InputDecoration(
            labelText: 'Superstar 7 : ',
            labelStyle: TextStyle(decoration: TextDecoration.underline, color: Colors.black),
          ),
          // hint: Text('Superstar 7'),
          value: s7 == "" ? null : s7,
          items:
          snapshot.data?.docs.map((DocumentSnapshot document){
            return DropdownMenuItem(
              value: '${document['prenom']} ${document['nom']}',
              child: Text('${document['prenom']} ${document['nom']}'),
            );
          }).toList(),
          onChanged: onChangedS7,
          menuMaxHeight: 500,
        ));}
        else return SizedBox(height:0);
      });

    Widget buildS8() => StreamBuilder(
      stream: FirebaseFirestore.instance.collection('IRLSuperstars').orderBy('prenom').snapshots(),
      builder : (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if((!stipulation!.contains('1v1')) && !stipulation!.contains('Triple Threat') && !stipulation!.contains('2v2') && !stipulation!.contains('Fatal 4-Way') && !stipulation!.contains('3v3') && !stipulation!.contains('2v2v2')){
        return ButtonTheme(alignedDropdown: true, child: DropdownButtonFormField(
          isExpanded: true,
          decoration: InputDecoration(
            labelText: 'Superstar 8 : ',
            labelStyle: TextStyle(decoration: TextDecoration.underline, color: Colors.black),
          ),
          // hint: Text('Superstar 8'),
          value: s8 == "" ? null : s8,
          items:
          snapshot.data?.docs.map((DocumentSnapshot document){
            return DropdownMenuItem(
              value: '${document['prenom']} ${document['nom']}',
              child: Text('${document['prenom']} ${document['nom']}'),
            );
          }).toList(),
          onChanged: onChangedS8,
          menuMaxHeight: 500,
        ));}
        else return SizedBox(height: 8,);
      });

  Widget buildS9() => StreamBuilder(
      stream: FirebaseFirestore.instance.collection('IRLSuperstars').orderBy('prenom').snapshots(),
      builder : (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if((!stipulation!.contains('1v1')) && !stipulation!.contains('Triple Threat') && !stipulation!.contains('2v2') && !stipulation!.contains('Fatal 4-Way') && !stipulation!.contains('3v3') && !stipulation!.contains('4v4')){
        return ButtonTheme(alignedDropdown: true, child: DropdownButtonFormField(
          isExpanded: true,
          decoration: InputDecoration(
            labelText: 'Superstar 9 : ',
            labelStyle: TextStyle(decoration: TextDecoration.underline, color: Colors.black),
          ),
          // hint: Text('Superstar 9'),
          value: s9 == "" ? null : s9,
          items:
          snapshot.data?.docs.map((DocumentSnapshot document){
            return DropdownMenuItem(
              value: '${document['prenom']} ${document['nom']}',
              child: Text('${document['prenom']} ${document['nom']}'),
            );
          }).toList(),
          onChanged: onChangedS9,
          menuMaxHeight: 500,
        ));}
        else return SizedBox(height: 0,);
      });

    Widget buildS10() => StreamBuilder(
      stream: FirebaseFirestore.instance.collection('IRLSuperstars').orderBy('prenom').snapshots(),
      builder : (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if(stipulation!.contains('5v5')){
        return ButtonTheme(alignedDropdown: true, child: DropdownButtonFormField(
          isExpanded: true,
          decoration: InputDecoration(
            labelText: 'Superstar 10 : ',
            labelStyle: TextStyle(decoration: TextDecoration.underline, color: Colors.black),
          ),
          // hint: Text('Superstar 10'),
          value: s10 == "" ? null : s10,
          items:
          snapshot.data?.docs.map((DocumentSnapshot document){
            return DropdownMenuItem(
              value: '${document['prenom']} ${document['nom']}',
              child: Text('${document['prenom']} ${document['nom']}'),
            );
          }).toList(),
          onChanged: onChangedS10,
          menuMaxHeight: 500,
        ));}
        else return SizedBox(height: 0,);
      });

  Widget buildGagnant() => StreamBuilder(
    stream: FirebaseFirestore.instance.collection('IRLSuperstars').orderBy('prenom').snapshots(),
    builder : (context, AsyncSnapshot<QuerySnapshot> snapshot) {
    return ButtonTheme(alignedDropdown: true, child: DropdownButtonFormField(
          isExpanded: true,
          decoration: InputDecoration(
            labelText: 'Gagnant : ',
            labelStyle: TextStyle(decoration: TextDecoration.underline, color: Colors.black),
          ),
          // hint: Text('Gagnant'),
          value: gagnant == "" ? null : gagnant,
          items:
          snapshot.data?.docs.map((DocumentSnapshot document){
            return DropdownMenuItem(
              value: '${document['prenom']} ${document['nom']}',
              child: Text('${document['prenom']} ${document['nom']}'),
            );
          }).toList(),
          onChanged: onChangedGagnant,
          menuMaxHeight: 500,
          validator: (gagnant) =>
            gagnant != null && gagnant != '' 
            && gagnant != s1 && gagnant != s2
            && gagnant != s3 && gagnant != s4
            && gagnant != s5 && gagnant != s6
            && gagnant != s7 && gagnant != s8
            && gagnant != s9 && gagnant != s10 ? "Le gagnant doit être un participant du match" : null,
        ));
      });

      Widget buildOrdre() => TextFormField(
        // maxLines: 1,
        initialValue: ordre.toString(),
        style: const TextStyle(
          // color: Colors.white70,
          fontWeight: FontWeight.bold,
          fontSize: 18
        ),
        decoration: const InputDecoration(
          labelText: 'Ordre : ',
          labelStyle: TextStyle(decoration: TextDecoration.underline, color: Colors.black),
          border: InputBorder.none,
          hintText: 'Match n°',
          // hintStyle: TextStyle(color: Colors.white70),
        ),
        validator: (ordre) =>
            ordre != null && ordre.isEmpty ? "L'ordre" : null,
        onChanged: onChangedOrdre,
      );
}