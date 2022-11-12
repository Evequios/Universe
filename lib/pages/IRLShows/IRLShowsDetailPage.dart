import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/IRLMatches.dart';
import 'package:wwe_universe/classes/IRLShows.dart';
import 'package:wwe_universe/pages/IRLMatches/AddEditIRLMatchesPage.dart';
import 'package:wwe_universe/pages/IRLMatches/IRLMatchesDetailPage.dart';
import 'package:wwe_universe/pages/IRLShows/AddEditIRLShowsPage.dart';

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
      title: const Text(
        'Matchs',
      ),
      actions: [editButton(), deleteButton()]
    ),
    body: Center(
          child: StreamBuilder<List<IRLMatches>>(
            stream: readAllIRLMatches(),
            builder: (BuildContext context, snapshot) {
            if (snapshot.hasError) {
              return Text('Something went wrong');
            }

            else if(snapshot.hasData){
              final irlMatches = snapshot.data!;

              return ListView(
                padding: EdgeInsets.all(8),
                children: irlMatches.map(buildIRLMatches).toList()
              ,);
            }
            else{
              return CircularProgressIndicator();
            }
          }),
        ),
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
            return Card(
              elevation : 4,
              child: ListTile(
              onTap: () async {
                await Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => IRLMatchesDetailPage(irlMatches: irlMatches, irlShows: irlShows!,),
              ));
              },
              title: Text(irlMatches.stipulation, style: TextStyle(fontWeight: FontWeight.bold)),
            ));
  }

  Widget editButton() => IconButton(
      icon: Icon(Icons.edit_outlined),
      onPressed: () async {
        if (isLoading) return;

        await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => AddEditIRLShowsPage(irlShows : irlShows),
        ));
      });

  Widget deleteButton() => IconButton(
        icon: Icon(Icons.delete),
        onPressed: () {
          final docIRLShows= FirebaseFirestore.instance.collection('IRLShows').doc(irlShows!.id);
          docIRLShows.delete();
          Navigator.of(context).pop();
        },
  );

  Stream<List<IRLMatches>> readAllIRLMatches() => 
    FirebaseFirestore.instance.collection('IRLMatches').where('showId', isEqualTo: irlShows!.id).snapshots().map((snapshot) => 
      snapshot.docs.map((doc) => IRLMatches.fromJson(doc.data())).toList());
}



