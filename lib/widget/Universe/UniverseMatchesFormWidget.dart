import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/Universe/UniverseStipulations.dart';
import 'package:wwe_universe/classes/Universe/UniverseSuperstars.dart';
import 'package:wwe_universe/database.dart';

UniverseStipulations defaultStip = UniverseStipulations(type: 'type', stipulation: 'stipulation');
UniverseSuperstars defaultSup = UniverseSuperstars(nom: 'nom', show: 'show', orientation: 'orientation');
late UniverseStipulations stip = UniverseStipulations(type: 'type', stipulation: 'stipulation');
Future getDetails(id) async {
  stip = await UniverseDatabase.instance.readStipulation(id);
  
}

bool disable(int nb){
  switch(nb){
    case 1 : 
      return false;
    case 2 :
      return false;
    case 3 :
      return stip.type == '1v1' ? true : false;
    case 4 :
      return stip.type == '1v1' || stip.type == 'Triple Threat' ? true : false;
    case 5 :
      return stip.type == '1v1' || stip.type == 'Triple Threat' || stip.type == '2v2' || stip.type == 'Fatal 4-Way' ? true : false;
    case 6 :
      return stip.type == '1v1' || stip.type == 'Triple Threat' || stip.type == '2v2' || stip.type == 'Fatal 4-Way' || stip.type == '5-Way' ? true : false;
    case 7 :
      return stip.type == '1v1' || stip.type == 'Triple Threat' || stip.type == '2v2' || stip.type == 'Fatal 4-Way' || stip.type == '5-Way' || stip.type == '3v3' || stip.type == '2v2v2' || stip.type == '6-Way' ? true : false;
    case 8 :
      return stip.type == '1v1' || stip.type == 'Triple Threat' || stip.type == '2v2' || stip.type == 'Fatal 4-Way' || stip.type == '5-Way' || stip.type == '3v3' || stip.type == '2v2v2' || stip.type == '6-Way' ? true : false;
    default :
      return true;
    
  }
}


class UniverseMatchesFormWidget extends StatelessWidget {
  final List<UniverseStipulations>? listStipulations;
  final List<UniverseSuperstars>? listSuperstars;
  final int? stipulation;
  final int? s1;
  final int? s2;
  final int? s3;
  final int? s4;
  final int? s5;
  final int? s6;
  final int? s7;
  final int? s8;
  int? gagnant;
  final int? ordre;
  final int? showId;
  final ValueChanged<int?> onChangedStipulation;
  final ValueChanged<int?> onChangedS1;
  final ValueChanged<int?> onChangedS2;
  final ValueChanged<int?> onChangedS3;
  final ValueChanged<int?> onChangedS4;
  final ValueChanged<int?> onChangedS5;
  final ValueChanged<int?> onChangedS6;
  final ValueChanged<int?> onChangedS7;
  final ValueChanged<int?> onChangedS8;
  final ValueChanged<int?> onChangedGagnant;
  final ValueChanged<String?> onChangedOrdre;

  UniverseMatchesFormWidget({
    Key? key,
    required this.listStipulations,
    required this.listSuperstars,
    this.stipulation,
    this.s1,
    this.s2,
    this.s3,
    this.s4,
    this.s5,
    this.s6,
    this.s7,
    this.s8,
    this.gagnant,
    this.ordre,
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
    required this.onChangedGagnant,
    required this.onChangedOrdre,
  }) : super(key: key);
  
  bool validateWinner() {
    switch (stip.type){
    case '1v1' : 
      if(gagnant != s1 && gagnant != s2)
          return false;
      else
          return true;
    case 'Triple Threat':
      if(gagnant != s1 && gagnant != s2 && gagnant != s3)
          return false;
      else
          return true;
    case '2v2' :
      if(gagnant != s1 && gagnant != s2 && gagnant != s3 && gagnant != s4)
          return false;
      else
          return true;
    case 'Fatal 4-Way' :
      if(gagnant != s1 && gagnant != s2 && gagnant != s3 && gagnant != s4)
          return false;
      else
          return true;
    case '5-Way' :
      if(gagnant != s1 && gagnant != s2 && gagnant != s3 && gagnant != s4 && gagnant != s5)
          return false;
      else
          return true;
    case '3v3' :
      if(gagnant != s1 && gagnant != s2 && gagnant != s3 && gagnant != s4 && gagnant != s5 && gagnant != s6)
          return false;
      else
          return true;
    case '2v2v2' :
      if(gagnant != s1 && gagnant != s2 && gagnant != s3 && gagnant != s4 && gagnant != s5 && gagnant != s6)
          return false;
      else
          return true;
    case '6-Way' :
      if(gagnant != s1 && gagnant != s2 && gagnant != s3 && gagnant != s4 && gagnant != s5 && gagnant != s6)
          return false;
      else
          return true;
    case '8-Way' :
      if(gagnant != s1 && gagnant != s2 && gagnant != s3 && gagnant != s4 && gagnant != s5 && gagnant != s6 && gagnant != s7 && gagnant != s8)
          return false;
      else
          return true;
    default :
      return false;
    }
  }
  
