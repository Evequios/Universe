import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/Universe/UniverseMatches.dart';
import 'package:wwe_universe/classes/Universe/UniverseShows.dart';
import 'package:wwe_universe/classes/Universe/UniverseNews.dart';
import 'package:wwe_universe/pages/Universe/UniverseMatches/AddEditUniverseMatchesPage.dart';
import 'package:wwe_universe/pages/Universe/UniverseNews/AddEditUniverseNewsPage.dart';
// import 'package:sqflite_database_example/page/edit_note_page.dart';

class UniverseMatchesDetailPage extends StatefulWidget {
  final UniverseMatches universeMatches;
  final UniverseShows universeShows;

  const UniverseMatchesDetailPage({
    Key? key,
    required this.universeMatches, 
    required this.universeShows,
  }) : super(key: key);

  @override
  _UniverseMatchesDetailPage createState() => _UniverseMatchesDetailPage();
}

class _UniverseMatchesDetailPage extends State<UniverseMatchesDetailPage> {
  late UniverseMatches? universeMatches = widget.universeMatches;
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
                      universeMatches!.stipulation,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    SizedBox(height: 8),
                    Text(
                      universeMatches!.gagnant,
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
          builder: (context) => AddEditUniverseMatchesPage(universeMatches: universeMatches, universeShows: widget.universeShows,),
        ));
      });

  Widget deleteButton() => IconButton(
        icon: Icon(Icons.delete),
        onPressed: () {
          final docUniverseMatches= FirebaseFirestore.instance.collection('UniverseMatches').doc(universeMatches!.id);
          docUniverseMatches.delete();
          Navigator.of(context).pop();
        },
  );
}