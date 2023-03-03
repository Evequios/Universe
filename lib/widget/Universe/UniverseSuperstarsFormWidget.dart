import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/Universe/UniverseBrands.dart';

const List<String> listOrientations = <String>['Face', 'Tweener', 'Heel'];
UniverseBrands defaultBrand = UniverseBrands(nom: 'nom');

class UniverseSuperstarsFormWidget extends StatelessWidget {
  final List<UniverseBrands>? listBrands;
  final String? nom;
  final int? brand;
  final String? orientation;
  final ValueChanged<String?> onChangedNom;
  final ValueChanged<int?> onChangedBrand;
  final ValueChanged<String?> onChangedOrientation;

  const UniverseSuperstarsFormWidget({
    Key? key,
    required this.listBrands,
    this.nom = '',
    this.brand,
    this.orientation = '',
    required this.onChangedNom,
    required this.onChangedBrand,
    required this.onChangedOrientation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context){ 
  return Scaffold(
    body: Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildNom(),
              SizedBox(height: 8,),
              buildBrand(),
              SizedBox(height: 8,),
              buildOrientation(),
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

    Widget buildOrientation() => Container(alignment: Alignment.bottomLeft,child: DropdownButton(
      hint: Text("Orientation"),
      value: orientation == "" ? null : orientation,
      onChanged : onChangedOrientation, 
      items: listOrientations.map((orientation){
        return DropdownMenuItem<String>(
          value: orientation == "" ? null : orientation,
          child: Text(orientation));
      }).toList(),
    ),);
  
}