import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wwe_universe/classes/Universe/UniverseBrands.dart';
import 'package:wwe_universe/classes/Universe/UniverseNews.dart';
import 'package:wwe_universe/classes/Universe/UniverseSuperstars.dart';
import 'package:wwe_universe/NavBar.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/database.dart';
import 'package:wwe_universe/pages/Universe/UniverseNews/AddEditUniverseNewsPage.dart';
import 'package:wwe_universe/pages/Universe/UniverseNews/UniverseNewsDetailPage.dart';
import 'package:wwe_universe/pages/Universe/UniverseSuperstars/AddEditUniverseSuperstarsPage.dart';
import 'package:wwe_universe/pages/Universe/UniverseSuperstars/UniverseSuperstarsDetailPage.dart';

class UniverseSuperstarsPage extends StatefulWidget{
  @override
  _UniverseSuperstarsPage createState() => _UniverseSuperstarsPage();
}

class _UniverseSuperstarsPage extends State<UniverseSuperstarsPage> {
  UniverseBrands defaultBrand = UniverseBrands(nom: 'nom');
  late List<UniverseSuperstars> superstarsList;
  late List<UniverseBrands> brandsList;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    refreshSuperstars();
  }

  Future refreshSuperstars() async {
    setState(() => isLoading = true);

    this.superstarsList = await UniverseDatabase.instance.readAllSuperstars();
    this.brandsList = await UniverseDatabase.instance.readAllBrands();

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        drawer: Navbar(),
        appBar: AppBar(
          title: const Text(
            'Superstars',
          ),
          // actions: const [Icon(Icons.search), SizedBox(width: 12)],
        ),
        body: Center(
          child: isLoading
            ? const CircularProgressIndicator()
            : superstarsList.isEmpty
              ? const Text(
                'No created superstars'
              )
            : buildUniverseSuperstars(),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.black,
          child: const Icon(Icons.add),
          onPressed: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => AddEditUniverseSuperstarsPage(listBrands: brandsList,))
            );

            refreshSuperstars();
          },
        ),
      );


  Widget buildUniverseSuperstars() => ListView.builder(
    padding : EdgeInsets.all(8),
    itemCount: superstarsList.length,
    itemBuilder: (context, index){
      final superstar = superstarsList[index];
      UniverseBrands brand = defaultBrand; 
      if(superstar.brand != 0) brand = brandsList.firstWhere((brand) => brand.id == superstar.brand);
      return GestureDetector( 
        onTap: () async {
          await Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => UniverseSuperstarsDetailPage(superstarId: superstar.id!),
          )).then((value) => refreshSuperstars());
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
                    flex:10,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('${superstar.nom}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      alignment: Alignment.centerLeft, 
                    )
                  ),
                  Spacer(),
                  Container(child : ((){ if(superstar.brand != 0 && (brand.nom.toLowerCase() == 'raw' || brand.nom.toLowerCase() == 'smackdown' || brand.nom.toLowerCase() == 'nxt')) return Image(image: AssetImage('assets/${brand.nom.toLowerCase()}.png'));}()))
                ],
              )
            )
          )
        )
      );
    }
  );
}
