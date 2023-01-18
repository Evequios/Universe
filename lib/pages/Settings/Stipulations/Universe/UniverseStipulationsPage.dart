import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wwe_universe/classes/Universe/UniverseStipulations.dart';
import 'package:wwe_universe/NavBar.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/pages/Settings/Stipulations/Universe/AddEditUniverseStipulationsPage.dart';
import 'package:wwe_universe/pages/Settings/Stipulations/Universe/UniverseStipulationsDetailPage.dart';



class UniverseStipulationsPage extends StatefulWidget{
  @override
  _UniverseStipulationsPageState createState() => _UniverseStipulationsPageState();
}

class _UniverseStipulationsPageState extends State<UniverseStipulationsPage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        // backgroundColor: Color.fromARGB(227, 242, 237, 237),
        drawer: Navbar(),
        appBar: AppBar(
          title: const Text(
            'Stipulations',
            // style : TextStyle(fontWeight: FontWeight.bold,fontSize: 22)
          ),
          actions: const [Icon(Icons.search), SizedBox(width: 12)],
          
        ),
        body: Center(
          child: StreamBuilder<List<UniverseStipulations>>(
            stream: readAllUniverseStipulations(),
            builder: (BuildContext context, snapshot) {
            if (snapshot.hasError) {
              return Text('Something went wrong');
            }

            else if(snapshot.hasData){
              final universeStipulations = snapshot.data!;

              return ListView(
                padding: EdgeInsets.all(12),
                children: universeStipulations.map(buildUniverseStipulations).toList()
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
              MaterialPageRoute(builder: (context) => AddEditUniverseStipulationsPage()),
            );
          },
        ),
      );

  Widget buildUniverseStipulations(UniverseStipulations universeStipulations) {
  return Card(
            shape:RoundedRectangleBorder(
              side: new BorderSide(color: Color.fromARGB(189, 96, 125, 139)),
              borderRadius: BorderRadius.circular(4.0)),
              elevation : 2,
              child: ListTile(
              onTap: () async {
                await Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => UniverseStipulationsDetailPage(universeStipulations: universeStipulations),
              ));
              },
              title: Text('${universeStipulations.type} ${universeStipulations.stipulation}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              // subtitle: Text('${universeStipulations.createdTime.toDate().day}/${universeStipulations.createdTime.toDate().month}/${universeStipulations.createdTime.toDate().year}  ${universeStipulations.createdTime.toDate().hour}h${universeStipulations.createdTime.toDate().minute.toString().padLeft(2, '0')}                                      ${universeStipulations.categorie}'),
              ));
  }

  Stream<List<UniverseStipulations>> readAllUniverseStipulations() => 
  FirebaseFirestore.instance.collection('UniverseStipulations').orderBy('type').snapshots().map((snapshot) => 
    snapshot.docs.map((doc) => UniverseStipulations.fromJson(doc.data())).toList());
}