import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/Universe/UniverseStipulations.dart';
import 'package:wwe_universe/pages/Settings/Stipulations/Universe/AddEditUniverseStipulationsPage.dart';
// import 'package:sqflite_database_example/page/edit_note_page.dart';

class UniverseStipulationsDetailPage extends StatefulWidget {
  final UniverseStipulations universeStipulations;

  const UniverseStipulationsDetailPage({
    Key? key,
    required this.universeStipulations,
  }) : super(key: key);

  @override
  _UniverseStipulationsDetailPage createState() => _UniverseStipulationsDetailPage();
}

class _UniverseStipulationsDetailPage extends State<UniverseStipulationsDetailPage> {
  late UniverseStipulations? universeStipulations = widget.universeStipulations;
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
                      universeStipulations!.type,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    SizedBox(height: 8),
                    Text(
                      universeStipulations!.stipulation,
                      style: TextStyle(color: Colors.black, fontSize: 18),
                    ),
                  ],
                ),
              ),
      );

  Widget editButton() => IconButton(
      icon: Icon(Icons.edit_outlined),
      onPressed: () async {
        if (isLoading) return;

        await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => AddEditUniverseStipulationsPage(universeStipulations: universeStipulations),
        ));
      });

  Widget deleteButton() => IconButton(
        icon: Icon(Icons.delete),
        onPressed: () {
          final docUniverseStipulations = FirebaseFirestore.instance.collection('UniverseStipulations').doc(universeStipulations!.id);
          docUniverseStipulations.delete();
          Navigator.of(context).pop();
        },
      );
}