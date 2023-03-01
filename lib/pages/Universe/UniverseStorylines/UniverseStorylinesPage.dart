import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wwe_universe/classes/Universe/UniverseStorylines.dart';
import 'package:wwe_universe/NavBar.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/database.dart';
import 'package:wwe_universe/pages/Universe/UniverseStorylines/AddEditUniverseStorylinesPage.dart';
import 'package:wwe_universe/pages/Universe/UniverseStorylines/UniverseStorylinesDetailPage.dart';

class UniverseStorylinesPage extends StatefulWidget{
  @override
  _UniverseStorylinesPage createState() => _UniverseStorylinesPage();
}

class _UniverseStorylinesPage extends State<UniverseStorylinesPage> {
  late List<UniverseStorylines> storylinesList;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    refreshStorylines();
  }

  Future refreshStorylines() async {
    setState(() => isLoading = true);

    this.storylinesList = await UniverseDatabase.instance.readAllStorylines();

    setState(() => isLoading = false);
  }

  void dispose() {
    super.dispose();
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
          child: isLoading
            ? const CircularProgressIndicator()
            : storylinesList.isEmpty
              ? const Text(
                'No created news'
              )
            : buildUniverseStorylines(),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.black,
          child: const Icon(Icons.add),
          onPressed: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => AddEditUniverseStorylinesPage()),
            );

            refreshStorylines();
          },
        ),
      );


  Widget buildUniverseStorylines() => ListView.builder(
            padding : EdgeInsets.all(8),
            itemCount: storylinesList.length,
            itemBuilder: (context,index){
              final storyline = storylinesList[index];
              return Card(
                color : storyline.fin != '' ? Colors.white70 : Colors.white,
                shape:RoundedRectangleBorder(
                side: new BorderSide(color: Color.fromARGB(189, 96, 125, 139)),
                borderRadius: BorderRadius.circular(4.0)),
                elevation : 2,
                child: ListTile(
                onTap: () async {
                  await Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => UniverseStorylinesDetailPage(storylineId: storyline.id!),
                )).then((value) => refreshStorylines());
                },
                title: Text(storyline.titre, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                subtitle: Row(
                  children: [
                  Text('Début : Semaine ${storyline.debut}',style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blueGrey)),
                  const Spacer(),
                  Text('Fin : Semaine ${storyline.fin}', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blueGrey)),
                ])
              ));
            });
}