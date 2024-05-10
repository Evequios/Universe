import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/Superstars.dart';

Superstars defaultSup = const Superstars(name: 'name', brand: 0, orientation: 'orientation', ally1: 0, ally2: 0, ally3: 0, ally4: 0, ally5: 0, rival1: 0, rival2: 0, rival3: 0, rival4: 0, rival5: 0, division: 0);

class TeamsFormWidget extends StatelessWidget {
  final List<Superstars>? listSuperstars;
  final String? name;
  final int? m1;
  final int? m2;
  final int? m3;
  final int? m4;
  final int? m5;
  final ValueChanged<String?> onChangedName;
  final ValueChanged<int?> onChangedM1;
  final ValueChanged<int?> onChangedM2;
  final ValueChanged<int?> onChangedM3;
  final ValueChanged<int?> onChangedM4;
  final ValueChanged<int?> onChangedM5;

  const TeamsFormWidget({
    Key? key,
    required this.listSuperstars,
    this.name = '',
    this.m1,
    this.m2,
    this.m3,
    this.m4,
    this.m5,
    required this.onChangedName,
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
          buildName(),
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

  Widget buildName() => TextFormField(
    textCapitalization: TextCapitalization.sentences,
    initialValue: name,
    style: const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 18,
    ),
    decoration: InputDecoration(
      labelText: "Name",
      labelStyle: TextStyle(color: Colors.black87.withOpacity(0.5), fontSize: 18, ),
      border: const OutlineInputBorder(),
    ),
    validator: (name) =>
        name != null && name.isEmpty ? "The name can't be empty" : null,
    onChanged: onChangedName,
  );


  Widget buildM1() => 
  ButtonTheme( 
    alignedDropdown: true, 
    child: DropdownButtonFormField(
      decoration: InputDecoration(
      border: const OutlineInputBorder(),
        labelText: 'Member 1',
        labelStyle: TextStyle(color: Colors.black87.withOpacity(0.5)),
    ),
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
        decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: 'Member 2',
        labelStyle: TextStyle(color: Colors.black87.withOpacity(0.5)),
      ),
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
        decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: 'Member 3',
        labelStyle: TextStyle(color: Colors.black87.withOpacity(0.5)),
      ),
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
      decoration: InputDecoration(
      border: const OutlineInputBorder(),
        labelText: 'Member 4',
        labelStyle: TextStyle(color: Colors.black87.withOpacity(0.5)),
    ),
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
      decoration: InputDecoration(
      border: const OutlineInputBorder(),
        labelText: 'Member 5',
        labelStyle: TextStyle(color: Colors.black87.withOpacity(0.5)),
    ),
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