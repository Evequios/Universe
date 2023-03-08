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
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(12),
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    Text(
                      irlStipulations!.type,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const SizedBox(height: 8),
                    Text(
                      irlStipulations!.stipulation,
                      style: const TextStyle(color: Colors.black, fontSize: 18),
                    ),
                  ],
                ),
              ),
      );

  Widget editButton() => IconButton(
      icon: const Icon(Icons.edit_outlined),
      onPressed: () async {
        if (isLoading) return;

        await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => AddEditIRLStipulationsPage(irlStipulations: irlStipulations),
        ));
      });

  Widget deleteButton() => IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () {
          final docIRLStipulations = FirebaseFirestore.instance.collection('IRLStipulations').doc(irlStipulations!.id);
          docIRLStipulations.delete();
          Navigator.of(context).pop();
        },
      );
}