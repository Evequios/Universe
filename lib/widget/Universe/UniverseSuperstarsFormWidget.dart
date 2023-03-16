import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/Universe/UniverseBrands.dart';
import 'package:wwe_universe/classes/Universe/UniverseSuperstars.dart';
import 'package:wwe_universe/widget/IRL/IRLNewsFormWidget.dart';

const List<String> listOrientations = <String>['Face', 'Tweener', 'Heel'];
UniverseBrands defaultBrand = const UniverseBrands(name: 'nom');
UniverseSuperstars defaultSup = const UniverseSuperstars(name: 'nom', brand: 0, orientation: 'orientation', rival1: 0, rival2: 0, rival3: 0, rival4: 0, rival5: 0, ally1: 0, ally2: 0, ally3 : 0, ally4:0, ally5 : 0, division: 0);

class UniverseSuperstarsFormWidget extends StatelessWidget {
  final List<UniverseSuperstars>? listSuperstars;
  final List<UniverseBrands>? listBrands;
  final String? name;
  final int? brand;
  final String? orientation;
  final int? ally1;
  final int? ally2;
  final int? ally3;
  final int? ally4;
  final int? ally5;
  final int? rival1;
  final int? rival2;
  final int? rival3;
  final int? rival4;
  final int? rival5;
  final int? division;
  
  final ValueChanged<String?> onChangedName;
  final ValueChanged<int?> onChangedBrand;
  final ValueChanged<String?> onChangedOrientation;
  final ValueChanged<int?> onChangedAlly1;
  final ValueChanged<int?> onChangedAlly2;
  final ValueChanged<int?> onChangedAlly3;
  final ValueChanged<int?> onChangedAlly4;
  final ValueChanged<int?> onChangedAlly5;
  final ValueChanged<int?> onChangedRival1;
  final ValueChanged<int?> onChangedRival2;
  final ValueChanged<int?> onChangedRival3;
  final ValueChanged<int?> onChangedRival4;
  final ValueChanged<int?> onChangedRival5;
  final ValueChanged<int?> onChangedDivision;

  const UniverseSuperstarsFormWidget({
    Key? key,
    required this.listSuperstars,
    required this.listBrands,
    this.name = '',
    this.brand,
    this.orientation = '',
    this.ally1,
    this.ally2,
    this.ally3,
    this.ally4,
    this.ally5,
    this.rival1,
    this.rival2,
    this.rival3,
    this.rival4,
    this.rival5,
    this.division,
    required this.onChangedName,
    required this.onChangedBrand,
    required this.onChangedOrientation,
    required this.onChangedAlly1,
    required this.onChangedAlly2,
    required this.onChangedAlly3,
    required this.onChangedAlly4,
    required this.onChangedAlly5,
    required this.onChangedRival1,
    required this.onChangedRival2,
    required this.onChangedRival3,
    required this.onChangedRival4,
    required this.onChangedRival5,
    required this.onChangedDivision
  }) : super(key: key);

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

