import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wwe_universe/classes/IRL/IRLStipulations.dart';
import 'package:wwe_universe/NavBar.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/pages/Settings/Stipulations/IRL/AddEditIRLStipulationsPage.dart';
import 'package:wwe_universe/pages/Settings/Stipulations/IRL/IRLStipulationsDetailPage.dart';



class IRLStipulationsPage extends StatefulWidget{
  const IRLStipulationsPage({super.key});

  @override
  _IRLStipulationsPageState createState() => _IRLStipulationsPageState();
}

class _IRLStipulationsPageState extends State<IRLStipulationsPage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        // backgroundColor: Color.fromARGB(227, 242, 237, 237),
        drawer: const Navbar(),
        appBar: AppBar(
          title: const Text(
            'Stipulations',
            // style : TextStyle(fontWeight: FontWeight.bold,fontSize: 22)
          ),
          actions: const [Icon(Icons.search), SizedBox(width: 12)],
          
        ),
        body: Center(
          child: StreamBuilder<List<IRLStipulations>>(
            stream: readAllIRLStipulations(),
            builder: (BuildContext context, snapshot) {
            if (snapshot.hasError) {
              return const Text('Something went wrong');
            }

            else if(snapshot.hasData){
              final irlStipulations = snapshot.data!;

              return ListView(
                padding: const EdgeInsets.all(12),
                children: irlStipulations.map(buildIRLStipulations).toList()
              ,);
            }
            else{
              return const CircularProgressIndicator();
            }
          }),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.black,
          child: const Icon(Icons.add),
          onPressed: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const AddEditIRLStipulationsPage()),
            );
          },
        ),
      );

  Widget buildIRLStipulations(IRLStipulations irlStipulations) {
  return Card(
            shape:RoundedRectangleBorder(
              side: const BorderSide(color: Color.fromARGB(189, 96, 125, 139)),
              borderRadius: BorderRadius.circular(4.0)),
              elevation : 2,
              child: ListTile(
              onTap: () async {
                await Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => IRLStipulationsDetailPage(irlStipulations: irlStipulations),
              ));
              },
              title: Text('${irlStipulations.type} ${irlStipulations.stipulation}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              // subtitle: Text('${irlStipulations.createdTime.toDate().day}/${irlStipulations.createdTime.toDate().month}/${irlStipulations.createdTime.toDate().year}  ${irlStipulations.createdTime.toDate().hour}h${irlStipulations.createdTime.toDate().minute.toString().padLeft(2, '0')}                                      ${irlStipulations.categorie}'),
              ));
  }

  Stream<List<IRLStipulations>> readAllIRLStipulations() => 
  FirebaseFirestore.instance.collection('IRLStipulations').orderBy('type').snapshots().map((snapshot) => 
    snapshot.docs.map((doc) => IRLStipulations.fromJson(doc.data())).toList());
}