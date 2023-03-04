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
  final int? brandId;
  final int? h1Id;
  final int? h2Id;

  const UniverseTitlesDetailPage({
    Key? key,
    required this.titleId,
    this.brandId,
    this.h1Id,
    this.h2Id
    
  }) : super(key: key);

  @override
  _UniverseTitlesDetailPage createState() => _UniverseTitlesDetailPage();
}

class _UniverseTitlesDetailPage extends State<UniverseTitlesDetailPage> {
  UniverseTitles title = UniverseTitles(nom: '', tag: 0, brand: 0, holder1: 0, holder2: 0);
  UniverseBrands brand = UniverseBrands(name: '');
  UniverseSuperstars h1 = UniverseSuperstars(nom: '', brand: 0, orientation: 'orientation', rival1: 0); 
  UniverseSuperstars h2 = UniverseSuperstars(nom: '', brand: 0, orientation: 'orientation', rival1: 0);
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

    this.title = await UniverseDatabase.instance.readTitle(widget.titleId);
    if(widget.brandId != 0) this.brand = await UniverseDatabase.instance.readBrand(widget.brandId!);
    if(widget.h1Id != 0) this.h1 = await UniverseDatabase.instance.readSuperstar(widget.h1Id!);
    if(widget.h2Id != 0) this.h2 = await UniverseDatabase.instance.readSuperstar(widget.h2Id!);
    this.superstarsList = await UniverseDatabase.instance.readAllSuperstars();
    this.brandsList = await UniverseDatabase.instance.readAllBrands();

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
                      title.nom,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    SizedBox(height: 8),
                    Text("Brand : ${brand.name}",
                      style: TextStyle(color: Colors.black, fontSize: 18)
                    ),
                    SizedBox(height: 8),
                    title.tag == 0 && widget.h1Id != null ?
                    Text("Champion : ${h1.nom}",
                      style: TextStyle(color: Colors.black, fontSize: 18),
                    )
                    :
                    title.tag == 0 && widget.h1Id != null ?
                    Text("Champions : ${h1.nom} & ${h1.nom}",
                      style: TextStyle(color: Colors.black, fontSize: 18),
                    )
                    : SizedBox(height: 0),
                  ],
                ),
              ),
      );

  Widget editButton() => IconButton(
      icon: Icon(Icons.edit_outlined),
      onPressed: () async {
        if (isLoading) return;

        await Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => AddEditUniverseTitlesPage(title: title, listBrands: brandsList, listSuperstars: superstarsList,),
        ));

        refreshTitle();
      });

  Widget deleteButton() => IconButton(
        icon: Icon(Icons.delete),
        onPressed: () async {
          await UniverseDatabase.instance.deleteTitle(widget.titleId);
          Navigator.of(context).pop();
        },
      );
}