import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/Universe/UniverseBrands.dart';
import 'package:wwe_universe/classes/Universe/UniverseSuperstars.dart';

UniverseSuperstars defaultSup = UniverseSuperstars(nom: 'nom', brand: 0, orientation: 'orientation');

// bool disable(int tag){
//  return tag == 0 ? true : false;
// }

class UniverseTeamsFormWidget extends StatelessWidget {
  final List<UniverseSuperstars>? listSuperstars;
  final String? nom;
  final int? m1;
  final int? m2;
  final int? m3;
  final int? m4;
  final int? m5;
  final ValueChanged<String?> onChangedNom;
  final ValueChanged<int?> onChangedM1;
  final ValueChanged<int?> onChangedM2;
  final ValueChanged<int?> onChangedM3;
  final ValueChanged<int?> onChangedM4;
  final ValueChanged<int?> onChangedM5;

  const UniverseTeamsFormWidget({
    Key? key,
    required this.listSuperstars,
    this.nom = '',
    this.m1,
    this.m2,
    this.m3,
    this.m4,
    this.m5,
    required this.onChangedNom,
    required this.onChangedM1,
    required this.onChangedM2,
    required this.onChangedM3,
    required this.onChangedM4,
    required this.onChangedM5
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildNom(),
              SizedBox(height: 8),
              buildM1(),
              SizedBox(height: 8),
              buildM2(),
              SizedBox(height: 8),
              buildM3(),
              SizedBox(height: 8),
              buildM4(),
              SizedBox(height: 8),
              buildM5(),
              SizedBox(height: 8),
            ],
          ),
        ),
      );

  Widget buildNom() => TextFormField(
        initialValue: nom,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Name',
        ),
        validator: (nom) =>
            nom != null && nom.isEmpty ? "The name can't be empty" : null,
        onChanged: onChangedNom,
      );


    Widget buildM1() => 
    ButtonTheme( 
      alignedDropdown: true, 
      child: DropdownButtonFormField(
        decoration: InputDecoration(
        labelText: 'Member 1 : ',
        labelStyle: TextStyle(decoration: TextDecoration.underline, color: Colors.black),
      ),
        hint : Text("Member 1"),
        value: m1 != 0 ? m1 : defaultSup.id,
        onChanged: onChangedM1,
        items: listSuperstars!.map((m1){
        return DropdownMenuItem(
          // value: s1.id != 0 ? s1.id : listSuperstars![0].id,
          value: m1.id,
          child: Text(m1.nom));
      }).toList(),
      ),);

Widget buildM2() => 
    ButtonTheme( 
      alignedDropdown: true, 
      child: DropdownButtonFormField(
        decoration: InputDecoration(
        labelText: 'Member 2 : ',
        labelStyle: TextStyle(decoration: TextDecoration.underline, color: Colors.black),
      ),
        hint : Text("Member 2"),
        value: m2 != 0 ? m2 : defaultSup.id,
        onChanged: onChangedM2,
        items: listSuperstars!.map((m2){
        return DropdownMenuItem(
          // value: s1.id != 0 ? s1.id : listSuperstars![0].id,
          value: m2.id,
          child: Text(m2.nom));
      }).toList(),
      ),);


    Widget buildM3() => 
    ButtonTheme( 
      alignedDropdown: true, 
      child: DropdownButtonFormField(
        decoration: InputDecoration(
        labelText: 'Member 3 : ',
        labelStyle: TextStyle(decoration: TextDecoration.underline, color: Colors.black),
      ),
        hint : Text("Member 3"),
        value: m3 != 0 ? m3 : defaultSup.id,
        onChanged: onChangedM3,
        items: m1 != 0 && m2 != 0 ? listSuperstars!.map((m3){
        return DropdownMenuItem(
          value: m3.id,
          child: Text(m3.nom));
      }).toList() : null,
      ),);


    Widget buildM4() => 
    ButtonTheme( 
      alignedDropdown: true, 
      child: DropdownButtonFormField(
        decoration: InputDecoration(
        labelText: 'Member 4 : ',
        labelStyle: TextStyle(decoration: TextDecoration.underline, color: Colors.black),
      ),
        hint : Text("Member 4"),
        value: m4 != 0 ? m4 : defaultSup.id,
        onChanged: onChangedM4,
        items: m3 == 0 ? null : listSuperstars!.map((m4){
        return DropdownMenuItem(
          // value: s1.id != 0 ? s1.id : listSuperstars![0].id,
          value: m4.id,
          child: Text(m4.nom));
      }).toList(),
      ),);

    Widget buildM5() => 
    ButtonTheme( 
      alignedDropdown: true, 
      child: DropdownButtonFormField(
        decoration: InputDecoration(
        labelText: 'Member 5 : ',
        labelStyle: TextStyle(decoration: TextDecoration.underline, color: Colors.black),
      ),
        hint : Text("Member 5"),
        value: m5 != 0 ? m5 : defaultSup.id,
        onChanged: onChangedM5,
        items: m4 == 0 ? null : listSuperstars!.map((m5){
        return DropdownMenuItem(
          // value: s1.id != 0 ? s1.id : listSuperstars![0].id,
          value: m5.id,
          child: Text(m5.nom));
      }).toList(),
      ),);
}