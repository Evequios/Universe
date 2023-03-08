import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/IRL/IRLMatches.dart';
import 'package:wwe_universe/classes/IRL/IRLShows.dart';
import 'package:wwe_universe/pages/IRL/IRLMatches/AddEditIRLMatchesPage.dart';
import 'package:wwe_universe/pages/IRL/IRLMatches/IRLMatchesDetailPage.dart';
import 'package:wwe_universe/pages/IRL/IRLShows/AddEditIRLShowsPage.dart';

class IRLShowsDetailPage extends StatefulWidget {
  final IRLShows irlShows;

  const IRLShowsDetailPage({
    Key? key,
    required this.irlShows,
  }) : super(key: key);

  @override
  _IRLShowsDetailPage createState() => _IRLShowsDetailPage();
}

class _IRLShowsDetailPage extends State<IRLShowsDetailPage> {
  late IRLShows? irlShows = widget.irlShows;
  late List<IRLMatches> matchesList;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Matchs',),
      actions: [editButton(), deleteButton()]
    ),
    body: Column(children: [ 
      Container(
        padding: const EdgeInsets.all(8), 
        alignment: Alignment.centerLeft,
        child:const Text('Résumé : ',textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),)
      ),
      Container(
        width: double.infinity,
        height: 150,
        padding: const EdgeInsets.all(8),
        child :Card(
          shape:RoundedRectangleBorder(
            side: const BorderSide(color: Color.fromARGB(189, 96, 125, 139)),
            borderRadius: BorderRadius.circular(4.0)
          ),
          elevation : 2,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(8),
            child : Text(irlShows!.resume),
          )
        )
      ),
      const SizedBox(height: 8,),
      Container(
        padding: const EdgeInsets.all(8), 
        alignment: Alignment.centerLeft,
        child:const Text('Matchs : ', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),)
      ),
      Flexible(
        child: StreamBuilder<List<IRLMatches>>(
          stream: readAllIRLMatches(),
          builder: (BuildContext context, snapshot) {
            if (snapshot.hasError) {
              return const Text('Something went wrong');
            }

            else if(snapshot.hasData){
              final irlMatches = snapshot.data!;
              return ListView(
                padding: const EdgeInsets.all(8),
                children: irlMatches.map(buildIRLMatches).toList()
              );
            }
            
            else{
              return const CircularProgressIndicator();
            }
          }
        ),
      ),
    ]),
    floatingActionButton: FloatingActionButton(
      backgroundColor: Colors.black,
      child : const Icon(Icons.add),
      onPressed: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => AddEditIRLMatchesPage(irlShows :widget.irlShows)),
        );
      } ),
  );
  
  Widget buildIRLMatches(IRLMatches irlMatches) {
    return SizedBox(
    height: 80,
    child :Card(
      shape:RoundedRectangleBorder(
        side: const BorderSide(color: Color.fromARGB(189, 96, 125, 139)),
        borderRadius: BorderRadius.circular(4.0)
      ),
      elevation : 2,
      child: ListTile(
        onTap: () async {
          await Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => IRLMatchesDetailPage(irlMatches: irlMatches, irlShows: irlShows!,),
          ));
        },
        title: (() {
          if(irlMatches.stipulation.contains("1v1")){
            return Text('${irlMatches.s1} vs ${irlMatches.s2}', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold));
          }
          if(irlMatches.stipulation.contains("2v2")){
            return Text('${irlMatches.s1} & ${irlMatches.s2} vs ${irlMatches.s3} & ${irlMatches.s4}', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold));
          }
          if(irlMatches.stipulation.contains("3v3")){
            return Text('${irlMatches.s1}, ${irlMatches.s2}, ${irlMatches.s3} vs ${irlMatches.s4}, ${irlMatches.s5}, ${irlMatches.s6}', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold));
          }
          if(irlMatches.stipulation.contains("4v4")){
            return Text('Team ${irlMatches.s1} vs Team ${irlMatches.s6}', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold));
          }
          if(irlMatches.stipulation.contains("5v5")){
            return Text('Team ${irlMatches.s1} vs Team ${irlMatches.s6}', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold));
          }
          if(irlMatches.stipulation.contains("Triple Threat")){
            return Text('${irlMatches.s1} vs ${irlMatches.s2} vs ${irlMatches.s3}', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold));
          }
        }()),
        subtitle: Text(irlMatches.stipulation, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
      )
    )
    );
  }

  Widget editButton() => IconButton(
      icon: const Icon(Icons.edit_outlined),
      onPressed: () async {
        if (isLoading) return;

        await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => AddEditIRLShowsPage(irlShows : irlShows),
        ));
      });

  Widget deleteButton() => IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () {
          final docIRLShows= FirebaseFirestore.instance.collection('IRLShows').doc(irlShows!.id);
          docIRLShows.delete();
          Navigator.of(context).pop();
        },
  );

  Stream<List<IRLMatches>> readAllIRLMatches() {
    return FirebaseFirestore.instance.collection('IRLMatches').where('showId', isEqualTo: irlShows!.id).orderBy('ordre').snapshots().map((snapshot) => 
      snapshot.docs.map((doc) => IRLMatches.fromJson(doc.data())).toList());
  }
}



