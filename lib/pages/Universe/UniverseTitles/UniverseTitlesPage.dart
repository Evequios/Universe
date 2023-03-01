import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wwe_universe/classes/Universe/UniverseBrands.dart';
import 'package:wwe_universe/classes/Universe/UniverseSuperstars.dart';
import 'package:wwe_universe/classes/Universe/UniverseTitles.dart';
import 'package:wwe_universe/NavBar.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/database.dart';
import 'package:wwe_universe/pages/Universe/UniverseTitles/AddEditUniverseTitlesPage.dart';
import 'package:wwe_universe/pages/Universe/UniverseTitles/UniverseTitlesDetailPage.dart';



class UniverseTitlesPage extends StatefulWidget{
  @override
  _UniverseTitlesPageState createState() => _UniverseTitlesPageState();
}

class _UniverseTitlesPageState extends State<UniverseTitlesPage> {
  UniverseBrands defaultBrand = UniverseBrands(nom: 'nom');
  late List<UniverseTitles> titlesList;
  late List<UniverseSuperstars> superstarsList;
  late List<UniverseBrands> brandsList;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    refreshTitles();
  }

  Future refreshTitles() async {
    setState(() => isLoading = true);

    this.titlesList = await UniverseDatabase.instance.readAllTitles();
    this.superstarsList = await UniverseDatabase.instance.readAllSuperstars();
    this.brandsList = await UniverseDatabase.instance.readAllBrands();

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    drawer: Navbar(),
    appBar: AppBar(
      title: const Text(
        'Titles',
      ),
    ),
    body: Center(
      child: isLoading
        ? const CircularProgressIndicator()
        : titlesList.isEmpty
          ? const Text(
            'No created titles'
          )
        : buildUniverseTitles(),
    ),
    floatingActionButton: FloatingActionButton(
      backgroundColor: Colors.black,
      child: const Icon(Icons.add),
      onPressed: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => AddEditUniverseTitlesPage(listBrands: brandsList, listSuperstars: superstarsList,)),
        );

        refreshTitles();
      },
    ),
  );

  Widget buildUniverseTitles() => ListView.builder(
    padding : EdgeInsets.all(8),
    itemCount: titlesList.length,
    itemBuilder: (context, index){
      final title = titlesList[index];
      UniverseBrands brand = defaultBrand;
      if (title.brand != 0) brand = brandsList.firstWhere((brand) => brand.id == title.brand);
      if (title.holder1 != 0) final h1 = superstarsList.firstWhere((h1) => h1.id == title.holder1);
      if (title.holder2 != 0) final h2 = superstarsList.firstWhere((h2) => h2.id == title.holder2);
      return GestureDetector( 
        onTap: () async {
          await Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => UniverseTitlesDetailPage(titleId: title.id!, brandId: title.brand, h1Id: title.holder1, h2Id: title.holder2,),
          )).then((value) => refreshTitles());
        },
        child :Container(
          height: 100,
          child : Card(
            shape:RoundedRectangleBorder(
              side: new BorderSide(color: Color.fromARGB(189, 96, 125, 139)),
              borderRadius: BorderRadius.circular(4.0)
            ),
              // margin: EdgeInsets.all(12),
            elevation: 2,
            child: Padding(    
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('${title.nom}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      alignment: Alignment.centerLeft, 
                    )
                  ),
                  Spacer(),
                  Container(child : ((){ if(brand.nom == 'Raw' || brand.nom == 'SmackDown') return Image(image: AssetImage('assets/${brand.nom.toLowerCase()}.png'));}())),
                ]),
              )
            )
          )
      );
    }
  );
}