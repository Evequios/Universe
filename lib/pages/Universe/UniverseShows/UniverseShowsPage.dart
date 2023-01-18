import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wwe_universe/classes/Universe/UniverseNews.dart';
import 'package:wwe_universe/classes/Universe/UniverseShows.dart';
import 'package:wwe_universe/NavBar.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/pages/Universe/UniverseNews/AddEditUniverseNewsPage.dart';
import 'package:wwe_universe/pages/Universe/UniverseNews/UniverseNewsDetailPage.dart';
import 'package:wwe_universe/pages/Universe/UniverseShows/AddEditUniverseShowsPage.dart';
import 'package:wwe_universe/pages/Universe/UniverseShows/UniverseShowsDetailPage.dart';

class UniverseShowsPage extends StatefulWidget{
  @override
  _UniverseShowsPage createState() => _UniverseShowsPage();
}

class _UniverseShowsPage extends State<UniverseShowsPage> {
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
            'Shows',
          ),
          actions: [Icon(Icons.search), SizedBox(width: 12)],
        ),
        body: Center(
          child: StreamBuilder<List<UniverseShows>>(
            stream: readAllUniverseShows(),
            builder: (BuildContext context, snapshot) {
            if (snapshot.hasError) {
              return Text('Something went wrong');
            }

            else if(snapshot.hasData){
              final universeShows = snapshot.data!;

              return ListView(
                padding: EdgeInsets.all(8),
                children: universeShows.map(buildUniverseShows).toList()
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
              MaterialPageRoute(builder: (context) => AddEditUniverseShowsPage()),
            );
          },
        ),
      );


      Widget buildUniverseShows(UniverseShows universeShows) {
        String image = 'assets/${universeShows.nom.toLowerCase()}.png';
        return GestureDetector(
            onTap: () async {
              await Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => UniverseShowsDetailPage(universeShows: universeShows),
              ));},
            child:  Container( 
              height: 100,
              child:Card(
              shape:RoundedRectangleBorder(
              side: new BorderSide(color: Color.fromARGB(189, 96, 125, 139)),
              borderRadius: BorderRadius.circular(4.0)),
              margin: EdgeInsets.all(12),
              elevation: 2,
              
              child: Container(child: Padding(
                padding:  const EdgeInsets.symmetric(vertical:8.0, horizontal: 16),
                child: Row(
                    children: [Flexible(child:
                      universeShows.nom.toLowerCase() == 'raw' || 
                        universeShows.nom.toLowerCase() == 'smackdown' ||
                        universeShows.nom.toLowerCase() == 'nxt' ?
                        Image(image: AssetImage(image))
                        : Text(universeShows.nom, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    ),
                      Spacer(),
                      Container(
                      child:
                      Text('${universeShows.date}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18), )
                      ),
                        Spacer(),
                        
                    ],)
            ))
            )
          )
        );
  }

  Stream<List<UniverseShows>> readAllUniverseShows() => 
    FirebaseFirestore.instance.collection('UniverseShows').orderBy('date', descending: true).snapshots().map((snapshot) => 
      snapshot.docs.map((doc) => UniverseShows.fromJson(doc.data())).toList());
}
