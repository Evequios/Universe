import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wwe_universe/classes/IRL/IRLStorylines.dart';
import 'package:wwe_universe/NavBar.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/pages/IRL/IRLStorylines/AddEditIRLStorylinesPage.dart';
import 'package:wwe_universe/pages/IRL/IRLStorylines/IRLStorylinesDetailPage.dart';

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
          // actions: const [Icon(Icons.search), SizedBox(width: 12)],
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
              color : irlStorylines.fin != '' ? Colors.white70 : Colors.white,
              shape:RoundedRectangleBorder(
              side: new BorderSide(color: Color.fromARGB(189, 96, 125, 139)),
              borderRadius: BorderRadius.circular(4.0)),
              elevation : 2,
              child: ListTile(
              onTap: () async {
                
                await Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => IRLStorylinesDetailPage(irlStorylines: irlStorylines),
              ));
              },
              title: Text(irlStorylines.titre, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              subtitle: Row(
                children: [
                Text('Début : ${irlStorylines.debut}',style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blueGrey)),
                const Spacer(),
                Text('Fin : ${irlStorylines.fin}', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blueGrey)),
              ])
            ));
  }

  Stream<List<IRLStorylines>> readAllIRLStorylines() => 
    FirebaseFirestore.instance.collection('IRLStorylines').orderBy('debut', descending: true).snapshots().map((snapshot) => 
      snapshot.docs.map((doc) => IRLStorylines.fromJson(doc.data())).toList());
}