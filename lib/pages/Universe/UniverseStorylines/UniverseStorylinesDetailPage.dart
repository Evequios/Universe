import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/Universe/UniverseStorylines.dart';
import 'package:wwe_universe/classes/Universe/UniverseNews.dart';
import 'package:wwe_universe/pages/Universe/UniverseNews/AddEditUniverseNewsPage.dart';
import 'package:wwe_universe/pages/Universe/UniverseStorylines/AddEditUniverseStorylinesPage.dart';
// import 'package:sqflite_database_example/page/edit_note_page.dart';

class UniverseStorylinesDetailPage extends StatefulWidget {
  final UniverseStorylines universeStorylines;

  const UniverseStorylinesDetailPage({
    Key? key,
    required this.universeStorylines,
  }) : super(key: key);

  @override
  _UniverseStorylinesDetailPage createState() => _UniverseStorylinesDetailPage();
}

class _UniverseStorylinesDetailPage extends State<UniverseStorylinesDetailPage> {
  late UniverseStorylines? universeStorylines = widget.universeStorylines;
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
                      universeStorylines!.titre,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    SizedBox(height: 8),
                    Text(
                      universeStorylines!.texte,
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
          builder: (context) => AddEditUniverseStorylinesPage(universeStorylines: universeStorylines),
        ));
      });

  Widget deleteButton() => IconButton(
        icon: Icon(Icons.delete),
        onPressed: () {
          final docUniverseStorylines= FirebaseFirestore.instance.collection('UniverseStorylines').doc(universeStorylines!.id);
          docUniverseStorylines.delete();
          Navigator.of(context).pop();
        },
  );
}

