import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/IRL/IRLShows.dart';
import 'package:wwe_universe/classes/IRL/IRLNews.dart';
import 'package:wwe_universe/widget/IRL/IRLNewsFormWidget.dart';
import 'package:wwe_universe/widget/IRL/IRLShowsFormWidget.dart';
import 'package:intl/intl.dart';

class AddEditIRLShowsPage extends StatefulWidget {
  final IRLShows? irlShows;

  const AddEditIRLShowsPage({
    Key? key,
    this.irlShows
  }) : super(key: key);
  @override
  _AddEditIRLShowsPage createState() => _AddEditIRLShowsPage();
}

class _AddEditIRLShowsPage extends State<AddEditIRLShowsPage> {
  final _formKey = GlobalKey<FormState>();
  late String nom;
  late String date;
  late String resume;

  @override
  void initState() {
    super.initState();

    nom = widget.irlShows?.nom ?? '';
    date = widget.irlShows?.date ?? '';
    resume = widget.irlShows?.resume ?? '';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      actions: [buildButton()],
    ),
    body: Form(
      key: _formKey,
      child: IRLShowsFormWidget(
        nom: nom,
        date: date,
        resume: resume,
        onChangedNom: (nom) => setState(() => this.nom = nom),
        onChangedDate: (date) => setState(() => this.date = date),
        onChangedResume: (resume) => setState(() => this.resume = resume),
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
        onPressed: addOrUpdateIRLShows,
        child: Text('Save'),
      ),
    );
  }

  void addOrUpdateIRLShows() async {
    final isValid = _formKey.currentState!.validate();

    if (isValid) {
      final isUpdating = widget.irlShows != null;

      if (isUpdating) {
        await updateIRLShows();
      } else {
        await addIRLShows();
      }

      Navigator.of(context).pop();
    }
  }

  Future updateIRLShows() async {
    final docIRLShows = FirebaseFirestore.instance.collection('IRLShows').doc(widget.irlShows!.id);
    docIRLShows.update({
      'nom': nom,
      'date': date,
      'resume': resume,
    });
  }

  Future addIRLShows() async {
    final docIRLShows = FirebaseFirestore.instance.collection('IRLShows').doc();
    final irlShows = IRLShows(
      id: docIRLShows.id,
      nom: nom,
      date: date,
      resume: resume
    );
    final json = irlShows.toJson();
    await docIRLShows.set(json);

  }
}