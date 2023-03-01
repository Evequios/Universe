import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wwe_universe/classes/Universe/UniverseStipulations.dart';
import 'package:wwe_universe/NavBar.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/database.dart';
import 'package:wwe_universe/pages/Settings/Stipulations/Universe/AddEditUniverseStipulationsPage.dart';
import 'package:wwe_universe/pages/Settings/Stipulations/Universe/UniverseStipulationsDetailPage.dart';



class UniverseStipulationsPage extends StatefulWidget{
  @override
  _UniverseStipulationsPageState createState() => _UniverseStipulationsPageState();
}

class _UniverseStipulationsPageState extends State<UniverseStipulationsPage> {
  late List<UniverseStipulations> stipulationsList;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    refreshStipulations();
  }

  Future refreshStipulations() async {
    setState(() => isLoading = true);

    this.stipulationsList = await UniverseDatabase.instance.readAllStipulations();

    setState(() => isLoading = false);
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
          child: isLoading
            ? const CircularProgressIndicator()
            : stipulationsList.isEmpty
              ? const Text(
                'No created stipulations'
              )
            : buildUniverseStipulations(),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.black,
          child: const Icon(Icons.add),
          onPressed: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => AddEditUniverseStipulationsPage()),
            );

            refreshStipulations();
          },
        ),
      );

  Widget buildUniverseStipulations() => ListView.builder(
    padding: EdgeInsets.all(8),
    itemCount: stipulationsList.length,
    itemBuilder: (context, index) {
      final stipulation = stipulationsList[index];
  return Card(
            shape:RoundedRectangleBorder(
              side: new BorderSide(color: Color.fromARGB(189, 96, 125, 139)),
              borderRadius: BorderRadius.circular(4.0)),
              elevation : 2,
              child: ListTile(
              onTap: () async {
                await Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => UniverseStipulationsDetailPage(stipulationId: stipulation.id!),
              )).then((value) => refreshStipulations());;
              },
              title: Text('${stipulation.type} ${stipulation.stipulation}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              // subtitle: Text('${universeStipulations.createdTime.toDate().day}/${universeStipulations.createdTime.toDate().month}/${universeStipulations.createdTime.toDate().year}  ${universeStipulations.createdTime.toDate().hour}h${universeStipulations.createdTime.toDate().minute.toString().padLeft(2, '0')}                                      ${universeStipulations.categorie}'),
              ));
  });
}