import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wwe_universe/classes/IRLNews.dart';
import 'package:wwe_universe/classes/IRLSuperstars.dart';
import 'package:wwe_universe/NavBar.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/pages/IRLNews/AddEditIRLNewsPage.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:wwe_universe/pages/IRLNews/IRLNewsDetailPage.dart';
import 'package:wwe_universe/pages/IRLSuperstars/AddEditIRLSuperstarsPage.dart';
import 'package:wwe_universe/pages/IRLSuperstars/IRLSuperstarsDetailPage.dart';

class IRLSuperstarsPage extends StatefulWidget{
  @override
  _IRLSuperstarsPage createState() => _IRLSuperstarsPage();
}

class _IRLSuperstarsPage extends State<IRLSuperstarsPage> {
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
          child: StreamBuilder<List<IRLSuperstars>>(
            stream: readAllIRLSuperstars(),
            builder: (BuildContext context, snapshot) {
            if (snapshot.hasError) {
              return Text('Something went wrong');
            }

            else if(snapshot.hasData){
              final irlSuperstars = snapshot.data!;

              return ListView(
                padding: EdgeInsets.all(8),
                children: irlSuperstars.map(buildIRLSuperstars).toList()
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
              MaterialPageRoute(builder: (context) => AddEditIRLSuperstarsPage()),
            );
          },
        ),
      );


  Widget buildIRLSuperstars(IRLSuperstars irlSuperstars) {
          return GestureDetector( 
            onTap: () async {
              await Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => IRLSuperstarsDetailPage(irlSuperstars: irlSuperstars),
            ));},
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
                        Text('${irlSuperstars.prenom} ${irlSuperstars.nom}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                        Spacer(),
                        Image(image: AssetImage('assets/${irlSuperstars.show.toLowerCase()}.png'))
                  ],
                )
              )
            )
          ));
    }

    Stream<List<IRLSuperstars>> readAllIRLSuperstars() => 
    FirebaseFirestore.instance.collection('IRLSuperstars').orderBy('prenom').snapshots().map((snapshot) => 
      snapshot.docs.map((doc) => IRLSuperstars.fromJson(doc.data())).toList());
}