import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wwe_universe/classes/IRLStorylines.dart';
import 'package:wwe_universe/NavBar.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/pages/IRLStorylines/AddEditIRLStorylinesPage.dart';
import 'package:wwe_universe/pages/IRLStorylines/IRLStorylinesDetailPage.dart';

class IRLStorylinesPage extends StatefulWidget{
  @override
  _IRLStorylinesPage createState() => _IRLStorylinesPage();
}

class _IRLStorylinesPage extends State<IRLStorylinesPage> {
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
          child: StreamBuilder<List<IRLStorylines>>(
            stream: readAllIRLStorylines(),
            builder: (BuildContext context, snapshot) {
            if (snapshot.hasError) {
              return Text('Something went wrong');
            }

            else if(snapshot.hasData){
              final irlStorylines = snapshot.data!;

              return ListView(
                padding: EdgeInsets.all(8),
                children: irlStorylines.map(buildIRLStorylines).toList()
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
              MaterialPageRoute(builder: (context) => AddEditIRLStorylinesPage()),
            );
          },
        ),
      );


  Widget buildIRLStorylines(IRLStorylines irlStorylines) {
            return Card(
              elevation : 4,
              child: ListTile(
              onTap: () async {
                
                await Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => IRLStorylinesDetailPage(irlStorylines: irlStorylines),
              ));
              },
              title: Text(irlStorylines.titre, style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Début : ${irlStorylines.debut}       Fin : ${irlStorylines.fin}'),
            ));
  }

  Stream<List<IRLStorylines>> readAllIRLStorylines() => 
    FirebaseFirestore.instance.collection('IRLStorylines').orderBy('debut', descending: true).snapshots().map((snapshot) => 
      snapshot.docs.map((doc) => IRLStorylines.fromJson(doc.data())).toList());
}