import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/Universe/UniverseBrands.dart';
import 'package:wwe_universe/classes/Universe/UniverseSuperstars.dart';

UniverseBrands defaultBrand = const UniverseBrands(name: 'nom');
UniverseSuperstars defaultSup = const UniverseSuperstars(name: 'nom', brand: 0, orientation: 'orientation', ally1: 0, ally2: 0, ally3: 0, ally4: 0, ally5: 0, rival1: 0, rival2: 0, rival3: 0, rival4: 0, rival5: 0);
List<bool> listTag = [false, true];

bool disable(int tag){
 return tag == 0 ? true : false;
}

class UniverseTitlesFormWidget extends StatelessWidget {
  final List<UniverseSuperstars>? listSuperstars;
  final List<UniverseBrands>? listBrands;
  final String? name;
  final int? brand;
  final int? tag;
  final int? holder1;
  final int? holder2;
  final ValueChanged<String?> onChangedName;
  final ValueChanged<int?> onChangedBrand;
  final ValueChanged<int?> onChangedTag;
  final ValueChanged<int?> onChangedHolder1; 
  final ValueChanged<int?> onChangedHolder2;


  const UniverseTitlesFormWidget({
    Key? key,
    required this.listBrands,
    required this.listSuperstars,
    this.name = '',
    this.brand,
    this.tag,
    this.holder1,
    this.holder2,
    required this.onChangedName,
    required this.onChangedBrand,
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
          buildName(),
          const SizedBox(height: 8),
          buildBrand(),
          const SizedBox(height: 16),
          buildTag(),
          const SizedBox(height: 8),
          buildHolder1(),
          buildHolder2(),
        ],
      ),
    ),
  );

  Widget buildName() => TextFormField(
    initialValue: name,
    style: const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 24,
    ),
    decoration: const InputDecoration(
      border: InputBorder.none,
      hintText: 'Name',
    ),
    validator: (name) =>
        name != null && name.isEmpty ? "The name can't be empty" : null,
    onChanged: onChangedName,
  );


  Widget buildBrand() => 
    ButtonTheme( 
      alignedDropdown: true, 
      child: DropdownButtonFormField(
        decoration: const InputDecoration(
        labelText: 'Brand : ',
        labelStyle: TextStyle(decoration: TextDecoration.underline, color: Colors.black),
      ),
        hint : const Text("Brand"),
        value: brand != 0 ? brand : defaultBrand.id,
        onChanged: onChangedBrand,
        items: listBrands!.map((brand){
        return DropdownMenuItem(
          value: brand.id,
          child: Text(brand.name));
      }).toList(),
      ),
    );

    Widget buildTag() => 
    ButtonTheme( 
      alignedDropdown: true, 
      child: DropdownButtonFormField(
        decoration: const InputDecoration(
        labelText: 'Title type : ',
        labelStyle: TextStyle(decoration: TextDecoration.underline, color: Colors.black),
      ),
        hint : const Text("Title type"),
        value: tag,
        onChanged: onChangedTag,
        items: listTag.map((tag){
        return DropdownMenuItem(
          value: tag ? 1 : 0,
          child: tag ? const Text('Tag') : const Text('Solo'));
      }).toList(),
      ),
    );


    Widget buildHolder1() => 
    ButtonTheme( 
      alignedDropdown: true, 
      child: DropdownButtonFormField(
        decoration: const InputDecoration(
        labelText: 'Holder 1 : ',
        labelStyle: TextStyle(decoration: TextDecoration.underline, color: Colors.black),
      ),
        hint : const Text("Holder 1"),
        value: holder1 != 0 ? holder1 : defaultSup.id,
        onChanged: onChangedHolder1,
        items: listSuperstars!.map((holder1){
        return DropdownMenuItem(
          value: holder1.id,
          child: Text(holder1.name));
      }).toList(),
      ),
    );



    Widget buildHolder2() => 
    ButtonTheme( 
      alignedDropdown: true, 
      child: DropdownButtonFormField(
        decoration: const InputDecoration(
        labelText: 'Holder 2 : ',
        labelStyle: TextStyle(decoration: TextDecoration.underline, color: Colors.black),
      ),
        hint : const Text("Holder 2"),
        value: holder2 != 0 ? holder2 : defaultSup.id,
        onChanged: onChangedHolder2,
        items : disable(tag!) ? null : listSuperstars!.map((holder2){
        return DropdownMenuItem(
          value: holder2.id,
          child: Text(holder2.name));
      }).toList(),
      ),
    );
}