  @override
  Widget build(BuildContext context){
  print("S1 : " + s1.toString());
  print("S2 : " + s2.toString());
  print("stipulation : " + stipulation.toString());
  print("Gagnant : " + gagnant.toString());
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

  Widget buildStipulation() => 
    ButtonTheme( 
      alignedDropdown: true, 
      child: DropdownButtonFormField(
        decoration: InputDecoration(
        labelText: 'Stipulation: ',
        labelStyle: TextStyle(decoration: TextDecoration.underline, color: Colors.black),
      ),
        hint : Text("Stipulation"),
        value: stipulation != 0 ? stipulation : defaultStip.id,
        onChanged: onChangedStipulation,
        items: listStipulations!.map((stipulation){
        return DropdownMenuItem(
          value: stipulation.id,
          child: Text('${stipulation.type} ${stipulation.stipulation}'),
        );
      }).toList(),
      validator: (stipulation) =>
           stipulation == null ? "Please choose a match type" : null
      ),);


  Widget buildS1() => 
    ButtonTheme( 
      alignedDropdown: true, 
      child: DropdownButtonFormField(
        decoration: InputDecoration(
        labelText: 'Superstar 1 : ',
        labelStyle: TextStyle(decoration: TextDecoration.underline, color: Colors.black),
      ),
        hint : Text("Superstar 1"),
        value: s1 != 0 ? s1 : defaultSup.id,
        // value: s1 != 0 ? s1 : listSuperstars![0].id,
        onChanged: onChangedS1,
        items: disable(1) ? null : listSuperstars!.map((s1){
        return DropdownMenuItem(
          // value: s1.id != 0 ? s1.id : listSuperstars![0].id,
          value: s1.id,
          child: Text(s1.nom));
      }).toList(),
      validator: (s1) =>
           s1 == null ? "Please choose a superstar" : null
      ),);

  Widget buildS2() => 
    ButtonTheme( 
      alignedDropdown: true, 
      child: DropdownButtonFormField(
        decoration: InputDecoration(
        labelText: 'Superstar 2 : ',
        labelStyle: TextStyle(decoration: TextDecoration.underline, color: Colors.black),
      ),
        hint : Text("Superstar 2"),
        value: s2 != 0 ? s2 : defaultSup.id,
        // value: s2 != 0 ? s2 : listSuperstars![0].id,
        onChanged: onChangedS2,
        items: disable(2) ? null : listSuperstars!.map((s2){
        return DropdownMenuItem(
          // value: s2.id != 0 ? s2.id : listSuperstars![1].id,
          value: s2.id,
          child: Text(s2.nom));
      }).toList(),
      validator: (s2) =>
           s2 == null ? "Please choose a superstar" : null
      ),);


    Widget buildS3() => 
    ButtonTheme( 
      alignedDropdown: true, 
      child: DropdownButtonFormField(
        decoration: InputDecoration(
        labelText: 'Superstar 3 : ',
        labelStyle: TextStyle(decoration: TextDecoration.underline, color: Colors.black),
      ),
        hint : Text("Superstar 3"),
        // value: s3 != 0 ? s3 : listSuperstars![0].id,
        onChanged: onChangedS3,
        items: disable(3) ? null : listSuperstars!.map((s3){
        return DropdownMenuItem(
          value: s3.id,
          child: Text(s3.nom));
      }).toList(),
      ),);

    Widget buildS4() {
      return
    ButtonTheme( 
      alignedDropdown: true, 
      child: DropdownButtonFormField(
        decoration: InputDecoration(
        labelText: 'Superstar 4 : ',
        labelStyle: TextStyle(decoration: TextDecoration.underline, color: Colors.black),
      ),
        hint : Text("Superstar 4"),
        // value: s4 != 0 ? s4 : listSuperstars![0].id,
        onChanged: onChangedS4,
        items: disable(4) ? null : listSuperstars!.map((s4){
        return DropdownMenuItem(
          value: s4.id,
          child: Text(s4.nom));
      }).toList(),
      ),);
    }

  Widget buildS5() => 
    ButtonTheme( 
      alignedDropdown: true, 
      child: DropdownButtonFormField(
        decoration: InputDecoration(
        labelText: 'Superstar 5 : ',
        labelStyle: TextStyle(decoration: TextDecoration.underline, color: Colors.black),
      ),
        hint : Text("Superstar 5"),
        // value: s4 != 0 ? s4 : listSuperstars![0].id,
        onChanged: onChangedS5,
        items: disable(5) ? null : listSuperstars!.map((s5){
        return DropdownMenuItem(
          value: s5.id,
          child: Text(s5.nom));
      }).toList(),
      ),);

      Widget buildS6() => 
    ButtonTheme( 
      alignedDropdown: true, 
      child: DropdownButtonFormField(
        decoration: InputDecoration(
        labelText: 'Superstar 6 : ',
        labelStyle: TextStyle(decoration: TextDecoration.underline, color: Colors.black),
      ),
        hint : Text("Superstar 6"),
        // value: s4 != 0 ? s4 : listSuperstars![0].id,
        onChanged: onChangedS6,
        items: disable(6) ? null : listSuperstars!.map((s6){
        return DropdownMenuItem(
          value: s6.id,
          child: Text(s6.nom));
      }).toList(),
      ),);

    Widget buildS7() => 
    ButtonTheme( 
      alignedDropdown: true, 
      child: DropdownButtonFormField(
        decoration: InputDecoration(
        labelText: 'Superstar 7 : ',
        labelStyle: TextStyle(decoration: TextDecoration.underline, color: Colors.black),
      ),
        hint : Text("Superstar 7"),
        // value: s4 != 0 ? s4 : listSuperstars![0].id,
        onChanged: onChangedS7,
        items: disable(7) ? null : listSuperstars!.map((s7){
        return DropdownMenuItem(
          value: s7.id,
          child: Text(s7.nom));
      }).toList(),
      ),);

    Widget buildS8() => 
    ButtonTheme( 
      alignedDropdown: true, 
      child: DropdownButtonFormField(
        decoration: InputDecoration(
        labelText: 'Superstar 8 : ',
        labelStyle: TextStyle(decoration: TextDecoration.underline, color: Colors.black),
      ),
        hint : Text("Superstar 8"),
        // value: s4 != 0 ? s4 : listSuperstars![0].id,
        onChanged: onChangedS8,
        items: disable(8) ? null : listSuperstars!.map((s8){
        return DropdownMenuItem(
          value: s8.id,
          child: Text(s8.nom));
      }).toList(),
      ),);

Widget buildGagnant() => 
    ButtonTheme( 
      alignedDropdown: true, 
      child: DropdownButtonFormField(
        decoration: InputDecoration(
        labelText: 'Gagnant : ',
        labelStyle: TextStyle(decoration: TextDecoration.underline, color: Colors.black),
      ),
        hint : Text("Gagnant"),
        value: gagnant != 0 ? gagnant : defaultSup.id,
        // value: gagnant != 0 ? gagnant : listSuperstars![0].id,
        onChanged: onChangedGagnant,
        items: listSuperstars!.map((gagnant){
        return DropdownMenuItem(
          value: gagnant.id,
          child: Text(gagnant.nom));
      }).toList(),
      validator: (gagnant) => validateWinner() ? null : "The winner must be in the match",
      // validator: (gagnant) {
      //     //  (gagnant != s1 && gagnant != s2
      //     //   && gagnant != s3 && gagnant != s4
      //     //   && gagnant != s5 && gagnant != s6
      //     //   && gagnant != s7 && gagnant != s8) || 
      //     gagnant == 0
      //       ? "Le gagnant doit être un participant du match" : null;
      //   }
      ),);
      //check si le gagnant peut pas être dans un champ disabled

   Widget buildOrdre() => TextFormField(
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
            int.parse(ordre!) != null && ordre.isEmpty ? "L'ordre" : null,
        onChanged: onChangedOrdre,
      );
}