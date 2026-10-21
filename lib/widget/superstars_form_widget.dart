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
  final Superstars? ally1, ally2, ally3, ally4, ally5;
  final Superstars? rival1, rival2, rival3, rival4, rival5;
  final int? division;
  
  final ValueChanged<String?> onChangedName;
  final ValueChanged<Brands?> onChangedBrand;
  final ValueChanged<String?> onChangedOrientation;
  final ValueChanged<Superstars?> onChangedAlly1, onChangedAlly2, onChangedAlly3, onChangedAlly4, onChangedAlly5;
  final ValueChanged<Superstars?> onChangedRival1, onChangedRival2, onChangedRival3, onChangedRival4, onChangedRival5;
  final ValueChanged<int?> onChangedDivision;

  const SuperstarsFormWidget({
    super.key,
    required this.listSuperstars,
    required this.listBrands,
    this.name = '',
    this.brand,
    this.orientation = '',
    this.ally1, this.ally2, this.ally3, this.ally4, this.ally5, 
    this.rival1, this.rival2, this.rival3, this.rival4, this.rival5,
    this.division,
    required this.onChangedName,
    required this.onChangedBrand,
    required this.onChangedOrientation,
    required this.onChangedAlly1, required this.onChangedAlly2, required this.onChangedAlly3, required this.onChangedAlly4, required this.onChangedAlly5,
    required this.onChangedRival1, required this.onChangedRival2, required this.onChangedRival3, required this.onChangedRival4, required this.onChangedRival5,
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
                const Text('Allies', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                buildAlly1(),
                const SizedBox(height: 8,),
                buildAlly2(),
                const SizedBox(height: 8,),
                buildAlly3(),
                const SizedBox(height: 8,),
                buildAlly4(),
                const SizedBox(height: 8,),
                buildAlly5(),
                const SizedBox(height: 24,),
                const Text('Rivals', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                buildRival1(),
                const SizedBox(height: 8,),
                buildRival2(),
                const SizedBox(height: 8,),
                buildRival3(),
                const SizedBox(height: 8,),
                buildRival4(),
                const SizedBox(height: 8,),
                buildRival5()
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


  Widget buildAlly1() => 
  ButtonTheme( 
    alignedDropdown: true, 
    child: DropdownButtonFormField<Superstars>(
      decoration: InputDecoration(
      border: const OutlineInputBorder(),
        labelText: 'Ally 1',
        labelStyle: TextStyle(color: Colors.black87.withOpacity(0.5)),
    ),
      value: listSuperstars!.contains(ally1) ? ally1 : null,
      onChanged: onChangedAlly1,
      items: listSuperstars!.map((ally1){
      return DropdownMenuItem(
        value: ally1,
        child: Text(ally1.name));
    }).toList(),
    ),
  );

  Widget buildAlly2() => 
  ButtonTheme( 
    alignedDropdown: true, 
    child: DropdownButtonFormField<Superstars>(
    decoration: InputDecoration(
      border: const OutlineInputBorder(),
        labelText: 'Ally 2',
        labelStyle: TextStyle(color: Colors.black87.withOpacity(0.5)),
    ),
      value: listSuperstars!.contains(ally2) ? ally2 : null,
      onChanged: onChangedAlly2,
      items: listSuperstars!.map((ally2){
      return DropdownMenuItem(
        value: ally2,
        child: Text(ally2.name));
    }).toList(),
    ),
  );

  Widget buildAlly3() => 
  ButtonTheme( 
    alignedDropdown: true, 
    child: DropdownButtonFormField<Superstars>(
      decoration: InputDecoration(
      border: const OutlineInputBorder(),
        labelText: 'Ally 3',
        labelStyle: TextStyle(color: Colors.black87.withOpacity(0.5)),
    ),
      value: listSuperstars!.contains(ally3) ? ally3 : null,
      onChanged: onChangedAlly3,
      items: listSuperstars!.map((ally3){
      return DropdownMenuItem(
        value: ally3,
        child: Text(ally3.name));
    }).toList(),
    ),
  );

  Widget buildAlly4() => 
  ButtonTheme( 
    alignedDropdown: true, 
    child: DropdownButtonFormField<Superstars>(
      decoration: InputDecoration(
      border: const OutlineInputBorder(),
        labelText: 'Ally 4',
        labelStyle: TextStyle(color: Colors.black87.withOpacity(0.5)),
    ),
      value: listSuperstars!.contains(ally4) ? ally4 : null,
      onChanged: onChangedAlly4,
      items: listSuperstars!.map((ally4){
      return DropdownMenuItem(
        value: ally4,
        child: Text(ally4.name));
    }).toList(),
    ),
  );

  Widget buildAlly5() => 
  ButtonTheme( 
    alignedDropdown: true, 
    child: DropdownButtonFormField<Superstars>(
      decoration: InputDecoration(
      border: const OutlineInputBorder(),
        labelText: 'Ally 5',
        labelStyle: TextStyle(color: Colors.black87.withOpacity(0.5)),
    ),
      value: listSuperstars!.contains(ally5) ? ally5 : null,
      onChanged: onChangedAlly5,
      items: listSuperstars!.map((ally5){
      return DropdownMenuItem(
        value: ally5,
        child: Text(ally5.name));
    }).toList(),
    ),
  );

  Widget buildRival1() => 
  ButtonTheme( 
    alignedDropdown: true, 
    child: DropdownButtonFormField<Superstars>(
      decoration: InputDecoration(
      border: const OutlineInputBorder(),
        labelText: 'Rival 1',
        labelStyle: TextStyle(color: Colors.black87.withOpacity(0.5)),
    ),
      value: listSuperstars!.contains(rival1) ? rival1 : null,
      onChanged: onChangedRival1,
      items: listSuperstars!.map((rival1){
      return DropdownMenuItem(
        value: rival1,
        child: Text(rival1.name));
    }).toList(),
    ),
  );

  Widget buildRival2() => 
  ButtonTheme( 
    alignedDropdown: true, 
    child: DropdownButtonFormField(
      decoration: InputDecoration(
      border: const OutlineInputBorder(),
        labelText: 'Rival 2',
        labelStyle: TextStyle(color: Colors.black87.withOpacity(0.5)),
    ),
      value: listSuperstars!.contains(rival2) ? rival2 : null,
      onChanged: onChangedRival2,
      items: listSuperstars!.map((rival2){
      return DropdownMenuItem(
        value: rival2,
        child: Text(rival2.name));
    }).toList(),
    ),
  );

  Widget buildRival3() => 
  ButtonTheme( 
    alignedDropdown: true, 
    child: DropdownButtonFormField(
      decoration: InputDecoration(
      border: const OutlineInputBorder(),
        labelText: 'Rival 3',
        labelStyle: TextStyle(color: Colors.black87.withOpacity(0.5)),
    ),
      value: listSuperstars!.contains(rival3) ? rival3 : null,
      onChanged: onChangedRival3,
      items: listSuperstars!.map((rival3){
      return DropdownMenuItem(
        value: rival3,
        child: Text(rival3.name));
    }).toList(),
    ),
  );

  Widget buildRival4() => 
  ButtonTheme( 
    alignedDropdown: true, 
    child: DropdownButtonFormField(
      decoration: InputDecoration(
      border: const OutlineInputBorder(),
        labelText: 'Rival 4',
        labelStyle: TextStyle(color: Colors.black87.withOpacity(0.5)),
    ),
      value: listSuperstars!.contains(rival4) ? rival4 : null,
      onChanged: onChangedRival4,
      items: listSuperstars!.map((rival4){
      return DropdownMenuItem(
        value: rival4,
        child: Text(rival4.name));
    }).toList(),
    ),
  );

  Widget buildRival5() => 
  ButtonTheme( 
    alignedDropdown: true, 
    child: DropdownButtonFormField(
      decoration: InputDecoration(
      border: const OutlineInputBorder(),
        labelText: 'Rival 5',
        labelStyle: TextStyle(color: Colors.black87.withOpacity(0.5)),
    ),
      value: listSuperstars!.contains(rival5) ? rival5 : null,
      onChanged: onChangedRival5,
      items: listSuperstars!.map((rival5){
      return DropdownMenuItem(
        value: rival5,
        child: Text(rival5.name));
    }).toList(),
    ),
  );
}