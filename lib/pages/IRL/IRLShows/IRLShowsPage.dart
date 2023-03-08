import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wwe_universe/classes/IRL/IRLShows.dart';
import 'package:wwe_universe/NavBar.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/pages/IRL/IRLShows/AddEditIRLShowsPage.dart';
import 'package:wwe_universe/pages/IRL/IRLShows/IRLShowsDetailPage.dart';

class IRLShowsPage extends StatefulWidget{
  const IRLShowsPage({super.key});

  @override
  _IRLShowsPage createState() => _IRLShowsPage();
}

class _IRLShowsPage extends State<IRLShowsPage> {
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    drawer: const Navbar(),
    appBar: AppBar(
      title: const Text('Shows',),
    ),
    body: Center(
      child: StreamBuilder<List<IRLShows>>(
        stream: readAllIRLShows(),
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          else if(snapshot.hasData){
            final irlShows = snapshot.data!;
            return ListView(
              padding: const EdgeInsets.all(8),
              children: irlShows.map(buildIRLShows).toList()
            );
          }
          else{
            return const CircularProgressIndicator();
          }
        }
      ),
    ),
    floatingActionButton: FloatingActionButton(
      backgroundColor: Colors.black,
      child: const Icon(Icons.add),
      onPressed: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const AddEditIRLShowsPage()),
        );
      },
    ),
  );


  Widget buildIRLShows(IRLShows irlShows) {
    String image = 'assets/${irlShows.nom.toLowerCase()}.png';
    return GestureDetector(
      onTap: () async {
        await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => IRLShowsDetailPage(irlShows: irlShows),
        ));
      },
      child:  SizedBox( 
      height: 80,
      child:Card(
        shape:RoundedRectangleBorder(
          side: const BorderSide(color: Color.fromARGB(189, 96, 125, 139)),
          borderRadius: BorderRadius.circular(4.0)),
          elevation: 2,
          child: Padding(
            padding:  const EdgeInsets.symmetric(vertical:8.0, horizontal: 16),
            child: Row(
              children: [
                Expanded(child: 
                  FittedBox(fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft, 
                    child: irlShows.nom.toLowerCase() == 'raw' || 
                    irlShows.nom.toLowerCase() == 'smackdown' ||
                    irlShows.nom.toLowerCase() == 'nxt' ?
                    Image(image: AssetImage(image))
                    : Text(irlShows.nom, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),)),
                const Spacer(),
                  Text(irlShows.date, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18), ),
              ],)
          )
      )
      )
    );
  }

  Stream<List<IRLShows>> readAllIRLShows() => 
    FirebaseFirestore.instance.collection('IRLShows').orderBy('date', descending: true).snapshots().map((snapshot) => 
      snapshot.docs.map((doc) => IRLShows.fromJson(doc.data())).toList());
}
