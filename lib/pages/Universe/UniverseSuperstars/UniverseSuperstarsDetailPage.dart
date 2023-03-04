import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/Universe/UniverseBrands.dart';
import 'package:wwe_universe/classes/Universe/UniverseSuperstars.dart';
import 'package:wwe_universe/classes/Universe/UniverseNews.dart';
import 'package:wwe_universe/database.dart';
import 'package:wwe_universe/pages/Universe/UniverseNews/AddEditUniverseNewsPage.dart';
import 'package:wwe_universe/pages/Universe/UniverseSuperstars/AddEditUniverseSuperstarsPage.dart';
// import 'package:sqflite_database_example/page/edit_note_page.dart';

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
  UniverseBrands defaultBrand = UniverseBrands(nom: '');
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    refreshSuperstars();
  }

  Future refreshSuperstars() async {
    setState(() => isLoading = true);

    superstar = await UniverseDatabase.instance.readSuperstar(widget.superstarId);
    if(superstar.brand != 0) brand = await UniverseDatabase.instance.readBrand(superstar.brand);
    else brand = defaultBrand;
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
            ? Center(child: CircularProgressIndicator())
            : Padding(
                padding: EdgeInsets.all(12),
                child: ListView(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  children: [
                    Text(
                      'Nom : ${superstar.nom}',
                      style: TextStyle(color: Colors.black, fontSize: 18),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Brand : ${brand.nom}',
                      style: TextStyle(color: Colors.black, fontSize: 18),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Orientation : ${superstar.orientation}',
                      style: TextStyle(color: Colors.black, fontSize: 18),
                    ),
                    SizedBox(height: 8),
                    superstar.rival1 != 0 ? Text(
                      'Rival1 : ${superstar.rival1}',
                      style: TextStyle(color: Colors.black, fontSize: 18),
                    ) : SizedBox(height: 0,)
                  ],
                ),
              ),
      );

  Widget editButton() => IconButton(
      icon: Icon(Icons.edit_outlined),
      onPressed: () async {
        if (isLoading) return;

        await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => AddEditUniverseSuperstarsPage(superstar: superstar, listBrands: listBrands, listSuperstars: listSuperstars,),
        ));

        refreshSuperstars();
      });

  Widget deleteButton() => IconButton(
        icon: Icon(Icons.delete),
        onPressed: () async {
          await UniverseDatabase.instance.deleteSuperstar(widget.superstarId);

          Navigator.of(context).pop();
        },
  );
}