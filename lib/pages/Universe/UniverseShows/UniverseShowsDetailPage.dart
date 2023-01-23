import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/Universe/UniverseMatches.dart';
import 'package:wwe_universe/classes/Universe/UniverseShows.dart';
import 'package:wwe_universe/pages/Universe/UniverseMatches/AddEditUniverseMatchesPage.dart';
import 'package:wwe_universe/pages/Universe/UniverseMatches/UniverseMatchesDetailPage.dart';
import 'package:wwe_universe/pages/Universe/UniverseShows/AddEditUniverseShowsPage.dart';

class UniverseShowsDetailPage extends StatefulWidget {
  final UniverseShows universeShows;

  const UniverseShowsDetailPage({
    Key? key,
    required this.universeShows,
  }) : super(key: key);

  @override
  _UniverseShowsDetailPage createState() => _UniverseShowsDetailPage();
}

class _UniverseShowsDetailPage extends State<UniverseShowsDetailPage> {
  late UniverseShows? universeShows = widget.universeShows;
  late List<UniverseMatches> matchesList;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text(
        'Matchs',
      ),
      actions: [editButton(), deleteButton()]
    ),
    body: Center(
          child: StreamBuilder<List<UniverseMatches>>(
            stream: readAllUniverseMatches(),
            builder: (BuildContext context, snapshot) {
            if (snapshot.hasError) {
              return Text('Something went wrong');
            }

            else if(snapshot.hasData){
              final universeMatches = snapshot.data!;

              return ListView(
                padding: EdgeInsets.all(12),
                children: universeMatches.map(buildUniverseMatches).toList()
              ,);
            }
            else{
              return CircularProgressIndicator();
            }
          }),
        ),
    floatingActionButton: FloatingActionButton(
      backgroundColor: Colors.black,
      child : const Icon(Icons.add),
      onPressed: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => AddEditUniverseMatchesPage(universeShows :widget.universeShows)),
        );
      } ),
  );
  
  Widget buildUniverseMatches(UniverseMatches universeMatches) {
            return Container(
              height: 80,
              child: Card(
              shape:RoundedRectangleBorder(
              side: new BorderSide(color: Color.fromARGB(189, 96, 125, 139)),
              borderRadius: BorderRadius.circular(4.0)),
              elevation : 2,
              child: ListTile(
              onTap: () async {
                await Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => UniverseMatchesDetailPage(universeMatches: universeMatches, universeShows: universeShows!,),
              ));
              },
              title: Text(universeMatches.stipulation, style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(universeMatches.stipulation, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),

            )));
  }

  Widget editButton() => IconButton(
      icon: Icon(Icons.edit_outlined),
      onPressed: () async {
        if (isLoading) return;

        await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => AddEditUniverseShowsPage(universeShows : universeShows),
        ));
      });

  Widget deleteButton() => IconButton(
        icon: Icon(Icons.delete),
        onPressed: () {
          final docUniverseShows= FirebaseFirestore.instance.collection('UniverseShows').doc(universeShows!.id);
          docUniverseShows.delete();
          Navigator.of(context).pop();
        },
  );

  Stream<List<UniverseMatches>> readAllUniverseMatches() => 
    FirebaseFirestore.instance.collection('UniverseMatches').where('showId', isEqualTo: universeShows!.id).orderBy('ordre').snapshots().map((snapshot) => 
      snapshot.docs.map((doc) => UniverseMatches.fromJson(doc.data())).toList());
}



