import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wwe_universe/classes/Universe/UniverseTitles.dart';
import 'package:wwe_universe/NavBar.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/pages/Settings/Titles/Universe/AddEditUniverseTitlesPage.dart';
import 'package:wwe_universe/pages/Settings/Titles/Universe/UniverseTitlesDetailPage.dart';



class UniverseTitlesPage extends StatefulWidget{
  @override
  _UniverseTitlesPageState createState() => _UniverseTitlesPageState();
}

class _UniverseTitlesPageState extends State<UniverseTitlesPage> {

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
            'Titles',
            // style : TextStyle(fontWeight: FontWeight.bold,fontSize: 22)
          ),
          actions: const [Icon(Icons.search), SizedBox(width: 12)],
          
        ),
        body: Center(
          child: StreamBuilder<List<UniverseTitles>>(
            stream: readAllUniverseTitles(),
            builder: (BuildContext context, snapshot) {
            if (snapshot.hasError) {
              return Text('Something went wrong');
            }

            else if(snapshot.hasData){
              final universeTitles = snapshot.data!;

              return ListView(
                padding: EdgeInsets.all(12),
                children: universeTitles.map(buildUniverseTitles).toList()
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
              MaterialPageRoute(builder: (context) => AddEditUniverseTitlesPage()),
            );
          },
        ),
      );

  Widget buildUniverseTitles(UniverseTitles universeTitles) {
  return Card(
            shape:RoundedRectangleBorder(
              side: new BorderSide(color: Color.fromARGB(189, 96, 125, 139)),
              borderRadius: BorderRadius.circular(4.0)),
              elevation : 2,
              child: ListTile(
              onTap: () async {
                await Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => UniverseTitlesDetailPage(universeTitles: universeTitles),
              ));
              },
              title: Text('${universeTitles.nom} Championship', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              subtitle: universeTitles.tag == 'false' ? 
                Text('${universeTitles.holder1}')
                : Text('${universeTitles.holder1} & ${universeTitles.holder2}'),
              // subtitle: Text('${universeTitles.createdTime.toDate().day}/${universeTitles.createdTime.toDate().month}/${universeTitles.createdTime.toDate().year}  ${universeTitles.createdTime.toDate().hour}h${universeTitles.createdTime.toDate().minute.toString().padLeft(2, '0')}                                      ${universeTitles.categorie}'),
              ));
  }

  Stream<List<UniverseTitles>> readAllUniverseTitles() => 
  FirebaseFirestore.instance.collection('UniverseTitles').orderBy('nom').snapshots().map((snapshot) => 
    snapshot.docs.map((doc) => UniverseTitles.fromJson(doc.data())).toList());
}