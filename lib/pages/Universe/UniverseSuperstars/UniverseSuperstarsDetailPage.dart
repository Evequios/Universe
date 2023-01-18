import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/Universe/UniverseSuperstars.dart';
import 'package:wwe_universe/classes/Universe/UniverseNews.dart';
import 'package:wwe_universe/pages/Universe/UniverseNews/AddEditUniverseNewsPage.dart';
import 'package:wwe_universe/pages/Universe/UniverseSuperstars/AddEditUniverseSuperstarsPage.dart';
// import 'package:sqflite_database_example/page/edit_note_page.dart';

class UniverseSuperstarsDetailPage extends StatefulWidget {
  final UniverseSuperstars? universeSuperstars;

  const UniverseSuperstarsDetailPage({
    Key? key,
    required this.universeSuperstars,
  }) : super(key: key);

  @override
  _UniverseSuperstarsDetailPage createState() => _UniverseSuperstarsDetailPage();
}

class _UniverseSuperstarsDetailPage extends State<UniverseSuperstarsDetailPage> {
  late UniverseSuperstars? universeSuperstars = widget.universeSuperstars;
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
                      'Prénom : ${universeSuperstars!.prenom}',
                      style: TextStyle(color: Colors.black, fontSize: 18,),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Nom : ${universeSuperstars!.nom}',
                      style: TextStyle(color: Colors.black, fontSize: 18),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Show : ${universeSuperstars!.show}',
                      style: TextStyle(color: Colors.black, fontSize: 18),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Orientation : ${universeSuperstars!.orientation}',
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
          builder: (context) => AddEditUniverseSuperstarsPage(universeSuperstars: universeSuperstars),
        ));
      });

  Widget deleteButton() => IconButton(
        icon: Icon(Icons.delete),
        onPressed: () {
          final docUniverseSuperstars= FirebaseFirestore.instance.collection('UniverseSuperstars').doc(universeSuperstars!.id);
          docUniverseSuperstars.delete();
          Navigator.of(context).pop();
        },
  );
}