import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/Universe/UniverseBrands.dart';
import 'package:wwe_universe/classes/Universe/UniverseSuperstars.dart';

UniverseBrands defaultBrand = UniverseBrands(nom: 'nom');
UniverseSuperstars defaultSup = UniverseSuperstars(nom: 'nom', brand: 0, orientation: 'orientation', rival1: 0);
List<bool> listTag = [false, true];

bool disable(int tag){
 return tag == 0 ? true : false;
}

class UniverseTitlesFormWidget extends StatelessWidget {
  final List<UniverseSuperstars>? listSuperstars;
  final List<UniverseBrands>? listBrands;
  final String? nom;
  final int? brand;
  final int? tag;
  final int? holder1;
  final int? holder2;
  final ValueChanged<String?> onChangedNom;
  final ValueChanged<int?> onChangedBrand;
  final ValueChanged<int?> onChangedTag;
  final ValueChanged<int?> onChangedHolder1; 
  final ValueChanged<int?> onChangedHolder2;


  const UniverseTitlesFormWidget({
    Key? key,
    required this.listBrands,
    required this.listSuperstars,
    this.nom = '',
    this.brand,
    this.tag,
    this.holder1,
    this.holder2,
    required this.onChangedNom,
    required this.onChangedBrand,
    required this.onChangedTag,
    required this.onChangedHolder1,
    required this.onChangedHolder2,
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
              buildBrand(),
              SizedBox(height: 16),
              buildTag(),
              SizedBox(height: 8),
              buildHolder1(),
              buildHolder2(),
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


  Widget buildBrand() => 
    ButtonTheme( 
      alignedDropdown: true, 
      child: DropdownButtonFormField(
        decoration: InputDecoration(
        labelText: 'Brand : ',
        labelStyle: TextStyle(decoration: TextDecoration.underline, color: Colors.black),
      ),
        hint : Text("Brand"),
        value: brand != 0 ? brand : defaultBrand.id,
        // value: s1 != 0 ? s1 : listSuperstars![0].id,
        onChanged: onChangedBrand,
        items: listBrands!.map((brand){
        return DropdownMenuItem(
          // value: s1.id != 0 ? s1.id : listSuperstars![0].id,
          value: brand.id,
          child: Text(brand.nom));
      }).toList(),
      ),);

    Widget buildTag() => 
    ButtonTheme( 
      alignedDropdown: true, 
      child: DropdownButtonFormField(
        decoration: InputDecoration(
        labelText: 'Title type : ',
        labelStyle: TextStyle(decoration: TextDecoration.underline, color: Colors.black),
      ),
        hint : Text("Title type"),
        value: tag,
        onChanged: onChangedTag,
        items: listTag.map((tag){
        return DropdownMenuItem(
          // value: s1.id != 0 ? s1.id : listSuperstars![0].id,
          value: tag ? 1 : 0,
          child: tag ? Text('Tag') : Text('Solo'));
      }).toList(),
      ),);


    Widget buildHolder1() => 
    ButtonTheme( 
      alignedDropdown: true, 
      child: DropdownButtonFormField(
        decoration: InputDecoration(
        labelText: 'Holder 1 : ',
        labelStyle: TextStyle(decoration: TextDecoration.underline, color: Colors.black),
      ),
        hint : Text("Holder 1"),
        value: holder1 != 0 ? holder1 : defaultSup.id,
        onChanged: onChangedHolder1,
        items: listSuperstars!.map((holder1){
        return DropdownMenuItem(
          // value: s1.id != 0 ? s1.id : listSuperstars![0].id,
          value: holder1.id,
          child: Text(holder1.nom));
      }).toList(),
      ),);



    Widget buildHolder2() => 
    ButtonTheme( 
      alignedDropdown: true, 
      child: DropdownButtonFormField(
        decoration: InputDecoration(
        labelText: 'Holder 2 : ',
        labelStyle: TextStyle(decoration: TextDecoration.underline, color: Colors.black),
      ),
        hint : Text("Holder 2"),
        value: holder2 != 0 ? holder2 : defaultSup.id,
        onChanged: onChangedHolder2,
        items : disable(tag!) ? null : listSuperstars!.map((holder2){
        return DropdownMenuItem(
          value: holder2.id,
          child: Text(holder2.nom));
      }).toList(),
      ),);
}