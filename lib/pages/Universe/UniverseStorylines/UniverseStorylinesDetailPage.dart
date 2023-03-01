import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/Universe/UniverseStorylines.dart';
import 'package:wwe_universe/classes/Universe/UniverseNews.dart';
import 'package:wwe_universe/database.dart';
import 'package:wwe_universe/pages/Universe/UniverseNews/AddEditUniverseNewsPage.dart';
import 'package:wwe_universe/pages/Universe/UniverseStorylines/AddEditUniverseStorylinesPage.dart';
// import 'package:sqflite_database_example/page/edit_note_page.dart';

class UniverseStorylinesDetailPage extends StatefulWidget {
  final int storylineId;

  const UniverseStorylinesDetailPage({
    Key? key,
    required this.storylineId,
  }) : super(key: key);

  @override
  _UniverseStorylinesDetailPage createState() => _UniverseStorylinesDetailPage();
}

class _UniverseStorylinesDetailPage extends State<UniverseStorylinesDetailPage> {
  late UniverseStorylines storyline;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    refreshStorylines();
  }

  Future refreshStorylines() async {
    setState(() => isLoading = true);

    this.storyline = await UniverseDatabase.instance.readStoryline(widget.storylineId);

    setState(() => isLoading = false);
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
                      storyline.titre,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    SizedBox(height: 8),
                    Text(
                      storyline.texte,
                      style: TextStyle(color: Colors.black, fontSize: 18),
                    )
                  ],
                ),
              ),
      );

  Widget editButton() => IconButton(
      icon: Icon(Icons.edit_outlined),
      onPressed: () async {
        // if (isLoading) return;

        await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => AddEditUniverseStorylinesPage(storyline : storyline),
        ));

        refreshStorylines();
      });

  Widget deleteButton() => IconButton(
        icon: Icon(Icons.delete),
        onPressed: () async {
          await UniverseDatabase.instance.deleteStoryline(widget.storylineId);
          
          Navigator.of(context).pop();
        },
  );
}

