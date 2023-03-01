import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wwe_universe/classes/Universe/UniverseNews.dart';
import 'package:wwe_universe/classes/Universe/UniverseShows.dart';
import 'package:wwe_universe/NavBar.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/database.dart';
import 'package:wwe_universe/pages/Universe/UniverseNews/AddEditUniverseNewsPage.dart';
import 'package:wwe_universe/pages/Universe/UniverseNews/UniverseNewsDetailPage.dart';
import 'package:wwe_universe/pages/Universe/UniverseShows/AddEditUniverseShowsPage.dart';
import 'package:wwe_universe/pages/Universe/UniverseShows/UniverseShowsDetailPage.dart';

class UniverseShowsPage extends StatefulWidget{
  @override
  _UniverseShowsPage createState() => _UniverseShowsPage();
}

class _UniverseShowsPage extends State<UniverseShowsPage> {
  late List<UniverseShows> showsList;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    refreshShows();
  }

  Future refreshShows() async {
    setState(() => isLoading = true);

    this.showsList = await UniverseDatabase.instance.readAllShows();

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    drawer: Navbar(),
    appBar: AppBar(
      title: const Text('Shows'),
      // actions: [Icon(Icons.search), SizedBox(width: 12)],
    ),
    body: Center(
          child: isLoading
            ? const CircularProgressIndicator()
            : showsList.isEmpty
              ? const Text(
                'No created shows'
              )
            : buildUniverseShows(),
        ),
    floatingActionButton: FloatingActionButton(
      backgroundColor: Colors.black,
      child: const Icon(Icons.add),
      onPressed: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => AddEditUniverseShowsPage()),
        );

        refreshShows();
      },
    ),
  );


    Widget buildUniverseShows() => ListView.builder(
      padding: EdgeInsets.all(8),
      itemCount : showsList.length,
      itemBuilder: (context, index){
      final show = showsList[index];
      String image = 'assets/${show.nom.toLowerCase()}.png';
      return GestureDetector(
        onTap: () async {
          await Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => UniverseShowsDetailPage(showId: show.id!),
          )).then((value) => refreshShows());;
        },
        child:  Container( 
        height: 80,
        child:Card(
          shape:RoundedRectangleBorder(
            side: new BorderSide(color: Color.fromARGB(189, 96, 125, 139)),
            borderRadius: BorderRadius.circular(4.0)),
            // margin: EdgeInsets.all(12),
            elevation: 2,      
            child: Container(child: Padding(
              padding:  const EdgeInsets.symmetric(vertical:8.0, horizontal: 16),
              child: Row(
              children: [
                Expanded(child: 
                  FittedBox(fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft, 
                    child: show.nom.toLowerCase() == 'raw' || 
                    show.nom.toLowerCase() == 'smackdown' ||
                    show.nom.toLowerCase() == 'nxt' ?
                    Image(image: AssetImage(image))
                    : Text(show.nom, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),)),
                Spacer(),
                  Container(
                    child: Text('Year ${show.annee} Week ${show.semaine}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18), )
                  ),                      
                ],)
            ))
            )
          )
        );
  });
}
