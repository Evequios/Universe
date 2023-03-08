import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wwe_universe/classes/IRL/IRLTitles.dart';
import 'package:wwe_universe/NavBar.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/pages/Settings/Titles/IRL/AddEditIRLTitlesPage.dart';
import 'package:wwe_universe/pages/Settings/Titles/IRL/IRLTitlesDetailPage.dart';



class IRLTitlesPage extends StatefulWidget{
  const IRLTitlesPage({super.key});

  @override
  _IRLTitlesPageState createState() => _IRLTitlesPageState();
}

class _IRLTitlesPageState extends State<IRLTitlesPage> {

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
            'Titles',
            // style : TextStyle(fontWeight: FontWeight.bold,fontSize: 22)
          ),
          actions: const [Icon(Icons.search), SizedBox(width: 12)],
          
        ),
        body: Center(
          child: StreamBuilder<List<IRLTitles>>(
            stream: readAllIRLTitles(),
            builder: (BuildContext context, snapshot) {
            if (snapshot.hasError) {
              return const Text('Something went wrong');
            }

            else if(snapshot.hasData){
              final irlTitles = snapshot.data!;

              return ListView(
                padding: const EdgeInsets.all(12),
                children: irlTitles.map(buildIRLTitles).toList()
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
              MaterialPageRoute(builder: (context) => const AddEditIRLTitlesPage()),
            );
          },
        ),
      );

  Widget buildIRLTitles(IRLTitles irlTitles) {
  return Card(
            shape:RoundedRectangleBorder(
              side: const BorderSide(color: Color.fromARGB(189, 96, 125, 139)),
              borderRadius: BorderRadius.circular(4.0)),
              elevation : 2,
              child: ListTile(
              onTap: () async {
                await Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => IRLTitlesDetailPage(irlTitles: irlTitles),
              ));
              },
              title: Text('${irlTitles.nom} Championship', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              subtitle: irlTitles.tag == 'false' ? 
                Text(irlTitles.holder1)
                : Text('${irlTitles.holder1} & ${irlTitles.holder2}'),
              // subtitle: Text('${irlTitles.createdTime.toDate().day}/${irlTitles.createdTime.toDate().month}/${irlTitles.createdTime.toDate().year}  ${irlTitles.createdTime.toDate().hour}h${irlTitles.createdTime.toDate().minute.toString().padLeft(2, '0')}                                      ${irlTitles.categorie}'),
              ));
  }

  Stream<List<IRLTitles>> readAllIRLTitles() => 
  FirebaseFirestore.instance.collection('IRLTitles').orderBy('nom').snapshots().map((snapshot) => 
    snapshot.docs.map((doc) => IRLTitles.fromJson(doc.data())).toList());
}