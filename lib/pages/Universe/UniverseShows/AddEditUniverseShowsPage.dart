import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/Universe/UniverseShows.dart';
import 'package:wwe_universe/classes/Universe/UniverseNews.dart';
import 'package:wwe_universe/widget/Universe/UniverseNewsFormWidget.dart';
import 'package:wwe_universe/widget/Universe/UniverseShowsFormWidget.dart';
import 'package:intl/intl.dart';

class AddEditUniverseShowsPage extends StatefulWidget {
  final UniverseShows? universeShows;

  const AddEditUniverseShowsPage({
    Key? key,
    this.universeShows
  }) : super(key: key);
  @override
  _AddEditUniverseShowsPage createState() => _AddEditUniverseShowsPage();
}

class _AddEditUniverseShowsPage extends State<AddEditUniverseShowsPage> {
  final _formKey = GlobalKey<FormState>();
  late String nom;
  late String date;

  @override
  void initState() {
    super.initState();

    nom = widget.universeShows?.nom ?? '';
    date = widget.universeShows?.date ?? '';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          actions: [buildButton()],
        ),
        body: Form(
          key: _formKey,
          child: UniverseShowsFormWidget(
            nom: nom,
            date: date,
            onChangedNom: (nom) => setState(() => this.nom = nom),
            onChangedDate: (date) => setState(() => this.date = date) ,
          ),
        ),
      );

  Widget buildButton() {
    final isFormValid = nom.isNotEmpty && nom.isNotEmpty;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          onPrimary: Colors.white,
          primary: isFormValid ? null : Colors.grey.shade700,
        ),
        onPressed: addOrUpdateUniverseShows,
        child: Text('Save'),
      ),
    );
  }

  void addOrUpdateUniverseShows() async {
    final isValid = _formKey.currentState!.validate();

    if (isValid) {
      final isUpdating = widget.universeShows != null;

      if (isUpdating) {
        await updateUniverseShows();
      } else {
        await addUniverseShows();
      }

      Navigator.of(context).pop();
    }
  }

  Future updateUniverseShows() async {
    final docUniverseShows = FirebaseFirestore.instance.collection('UniverseShows').doc(widget.universeShows!.id);
    docUniverseShows.update({
      'nom': nom,
      'date': date,
    });
  }

  Future addUniverseShows() async {
    final docUniverseShows = FirebaseFirestore.instance.collection('UniverseShows').doc();
    final universeShows = UniverseShows(
      id: docUniverseShows.id,
      nom: nom,
      date: date
    );
    final json = universeShows.toJson();
    await docUniverseShows.set(json);

  }
}