import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wwe_universe/classes/IRL/IRLSuperstars.dart';
import 'package:wwe_universe/NavBar.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/pages/IRL/IRLSuperstars/AddEditIRLSuperstarsPage.dart';
import 'package:wwe_universe/pages/IRL/IRLSuperstars/IRLSuperstarsDetailPage.dart';

class IRLSuperstarsPage extends StatefulWidget{
  const IRLSuperstarsPage({super.key});

  @override
  _IRLSuperstarsPage createState() => _IRLSuperstarsPage();
}

class _IRLSuperstarsPage extends State<IRLSuperstarsPage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        drawer: const Navbar(),
        appBar: AppBar(
          title: const Text(
            'Superstars',
          ),
          // actions: const [Icon(Icons.search), SizedBox(width: 12)],
        ),
        body: Column(children : [
          Flexible(
          child: StreamBuilder<List<IRLSuperstars>>(
            stream: readAllIRLSuperstars(),
            builder: (BuildContext context, snapshot) {
            if (snapshot.hasError) {
              return const Text('Something went wrong');
            }

            else if(snapshot.hasData){
              final irlSuperstars = snapshot.data!;
              return ListView(
                padding: const EdgeInsets.all(8),
                children: irlSuperstars.map(buildIRLSuperstars).toList()
              ,);
            }
            else{
              return const CircularProgressIndicator();
            }
          }),
        )]),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.black,
          child: const Icon(Icons.add),
          onPressed: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const AddEditIRLSuperstarsPage()),
            );
          },
        ),
      );


  Widget buildIRLSuperstars(IRLSuperstars irlSuperstars) {
          return GestureDetector( 
            onTap: () async {
              await Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => IRLSuperstarsDetailPage(irlSuperstars: irlSuperstars),
            ));
            },
            child :SizedBox(
            height: 80,
            child : Card(
              shape:RoundedRectangleBorder(
              side: const BorderSide(color: Color.fromARGB(189, 96, 125, 139)),
              borderRadius: BorderRadius.circular(4.0)),
              // margin: EdgeInsets.all(12),
              elevation: 2,
              child: Padding(
                
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft, 
                        child: Text('${irlSuperstars.prenom} ${irlSuperstars.nom}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), 
                      )
                    ),
                    const Spacer(),
                    Container(child : ((){ if(irlSuperstars.show != 'Aucun') return Image(image: AssetImage('assets/${irlSuperstars.show.toLowerCase()}.png'));}()))
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