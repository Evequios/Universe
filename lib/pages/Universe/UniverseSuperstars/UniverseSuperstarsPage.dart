import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wwe_universe/classes/Universe/UniverseNews.dart';
import 'package:wwe_universe/classes/Universe/UniverseSuperstars.dart';
import 'package:wwe_universe/NavBar.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/pages/Universe/UniverseNews/AddEditUniverseNewsPage.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:wwe_universe/pages/Universe/UniverseNews/UniverseNewsDetailPage.dart';
import 'package:wwe_universe/pages/Universe/UniverseSuperstars/AddEditUniverseSuperstarsPage.dart';
import 'package:wwe_universe/pages/Universe/UniverseSuperstars/UniverseSuperstarsDetailPage.dart';

class UniverseSuperstarsPage extends StatefulWidget{
  @override
  _UniverseSuperstarsPage createState() => _UniverseSuperstarsPage();
}

class _UniverseSuperstarsPage extends State<UniverseSuperstarsPage> {
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        drawer: Navbar(),
        appBar: AppBar(
          title: const Text(
            'Superstars',
          ),
          actions: const [Icon(Icons.search), SizedBox(width: 12)],
        ),
        body: Center(
          child: StreamBuilder<List<UniverseSuperstars>>(
            stream: readAllUniverseSuperstars(),
            builder: (BuildContext context, snapshot) {
            if (snapshot.hasError) {
              return Text('Something went wrong');
            }

            else if(snapshot.hasData){
              final universeSuperstars = snapshot.data!;

              return ListView(
                padding: EdgeInsets.all(8),
                children: universeSuperstars.map(buildUniverseSuperstars).toList()
              ,);
            }
            else{
              return CircularProgressIndicator();
            }
          }),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.black,
          child: const Icon(Icons.add),
          onPressed: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => AddEditUniverseSuperstarsPage()),
            );
          },
        ),
      );


  Widget buildUniverseSuperstars(UniverseSuperstars universeSuperstars) {
          return GestureDetector( 
            onTap: () async {
              await Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => UniverseSuperstarsDetailPage(universeSuperstars: universeSuperstars),
            ));
            },
            child :Container(
            height: 100,
            child : Card(
              shape:RoundedRectangleBorder(
              side: new BorderSide(color: Color.fromARGB(189, 96, 125, 139)),
              borderRadius: BorderRadius.circular(4.0)),
              margin: EdgeInsets.all(12),
              elevation: 2,
              child: Padding(
                
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
                child: Row(
                  children: [
                    universeSuperstars.titre == null ? 
                    Text('${universeSuperstars.prenom} ${universeSuperstars.nom}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),)
                    //  : Text('${universeSuperstars.titre} champion ${universeSuperstars.prenom} ${universeSuperstars.nom}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                    : Text('${universeSuperstars.prenom} ${universeSuperstars.nom}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                    // Text('${universeSuperstars.prenom} ${universeSuperstars.nom}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                    Spacer(),
                    Image(image: AssetImage('assets/${universeSuperstars.show.toLowerCase()}.png'))
                  ],
                )
              )
            )
          ));
    }

    Stream<List<UniverseSuperstars>> readAllUniverseSuperstars() => 
    FirebaseFirestore.instance.collection('UniverseSuperstars').orderBy('prenom').snapshots().map((snapshot) => 
      snapshot.docs.map((doc) => UniverseSuperstars.fromJson(doc.data())).toList());
}