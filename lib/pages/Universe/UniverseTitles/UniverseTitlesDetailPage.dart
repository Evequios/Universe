import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/Universe/UniverseBrands.dart';
import 'package:wwe_universe/classes/Universe/UniverseSuperstars.dart';
import 'package:wwe_universe/classes/Universe/UniverseTitles.dart';
import 'package:wwe_universe/database.dart';
import 'package:wwe_universe/pages/Universe/UniverseTitles/AddEditUniverseTitlesPage.dart';
// import 'package:sqflite_database_example/page/edit_note_page.dart';

class UniverseTitlesDetailPage extends StatefulWidget {
  final int titleId;

  const UniverseTitlesDetailPage({
    Key? key,
    required this.titleId,
    
  }) : super(key: key);

  @override
  _UniverseTitlesDetailPage createState() => _UniverseTitlesDetailPage();
}

class _UniverseTitlesDetailPage extends State<UniverseTitlesDetailPage> {
  UniverseTitles title = const UniverseTitles(name: '', tag: 0, brand: 0, holder1: 0, holder2: 0);
  UniverseBrands brand = const UniverseBrands(name: '');
  UniverseSuperstars h1 = const UniverseSuperstars(name: 'nom', brand: 0, orientation: 'orientation', ally1: 0, ally2: 0, ally3: 0, ally4: 0, ally5: 0, rival1: 0, rival2: 0, rival3: 0, rival4: 0, rival5: 0); 
  UniverseSuperstars h2 = const UniverseSuperstars(name: 'nom', brand: 0, orientation: 'orientation', ally1: 0, ally2: 0, ally3: 0, ally4: 0, ally5: 0, rival1: 0, rival2: 0, rival3: 0, rival4: 0, rival5: 0);
  late List<UniverseBrands> brandsList;
  late List<UniverseSuperstars> superstarsList;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    refreshTitle();
  }

  Future refreshTitle() async {
    setState(() => isLoading = true);

    title = await UniverseDatabase.instance.readTitle(widget.titleId);
    if(title.brand != 0) brand = await UniverseDatabase.instance.readBrand(title.brand);
    if(title.holder1 != 0) h1 = await UniverseDatabase.instance.readSuperstar(title.holder1);
    if(title.holder2 != 0) h2 = await UniverseDatabase.instance.readSuperstar(title.holder2);
    superstarsList = await UniverseDatabase.instance.readAllSuperstars();
    brandsList = await UniverseDatabase.instance.readAllBrands();

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
                  title.name,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const SizedBox(height: 8),
                Text("Brand : ${brand.name}",
                  style: const TextStyle(color: Colors.black, fontSize: 18)
                ),
                const SizedBox(height: 8),
                title.tag == 0 && title.holder1 != 0 ?
                Text("Champion : ${h1.name}",
                  style: const TextStyle(color: Colors.black, fontSize: 18),
                )
                :
                title.tag == 1 && title.holder1 != 0 && title.holder2 != 0 ?
                Text("Champions : ${h1.name} & ${h2.name}",
                  style: const TextStyle(color: Colors.black, fontSize: 18),
                )
                : const SizedBox(height: 0),
              ],
            ),
          ),
  );

  Widget editButton() => IconButton(
    icon: const Icon(Icons.edit_outlined),
    onPressed: () async {

      await Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => AddEditUniverseTitlesPage(title: title, listBrands: brandsList, listSuperstars: superstarsList,),
      ));

      refreshTitle();
    }
  );

  Widget deleteButton() => IconButton(
    icon: const Icon(Icons.delete),
    onPressed: () async {
      await UniverseDatabase.instance.deleteTitle(widget.titleId);
      if(context.mounted) Navigator.of(context).pop();
    },
  );
}