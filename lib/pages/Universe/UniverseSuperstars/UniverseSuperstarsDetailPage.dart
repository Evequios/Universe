import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/Universe/UniverseBrands.dart';
import 'package:wwe_universe/classes/Universe/UniverseSuperstars.dart';
import 'package:wwe_universe/database.dart';
import 'package:wwe_universe/pages/Universe/UniverseSuperstars/AddEditUniverseSuperstarsPage.dart';

class UniverseSuperstarsDetailPage extends StatefulWidget {
  final int superstarId;

  const UniverseSuperstarsDetailPage({
    Key? key,
    required this.superstarId,
  }) : super(key: key);

  @override
  _UniverseSuperstarsDetailPage createState() => _UniverseSuperstarsDetailPage();
}

class _UniverseSuperstarsDetailPage extends State<UniverseSuperstarsDetailPage> {
  late UniverseSuperstars superstar;
  late UniverseBrands brand;
  late List<UniverseBrands> listBrands = [];
  late List<UniverseSuperstars> listSuperstars = [];
  UniverseBrands defaultBrand = const UniverseBrands(name: '');
  UniverseSuperstars ally1 = const UniverseSuperstars(name: 'name', brand: 0, orientation: 'orientation', ally1: 0, ally2: 0, ally3: 0, ally4: 0, ally5: 0, rival1: 0, rival2: 0, rival3: 0, rival4: 0, rival5: 0);
  UniverseSuperstars ally2 = const UniverseSuperstars(name: 'name', brand: 0, orientation: 'orientation', ally1: 0, ally2: 0, ally3: 0, ally4: 0, ally5: 0, rival1: 0, rival2: 0, rival3: 0, rival4: 0, rival5: 0);
  UniverseSuperstars ally3 = const UniverseSuperstars(name: 'name', brand: 0, orientation: 'orientation', ally1: 0, ally2: 0, ally3: 0, ally4: 0, ally5: 0, rival1: 0, rival2: 0, rival3: 0, rival4: 0, rival5: 0);
  UniverseSuperstars ally4 = const UniverseSuperstars(name: 'name', brand: 0, orientation: 'orientation', ally1: 0, ally2: 0, ally3: 0, ally4: 0, ally5: 0, rival1: 0, rival2: 0, rival3: 0, rival4: 0, rival5: 0);
  UniverseSuperstars ally5 = const UniverseSuperstars(name: 'name', brand: 0, orientation: 'orientation', ally1: 0, ally2: 0, ally3: 0, ally4: 0, ally5: 0, rival1: 0, rival2: 0, rival3: 0, rival4: 0, rival5: 0);
  UniverseSuperstars rival1 = const UniverseSuperstars(name: 'name', brand: 0, orientation: 'orientation', ally1: 0, ally2: 0, ally3: 0, ally4: 0, ally5: 0, rival1: 0, rival2: 0, rival3: 0, rival4: 0, rival5: 0);
  UniverseSuperstars rival2 = const UniverseSuperstars(name: 'name', brand: 0, orientation: 'orientation', ally1: 0, ally2: 0, ally3: 0, ally4: 0, ally5: 0, rival1: 0, rival2: 0, rival3: 0, rival4: 0, rival5: 0);
  UniverseSuperstars rival3 = const UniverseSuperstars(name: 'name', brand: 0, orientation: 'orientation', ally1: 0, ally2: 0, ally3: 0, ally4: 0, ally5: 0, rival1: 0, rival2: 0, rival3: 0, rival4: 0, rival5: 0);
  UniverseSuperstars rival4 = const UniverseSuperstars(name: 'name', brand: 0, orientation: 'orientation', ally1: 0, ally2: 0, ally3: 0, ally4: 0, ally5: 0, rival1: 0, rival2: 0, rival3: 0, rival4: 0, rival5: 0);
  UniverseSuperstars rival5 = const UniverseSuperstars(name: 'name', brand: 0, orientation: 'orientation', ally1: 0, ally2: 0, ally3: 0, ally4: 0, ally5: 0, rival1: 0, rival2: 0, rival3: 0, rival4: 0, rival5: 0);

  

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    refreshSuperstars();
  }

  Future refreshSuperstars() async {
    setState(() => isLoading = true);

    superstar = await UniverseDatabase.instance.readSuperstar(widget.superstarId);
    if(superstar.ally1 != 0) ally1 = await UniverseDatabase.instance.readSuperstar(superstar.ally1);
    if(superstar.ally2 != 0) ally2 = await UniverseDatabase.instance.readSuperstar(superstar.ally2);
    if(superstar.ally3 != 0) ally3 = await UniverseDatabase.instance.readSuperstar(superstar.ally3);
    if(superstar.ally4 != 0) ally4 = await UniverseDatabase.instance.readSuperstar(superstar.ally4);
    if(superstar.ally5 != 0) ally5 = await UniverseDatabase.instance.readSuperstar(superstar.ally5);

    if(superstar.rival1 != 0) rival1 = await UniverseDatabase.instance.readSuperstar(superstar.rival1);
    if(superstar.rival2 != 0) rival2 = await UniverseDatabase.instance.readSuperstar(superstar.rival2);
    if(superstar.rival3 != 0) rival3 = await UniverseDatabase.instance.readSuperstar(superstar.rival3);
    if(superstar.rival4 != 0) rival4 = await UniverseDatabase.instance.readSuperstar(superstar.rival4);
    if(superstar.rival5 != 0) rival5 = await UniverseDatabase.instance.readSuperstar(superstar.rival5);

    if(superstar.brand != 0) {
      brand = await UniverseDatabase.instance.readBrand(superstar.brand);
    } 
    else {
      brand = defaultBrand;
    }
    listBrands = await UniverseDatabase.instance.readAllBrands();
    listSuperstars = await UniverseDatabase.instance.readAllSuperstars();

    setState(() => isLoading = false);  
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      actions: [editButton(), deleteButton()],
    ),
    body: isLoading
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(12),
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                Text(
                  'Name : ${superstar.name}',
                  style: const TextStyle(color: Colors.black, fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  'Brand : ${brand.name}',
                  style: const TextStyle(color: Colors.black, fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  'Orientation : ${superstar.orientation}',
                  style: const TextStyle(color: Colors.black, fontSize: 18),
                ),

                const SizedBox(height: 8),
                superstar.ally1 != 0 ? Text(
                  'Ally 1 : ${ally1.name}',
                  style: const TextStyle(color: Colors.black, fontSize: 18),
                ) : const SizedBox(height: 0,),

                const SizedBox(height: 8),
                superstar.ally2 != 0 ? Text(
                  'Ally 2 : ${ally2.name}',
                  style: const TextStyle(color: Colors.black, fontSize: 18),
                ) : const SizedBox(height: 0,),

                const SizedBox(height: 8),
                superstar.ally3!= 0 ? Text(
                  'Ally 3 : ${ally3.name}',
                  style: const TextStyle(color: Colors.black, fontSize: 18),
                ) : const SizedBox(height: 0,),

                const SizedBox(height: 8),
                superstar.ally4 != 0 ? Text(
                  'Ally 4 : ${ally4.name}',
                  style: const TextStyle(color: Colors.black, fontSize: 18),
                ) : const SizedBox(height: 0,),

                const SizedBox(height: 8),
                superstar.ally5 != 0 ? Text(
                  'Ally 5 : ${ally5.name}',
                  style: const TextStyle(color: Colors.black, fontSize: 18),
                ) : const SizedBox(height: 0,),

                const SizedBox(height: 8),
                superstar.rival1 != 0 ? Text(
                  'Rival 1 : ${rival1.name}',
                  style: const TextStyle(color: Colors.black, fontSize: 18),
                ) : const SizedBox(height: 0,),
                const SizedBox(height: 8),

                superstar.rival2 != 0 ? Text(
                  'Rival 2 : ${rival2.name}',
                  style: const TextStyle(color: Colors.black, fontSize: 18),
                ) : const SizedBox(height: 0,),
                const SizedBox(height: 8),

                superstar.rival3 != 0 ? Text(
                  'Rival 3 : ${rival3.name}',
                  style: const TextStyle(color: Colors.black, fontSize: 18),
                ) : const SizedBox(height: 0,),

                const SizedBox(height: 8),
                superstar.rival4 != 0 ? Text(
                  'Rival 4 : ${rival4.name}',
                  style: const TextStyle(color: Colors.black, fontSize: 18),
                ) : const SizedBox(height: 0,),

                const SizedBox(height: 8),
                superstar.rival5 != 0 ? Text(
                  'Rival5 : ${rival5.name}',
                  style: const TextStyle(color: Colors.black, fontSize: 18),
                ) : const SizedBox(height: 0,)
              ],
            ),
          ),
  );

  Widget editButton() => IconButton(
      icon: const Icon(Icons.edit_outlined),
      onPressed: () async {
        if (isLoading) return;

        await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => AddEditUniverseSuperstarsPage(superstar: superstar, listBrands: listBrands, listSuperstars: listSuperstars,),
        ));

        refreshSuperstars();
      });

  Widget deleteButton() => IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () async {
          await UniverseDatabase.instance.deleteSuperstar(widget.superstarId);

          if(context.mounted) Navigator.of(context).pop();
        },
  );
}