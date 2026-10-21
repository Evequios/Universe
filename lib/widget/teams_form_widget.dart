import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/superstars.dart';

Superstars defaultSup = const Superstars(name: 'name', brand: null, orientation: 'orientation',division: 0);

class TeamsFormWidget extends StatelessWidget {
  final List<Superstars>? listSuperstars;
  final String? name;
  final Superstars? m1;
  final Superstars? m2;
  final Superstars? m3;
  final Superstars? m4;
  final Superstars? m5;
  final ValueChanged<String?> onChangedName;
  final ValueChanged<Superstars?> onChangedM1;
  final ValueChanged<Superstars?> onChangedM2;
  final ValueChanged<Superstars?> onChangedM3;
  final ValueChanged<Superstars?> onChangedM4;
  final ValueChanged<Superstars?> onChangedM5;

  const TeamsFormWidget({
    super.key,
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
  });

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
    child: DropdownButtonFormField<Superstars>(
      decoration: InputDecoration(
      border: const OutlineInputBorder(),
        labelText: 'Member 1',
        labelStyle: TextStyle(color: Colors.black87.withOpacity(0.5)),
    ),
      value: m1 ?? defaultSup,
      onChanged: onChangedM1,
      items: listSuperstars!.map((m1){
      return DropdownMenuItem(
        value: m1,
        child: Text(m1.name));
    }).toList(),
    ),
  );

  Widget buildM2() => 
    ButtonTheme( 
    alignedDropdown: true, 
    child: DropdownButtonFormField<Superstars>(
      decoration: InputDecoration(
      border: const OutlineInputBorder(),
        labelText: 'Member 2',
        labelStyle: TextStyle(color: Colors.black87.withOpacity(0.5)),
    ),
      value: m2 ?? defaultSup,
      onChanged: onChangedM2,
      items: listSuperstars!.map((m2){
      return DropdownMenuItem(
        value: m2,
        child: Text(m2.name));
    }).toList(),
    ),
  );


    Widget buildM3() => 
    ButtonTheme( 
    alignedDropdown: true, 
    child: DropdownButtonFormField<Superstars>(
      decoration: InputDecoration(
      border: const OutlineInputBorder(),
        labelText: 'Member 3',
        labelStyle: TextStyle(color: Colors.black87.withOpacity(0.5)),
    ),
      value: m3 ?? defaultSup,
      onChanged: onChangedM3,
      items: listSuperstars!.map((m3){
      return DropdownMenuItem(
        value: m3,
        child: Text(m3.name));
    }).toList(),
    ),
  );


  Widget buildM4() => 
  ButtonTheme( 
    alignedDropdown: true, 
    child: DropdownButtonFormField<Superstars>(
      decoration: InputDecoration(
      border: const OutlineInputBorder(),
        labelText: 'Member 4',
        labelStyle: TextStyle(color: Colors.black87.withOpacity(0.5)),
    ),
      value: m4 ?? defaultSup,
      onChanged: onChangedM4,
      items: listSuperstars!.map((m4){
      return DropdownMenuItem(
        value: m4,
        child: Text(m4.name));
    }).toList(),
    ),
  );

  Widget buildM5() => 
  ButtonTheme( 
    alignedDropdown: true, 
    child: DropdownButtonFormField<Superstars>(
      decoration: InputDecoration(
      border: const OutlineInputBorder(),
        labelText: 'Member 5',
        labelStyle: TextStyle(color: Colors.black87.withOpacity(0.5)),
    ),
      value: m5 ?? defaultSup,
      onChanged: onChangedM5,
      items: listSuperstars!.map((m5){
      return DropdownMenuItem(
        value: m5,
        child: Text(m5.name));
    }).toList(),
    ),
  );
}