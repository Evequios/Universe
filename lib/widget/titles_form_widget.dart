import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/brands.dart';
import 'package:wwe_universe/classes/superstars.dart';

Brands defaultBrand = const Brands(name: 'nom');
Superstars defaultSup = const Superstars(name: 'nom', brand: null, orientation: 'orientation', division: 0);
List<bool> listTag = [false, true];

bool disable(int tag){
 return tag == 0 ? true : false;
}

class TitlesFormWidget extends StatelessWidget {
  final List<Superstars>? listSuperstars;
  final List<Brands>? listBrands;
  final String? name;
  final Brands? brand;
  final int? tag;
  final Superstars? holder1;
  final Superstars? holder2;
  final ValueChanged<String?> onChangedName;
  final ValueChanged<Brands?> onChangedBrand;
  final ValueChanged<int?> onChangedTag;
  final ValueChanged<Superstars?> onChangedHolder1; 
  final ValueChanged<Superstars?> onChangedHolder2;


  const TitlesFormWidget({
    super.key,
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
          buildBrand(),
          const SizedBox(height: 8),
          buildTag(),
          const SizedBox(height: 8),
          buildHolder1(),
          const SizedBox(height: 8,),
          buildHolder2(),
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


  Widget buildBrand() => 
    ButtonTheme( 
      alignedDropdown: true, 
      child: DropdownButtonFormField<Brands>(
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: 'Brand',
        labelStyle: TextStyle(color: Colors.black87.withOpacity(0.5)),
      ),
        initialValue: brand ?? defaultBrand,
        onChanged: onChangedBrand,
        items: listBrands!.map((brand){
        return DropdownMenuItem(
          value: brand,
          child: Text(brand.name));
      }).toList(),
    ),
  );

    Widget buildTag() => 
    ButtonTheme( 
      alignedDropdown: true, 
      child: DropdownButtonFormField(
        decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: 'Title type',
        labelStyle: TextStyle(color: Colors.black87.withOpacity(0.5)),
      ),
        initialValue: tag,
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
      child: DropdownButtonFormField<Superstars>(
        decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: 'Holder 1',
        labelStyle: TextStyle(color: Colors.black87.withOpacity(0.5)),
      ),
        initialValue: findSuperstarInList(holder1),
        onChanged: onChangedHolder1,
        items: listSuperstars!.map((holder1){
        return DropdownMenuItem(
          value: holder1,
          child: Text(holder1.name));
      }).toList(),
      ),
    );



    Widget buildHolder2() => 
    ButtonTheme( 
      alignedDropdown: true, 
      child: DropdownButtonFormField<Superstars>(
        decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: 'Holder 2',
        labelStyle: TextStyle(color: Colors.black87.withOpacity(0.5)),
      ),
        initialValue: findSuperstarInList(holder2),
        onChanged: onChangedHolder2,
        items: listSuperstars!.map((holder2){
        return DropdownMenuItem(
          value: holder2,
          child: Text(holder2.name));
      }).toList(),
      ),
    );

    Superstars? findSuperstarInList(Superstars? superstar) {
      if (superstar?.id == null) return null;

      for (final item in listSuperstars ?? <Superstars>[]) {
        if (item.id == superstar!.id) {
          return item;
        }
      }

      return null;
    }
}