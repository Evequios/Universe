import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/IRL/IRLMatches.dart';
import 'package:wwe_universe/classes/IRL/IRLShows.dart';
import 'package:wwe_universe/classes/IRL/IRLNews.dart';
import 'package:wwe_universe/pages/IRL/IRLMatches/AddEditIRLMatchesPage.dart';
import 'package:wwe_universe/pages/IRL/IRLNews/AddEditIRLNewsPage.dart';
// import 'package:sqflite_database_example/page/edit_note_page.dart';

class IRLMatchesDetailPage extends StatefulWidget {
  final IRLMatches irlMatches;
  final IRLShows irlShows;

  const IRLMatchesDetailPage({
    Key? key,
    required this.irlMatches, 
    required this.irlShows,
  }) : super(key: key);

  @override
  _IRLMatchesDetailPage createState() => _IRLMatchesDetailPage();
}

class _IRLMatchesDetailPage extends State<IRLMatchesDetailPage> {
  late IRLMatches? irlMatches = widget.irlMatches;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          actions: [editButton(), deleteButton()],
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : Padding(
                padding: EdgeInsets.all(12),
                child: ListView(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  children: [
                    Text(
                      irlMatches!.stipulation,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(child:(() {
                    if(irlMatches!.stipulation.contains("1v1")){
                      return Text('${irlMatches!.s1} vs ${irlMatches!.s2}', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold));
                    }
                    if(irlMatches!.stipulation.contains("2v2")){
                      return Text('${irlMatches!.s1} & ${irlMatches!.s2} vs ${irlMatches!.s3} & ${irlMatches!.s4}', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold));
                    }
                    if(irlMatches!.stipulation.contains("3v3")){
                      return Text('${irlMatches!.s1}, ${irlMatches!.s2}, ${irlMatches!.s3} vs ${irlMatches!.s4}, ${irlMatches!.s5}, ${irlMatches!.s6}', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold));
                    }
                    if(irlMatches!.stipulation.contains("4v4")){
                      return Text('Team ${irlMatches!.s1} vs Team ${irlMatches!.s6}', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold));
                    }
                    if(irlMatches!.stipulation.contains("5v5")){
                      return Text('Team ${irlMatches!.s1} vs Team ${irlMatches!.s6}', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold));
                    }
                    if(irlMatches!.stipulation.contains("Triple Threat")){
                      return Text('${irlMatches!.s1} vs ${irlMatches!.s2} vs ${irlMatches!.s3}', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold));
                    }
                  }())
                ),
                SizedBox(height: 30,),
                    Text('Gagnant : ${irlMatches!.gagnant}',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center
                    )
                    
                  ],
                ),
              ),
      );

  Widget editButton() => IconButton(
      icon: Icon(Icons.edit_outlined),
      onPressed: () async {
        if (isLoading) return;

        await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => AddEditIRLMatchesPage(irlMatches: irlMatches, irlShows: widget.irlShows,),
        ));
      });

  Widget deleteButton() => IconButton(
        icon: Icon(Icons.delete),
        onPressed: () {
          final docIRLMatches= FirebaseFirestore.instance.collection('IRLMatches').doc(irlMatches!.id);
          docIRLMatches.delete();
          Navigator.of(context).pop();
        },
  );
}