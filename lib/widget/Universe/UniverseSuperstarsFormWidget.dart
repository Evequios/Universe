import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/Universe/UniverseBrands.dart';
import 'package:wwe_universe/classes/Universe/UniverseSuperstars.dart';

const List<String> listOrientations = <String>['Face', 'Tweener', 'Heel'];
UniverseBrands defaultBrand = const UniverseBrands(name: 'nom');
UniverseSuperstars defaultSup = UniverseSuperstars(nom: 'nom', brand: 0, orientation: 'orientation', rival1: 0);

class UniverseSuperstarsFormWidget extends StatelessWidget {
  final List<UniverseSuperstars>? listSuperstars;
  final List<UniverseBrands>? listBrands;
  final String? nom;
  final int? brand;
  final String? orientation;
  final int? rival1;
  final ValueChanged<String?> onChangedNom;
  final ValueChanged<int?> onChangedBrand;
  final ValueChanged<String?> onChangedOrientation;
  final ValueChanged<int?> onChangedRival1;

  const UniverseSuperstarsFormWidget({
    Key? key,
    required this.listSuperstars,
    required this.listBrands,
    this.nom = '',
    this.brand,
    this.orientation = '',
    this.rival1,
    required this.onChangedNom,
    required this.onChangedBrand,
    required this.onChangedOrientation,
    required this.onChangedRival1
  }) : super(key: key);

  @override
  Widget build(BuildContext context){ 
  return Scaffold(
    body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildNom(),
              const SizedBox(height: 8,),
              buildBrand(),
              const SizedBox(height: 8,),
              buildOrientation(),
              const SizedBox(height: 8,),
              buildRival1()
            ],
          ),
        ),
      )
  );
  }


  Widget buildNom() => TextFormField(
        initialValue: nom,
        style: const TextStyle(color: Colors.black, fontSize: 18),
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Nom',
          hintStyle: TextStyle(color: Colors.black),
        ),
        validator: (nom) => nom != null && nom.isEmpty ? "The name can't be empty": null,
        onChanged: onChangedNom,
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
        ),);

    Widget buildOrientation() => Container(alignment: Alignment.bottomLeft,child: DropdownButton(
      hint: const Text("Orientation"),
      value: orientation == "" ? null : orientation,
      onChanged : onChangedOrientation, 
      items: listOrientations.map((orientation){
        return DropdownMenuItem<String>(
          value: orientation == "" ? null : orientation,
          child: Text(orientation));
      }).toList(),
    ),);

    Widget buildRival1() => 
    ButtonTheme( 
      alignedDropdown: true, 
      child: DropdownButtonFormField(
        decoration: InputDecoration(
        labelText: 'Rival 1 : ',
        labelStyle: TextStyle(decoration: TextDecoration.underline, color: Colors.black),
      ),
        hint : Text("Rival 1"),
        value: rival1 != 0 ? rival1 : defaultSup.id,
        onChanged: onChangedRival1,
        items: listSuperstars!.map((rival1){
        return DropdownMenuItem(
          // value: s1.id != 0 ? s1.id : listSuperstars![0].id,
          value: rival1.id,
          child: Text(rival1.nom));
      }).toList(),
      ),);
}