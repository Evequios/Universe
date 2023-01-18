import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/Universe/UniverseTitles.dart';
import 'package:wwe_universe/pages/Settings/Titles/Universe/AddEditUniverseTitlesPage.dart';
// import 'package:sqflite_database_example/page/edit_note_page.dart';

class UniverseTitlesDetailPage extends StatefulWidget {
  final UniverseTitles universeTitles;

  const UniverseTitlesDetailPage({
    Key? key,
    required this.universeTitles,
  }) : super(key: key);

  @override
  _UniverseTitlesDetailPage createState() => _UniverseTitlesDetailPage();
}

class _UniverseTitlesDetailPage extends State<UniverseTitlesDetailPage> {
  late UniverseTitles? universeTitles = widget.universeTitles;
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
                      universeTitles!.nom,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    SizedBox(height: 8),
                    Text("Show : ${universeTitles!.show}",
                      style: TextStyle(color: Colors.black, fontSize: 18)
                    ),
                    SizedBox(height: 8),
                    universeTitles!.tag == 'false' ?
                    Text("Champion : ${universeTitles!.holder1}",
                      style: TextStyle(color: Colors.black, fontSize: 18),
                    )
                    :Text("Champions : ${universeTitles!.holder1} & ${universeTitles!.holder2}",
                      style: TextStyle(color: Colors.black, fontSize: 18),
                    )
                    ,
                  ],
                ),
              ),
      );

  Widget editButton() => IconButton(
      icon: Icon(Icons.edit_outlined),
      onPressed: () async {
        if (isLoading) return;

        await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => AddEditUniverseTitlesPage(universeTitles: universeTitles),
        ));
      });

  Widget deleteButton() => IconButton(
        icon: Icon(Icons.delete),
        onPressed: () {
          final docUniverseTitles = FirebaseFirestore.instance.collection('UniverseTitles').doc(universeTitles!.id);
          docUniverseTitles.delete();
          Navigator.of(context).pop();
        },
      );
}