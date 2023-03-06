import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/Universe/UniverseSuperstars.dart';

UniverseSuperstars defaultSup = const UniverseSuperstars(name: 'nom', brand: 0, orientation: 'orientation', ally1: 0, ally2: 0, ally3: 0, ally4: 0, ally5: 0, rival1: 0, rival2: 0, rival3: 0, rival4: 0, rival5: 0);

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
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildNom(),
          const SizedBox(height: 8),
          buildM1(),
          const SizedBox(height: 8),
          buildM2(),
          const SizedBox(height: 8),
          buildM3(),
          const SizedBox(height: 8),
          buildM4(),
          const SizedBox(height: 8),
          buildM5(),
          const SizedBox(height: 8),
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
      decoration: const InputDecoration(
      labelText: 'Member 1 : ',
      labelStyle: TextStyle(decoration: TextDecoration.underline, color: Colors.black),
    ),
      hint : const Text("Member 1"),
      value: m1 != 0 ? m1 : defaultSup.id,
      onChanged: onChangedM1,
      items: listSuperstars!.map((m1){
      return DropdownMenuItem(
        value: m1.id,
        child: Text(m1.name));
    }).toList(),
    ),
  );

  Widget buildM2() => 
    ButtonTheme( 
      alignedDropdown: true, 
      child: DropdownButtonFormField(
        decoration: const InputDecoration(
        labelText: 'Member 2 : ',
        labelStyle: TextStyle(decoration: TextDecoration.underline, color: Colors.black),
      ),
        hint : const Text("Member 2"),
        value: m2 != 0 ? m2 : defaultSup.id,
        onChanged: onChangedM2,
        items: listSuperstars!.map((m2){
        return DropdownMenuItem(
          value: m2.id,
          child: Text(m2.name));
      }).toList(),
      ),
    );


    Widget buildM3() => 
    ButtonTheme( 
      alignedDropdown: true, 
      child: DropdownButtonFormField(
        decoration: const InputDecoration(
        labelText: 'Member 3 : ',
        labelStyle: TextStyle(decoration: TextDecoration.underline, color: Colors.black),
      ),
        hint : const Text("Member 3"),
        value: m3 != 0 ? m3 : defaultSup.id,
        onChanged: onChangedM3,
        items: m1 != 0 && m2 != 0 ? listSuperstars!.map((m3){
        return DropdownMenuItem(
          value: m3.id,
          child: Text(m3.name));
      }).toList() : null,
      ),
    );


  Widget buildM4() => 
  ButtonTheme( 
    alignedDropdown: true, 
    child: DropdownButtonFormField(
      decoration: const InputDecoration(
      labelText: 'Member 4 : ',
      labelStyle: TextStyle(decoration: TextDecoration.underline, color: Colors.black),
    ),
      hint : const Text("Member 4"),
      value: m4 != 0 ? m4 : defaultSup.id,
      onChanged: onChangedM4,
      items: m3 == 0 ? null : listSuperstars!.map((m4){
      return DropdownMenuItem(
        value: m4.id,
        child: Text(m4.name));
    }).toList(),
    ),
  );

  Widget buildM5() => 
  ButtonTheme( 
    alignedDropdown: true, 
    child: DropdownButtonFormField(
      decoration: const InputDecoration(
      labelText: 'Member 5 : ',
      labelStyle: TextStyle(decoration: TextDecoration.underline, color: Colors.black),
    ),
      hint : const Text("Member 5"),
      value: m5 != 0 ? m5 : defaultSup.id,
      onChanged: onChangedM5,
      items: m4 == 0 ? null : listSuperstars!.map((m5){
      return DropdownMenuItem(
        value: m5.id,
        child: Text(m5.name));
    }).toList(),
    ),
  );
}