import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/IRL/IRLStipulations.dart';
import 'package:wwe_universe/pages/Settings/Stipulations/IRL/AddEditIRLStipulationsPage.dart';
// import 'package:sqflite_database_example/page/edit_note_page.dart';

class IRLStipulationsDetailPage extends StatefulWidget {
  final IRLStipulations irlStipulations;

  const IRLStipulationsDetailPage({
    Key? key,
    required this.irlStipulations,
  }) : super(key: key);

  @override
  _IRLStipulationsDetailPage createState() => _IRLStipulationsDetailPage();
}

class _IRLStipulationsDetailPage extends State<IRLStipulationsDetailPage> {
  late IRLStipulations? irlStipulations = widget.irlStipulations;
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
                      irlStipulations!.type,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    SizedBox(height: 8),
                    Text(
                      irlStipulations!.stipulation,
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
          builder: (context) => AddEditIRLStipulationsPage(irlStipulations: irlStipulations),
        ));
      });

  Widget deleteButton() => IconButton(
        icon: Icon(Icons.delete),
        onPressed: () {
          final docIRLStipulations = FirebaseFirestore.instance.collection('IRLStipulations').doc(irlStipulations!.id);
          docIRLStipulations.delete();
          Navigator.of(context).pop();
        },
      );
}