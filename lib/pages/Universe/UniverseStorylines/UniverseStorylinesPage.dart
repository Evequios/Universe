import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wwe_universe/classes/Universe/UniverseStorylines.dart';
import 'package:wwe_universe/NavBar.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/pages/Universe/UniverseStorylines/AddEditUniverseStorylinesPage.dart';
import 'package:wwe_universe/pages/Universe/UniverseStorylines/UniverseStorylinesDetailPage.dart';

class UniverseStorylinesPage extends StatefulWidget{
  @override
  _UniverseStorylinesPage createState() => _UniverseStorylinesPage();
}

class _UniverseStorylinesPage extends State<UniverseStorylinesPage> {
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
            'Storylines',
          ),
          actions: const [Icon(Icons.search), SizedBox(width: 12)],
        ),
        body: Center(
          child: StreamBuilder<List<UniverseStorylines>>(
            stream: readAllUniverseStorylines(),
            builder: (BuildContext context, snapshot) {
            if (snapshot.hasError) {
              return Text('Something went wrong');
            }

            else if(snapshot.hasData){
              final universeStorylines = snapshot.data!;

              return ListView(
                padding: EdgeInsets.all(8),
                children: universeStorylines.map(buildUniverseStorylines).toList()
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
              MaterialPageRoute(builder: (context) => AddEditUniverseStorylinesPage()),
            );
          },
        ),
      );


  Widget buildUniverseStorylines(UniverseStorylines universeStorylines) {
            return Card(
              shape:RoundedRectangleBorder(
              side: new BorderSide(color: Color.fromARGB(189, 96, 125, 139)),
              borderRadius: BorderRadius.circular(4.0)),
              elevation : 2,
              child: ListTile(
              onTap: () async {
                
                await Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => UniverseStorylinesDetailPage(universeStorylines: universeStorylines),
              ));
              },
              title: Text(universeStorylines.titre, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              subtitle: Row(
                children: [
                Text('Début : Semaine ${universeStorylines.debut}',style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blueGrey)),
                const Spacer(),
                Text('Fin : Semaine ${universeStorylines.fin}', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blueGrey)),
              ])
            ));
  }

  Stream<List<UniverseStorylines>> readAllUniverseStorylines() => 
    FirebaseFirestore.instance.collection('UniverseStorylines').orderBy('debut', descending: true).snapshots().map((snapshot) => 
      snapshot.docs.map((doc) => UniverseStorylines.fromJson(doc.data())).toList());
}