  Widget buildBrand() => 
    ButtonTheme( 
      alignedDropdown: true, 
      child: DropdownButtonFormField(
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: 'Brand',
        labelStyle: TextStyle(color: Colors.black87.withOpacity(0.5)),
      ),
        value: brand != 0 ? brand : defaultBrand.id,
        onChanged: onChangedBrand,
        items: listBrands!.map((brand){
        return DropdownMenuItem(
          value: brand.id,
          child: Text(brand.name));
      }).toList(),
    ),
  );

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
    child: DropdownButtonFormField(
      decoration: InputDecoration(
      border: const OutlineInputBorder(),
        labelText: 'Ally 1',
        labelStyle: TextStyle(color: Colors.black87.withOpacity(0.5)),
    ),
      value: ally1 != 0 ? ally1 : defaultSup.id,
      onChanged: onChangedAlly1,
      items: listSuperstars!.map((ally1){
      return DropdownMenuItem(
        value: ally1.id,
        child: Text(ally1.name));
    }).toList(),
    ),
  );

  Widget buildAlly2() => 
  ButtonTheme( 
    alignedDropdown: true, 
    child: DropdownButtonFormField(
    decoration: InputDecoration(
      border: const OutlineInputBorder(),
        labelText: 'Ally 2',
        labelStyle: TextStyle(color: Colors.black87.withOpacity(0.5)),
    ),
      value: ally2 != 0 ? ally2 : defaultSup.id,
      onChanged: onChangedAlly2,
      items: listSuperstars!.map((ally2){
      return DropdownMenuItem(
        value: ally2.id,
        child: Text(ally2.name));
    }).toList(),
    ),
  );

  Widget buildAlly3() => 
  ButtonTheme( 
    alignedDropdown: true, 
    child: DropdownButtonFormField(
      decoration: InputDecoration(
      border: const OutlineInputBorder(),
        labelText: 'Ally 3',
        labelStyle: TextStyle(color: Colors.black87.withOpacity(0.5)),
    ),
      value: ally3 != 0 ? ally3 : defaultSup.id,
      onChanged: onChangedAlly3,
      items: listSuperstars!.map((ally3){
      return DropdownMenuItem(
        value: ally3.id,
        child: Text(ally3.name));
    }).toList(),
    ),
  );

  Widget buildAlly4() => 
  ButtonTheme( 
    alignedDropdown: true, 
    child: DropdownButtonFormField(
      decoration: InputDecoration(
      border: const OutlineInputBorder(),
        labelText: 'Ally 4',
        labelStyle: TextStyle(color: Colors.black87.withOpacity(0.5)),
    ),
      value: ally4 != 0 ? ally4 : defaultSup.id,
      onChanged: onChangedAlly4,
      items: listSuperstars!.map((ally4){
      return DropdownMenuItem(
        value: ally4.id,
        child: Text(ally4.name));
    }).toList(),
    ),
  );

  Widget buildAlly5() => 
  ButtonTheme( 
    alignedDropdown: true, 
    child: DropdownButtonFormField(
      decoration: InputDecoration(
      border: const OutlineInputBorder(),
        labelText: 'Ally 5',
        labelStyle: TextStyle(color: Colors.black87.withOpacity(0.5)),
    ),
      value: ally5 != 0 ? ally5 : defaultSup.id,
      onChanged: onChangedAlly5,
      items: listSuperstars!.map((ally5){
      return DropdownMenuItem(
        value: ally5.id,
        child: Text(ally5.name));
    }).toList(),
    ),
  );

  Widget buildRival1() => 
  ButtonTheme( 
    alignedDropdown: true, 
    child: DropdownButtonFormField(
      decoration: InputDecoration(
      border: const OutlineInputBorder(),
        labelText: 'Rival 1',
        labelStyle: TextStyle(color: Colors.black87.withOpacity(0.5)),
    ),
      value: rival1 != 0 ? rival1 : defaultSup.id,
      onChanged: onChangedRival1,
      items: listSuperstars!.map((rival1){
      return DropdownMenuItem(
        // value: s1.id != 0 ? s1.id : listSuperstars![0].id,
        value: rival1.id,
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
      value: rival2 != 0 ? rival2 : defaultSup.id,
      onChanged: onChangedRival2,
      items: listSuperstars!.map((rival2){
      return DropdownMenuItem(
        // value: s2.id != 0 ? s2.id : listSuperstars![0].id,
        value: rival2.id,
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
      value: rival3 != 0 ? rival3 : defaultSup.id,
      onChanged: onChangedRival3,
      items: listSuperstars!.map((rival3){
      return DropdownMenuItem(
        // value: s3.id != 0 ? s3.id : listSuperstars![0].id,
        value: rival3.id,
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
      value: rival4 != 0 ? rival4 : defaultSup.id,
      onChanged: onChangedRival4,
      items: listSuperstars!.map((rival4){
      return DropdownMenuItem(
        // value: s4.id != 0 ? s4.id : listSuperstars![0].id,
        value: rival4.id,
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
      value: rival5 != 0 ? rival5 : defaultSup.id,
      onChanged: onChangedRival5,
      items: listSuperstars!.map((rival5){
      return DropdownMenuItem(
        value: rival5.id,
        child: Text(rival5.name));
    }).toList(),
    ),
  );
}