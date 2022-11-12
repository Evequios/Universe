import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/IRLMatches.dart';
import 'package:wwe_universe/classes/IRLShows.dart';
import 'package:wwe_universe/classes/IRLNews.dart';
import 'package:wwe_universe/pages/IRLMatches/AddEditIRLMatchesPage.dart';
import 'package:wwe_universe/pages/IRLNews/AddEditIRLNewsPage.dart';
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
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    SizedBox(height: 8),
                    Text(
                      irlMatches!.gagnant,
                      style: TextStyle(color: Colors.black, fontSize: 18),
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