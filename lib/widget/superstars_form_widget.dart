import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/brands.dart';
import 'package:wwe_universe/classes/superstars.dart';

const List<String> listOrientations = <String>['Face', 'Tweener', 'Heel'];
Brands defaultBrand = const Brands(name: 'nom');
Superstars defaultSup = const Superstars(name: 'nom', orientation: 'orientation');

class SuperstarsFormWidget extends StatelessWidget {
  final List<Superstars>? listSuperstars;
  final List<Brands>? listBrands;
  final String? name;
  final Brands? brand;
  final String? orientation;
  final int? division;
  
  final ValueChanged<String?> onChangedName;
  final ValueChanged<Brands?> onChangedBrand;
  final ValueChanged<String?> onChangedOrientation;
  final ValueChanged<int?> onChangedDivision;

  const SuperstarsFormWidget({
    super.key,
    required this.listSuperstars,
    required this.listBrands,
    this.name = '',
    this.brand,
    this.orientation = '',
    this.division,
    required this.onChangedName,
    required this.onChangedBrand,
    required this.onChangedOrientation,
    required this.onChangedDivision
  });

  @override
  Widget build(BuildContext context){ 
  return Scaffold(
    body: SingleChildScrollView(
      child : Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                buildName(),
                const SizedBox(height: 8,),
                buildBrand(),
                const SizedBox(height: 8,),
                buildOrientation(),
                const SizedBox(height: 24,),
                const Text('Allies', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),)
              ],
            ),
          ),
       )
      )
    );
  }


  Widget buildName() => TextFormField(
    textCapitalization: TextCapitalization.sentences,
    initialValue: name,
    style: const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 18,
    ),
    decoration: InputDecoration(
      labelText : "Name",
      labelStyle: TextStyle(color: Colors.black87.withOpacity(0.5), fontSize: 18, ),
      border: const OutlineInputBorder(),
    ),
    validator: (name) => name != null && name.isEmpty ? "The name can't be empty": null,
    onChanged: onChangedName,
  );

  Widget buildBrand() => ButtonTheme(
    alignedDropdown: true,
    child: DropdownButtonFormField<Brands>(
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: 'Brand',
        labelStyle: TextStyle(color: Colors.black87.withOpacity(0.5)),
      ),
      value: getBrand(),
      selectedItemBuilder: (BuildContext context) {
        return listBrands?.map<Widget>((Brands brand) {
          return Text(brand.name);
        }).toList() ?? [];
      },
      onChanged: onChangedBrand,
      items: listBrands?.map((brand) {
        return DropdownMenuItem(
          value: brand,
          child: Text(brand.name),
        );
      }).toList() ?? [],
    ),
  );

  Brands? getBrand() {
    if (brand != null) {
      return listBrands?.firstWhere(
        (b) => b.id == brand?.id
      );
    } 
    return brand;
  }
  // Widget buildBrand() => ButtonTheme(
  //   alignedDropdown: true,
  //   child: DropdownButtonFormField<Brands>(
  //     decoration: InputDecoration(
  //       border: const OutlineInputBorder(),
  //       labelText: 'Brand',
  //       labelStyle: TextStyle(color: Colors.black87.withOpacity(0.5)),
  //     ),
  //     value: listBrands?.firstWhere(
  //       (b) => b.id == brand?.id,
  //       orElse: () => defaultBrand, // Assure qu'on a une seule valeur correcte
  //     ),
  //     selectedItemBuilder: (BuildContext context) {
  //       return listBrands?.map<Widget>((Brands brand) {
  //         return Text(brand.name);
  //       }).toList() ?? [];
  //     },
  //     onChanged: onChangedBrand,
  //     items: listBrands?.map((brand) {
  //       return DropdownMenuItem(
  //         value: brand,
  //         child: Text(brand.name),
  //       );
  //     }).toList() ?? [],
  //   ),
  // );

  Widget buildOrientation() => 
    ButtonTheme( 
      alignedDropdown: true, 
      child: DropdownButtonFormField(
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: 'Orientation',
        labelStyle: TextStyle(color: Colors.black87.withOpacity(0.5)),
      ),
        value: orientation != '' && orientation != null ? orientation : listOrientations[0],
        onChanged: onChangedOrientation,
        items: listOrientations.map((orientation){
        return DropdownMenuItem(
          value: orientation != '' ? orientation : listOrientations[0],
          child: Text(orientation));
      }).toList(),
      ));
}