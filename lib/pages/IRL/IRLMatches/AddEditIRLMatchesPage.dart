import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/IRL/IRLMatches.dart';
import 'package:wwe_universe/classes/IRL/IRLShows.dart';
import 'package:wwe_universe/classes/IRL/IRLNews.dart';
import 'package:wwe_universe/classes/IRL/IRLStipulations.dart';
import 'package:wwe_universe/widget/IRL/IRLMatchesFormWidget.dart';
import 'package:wwe_universe/widget/IRL/IRLNewsFormWidget.dart';

class AddEditIRLMatchesPage extends StatefulWidget {
  final IRLMatches? irlMatches;
  final IRLShows? irlShows;
  const AddEditIRLMatchesPage({
    Key? key,
    this.irlMatches,
    this.irlShows,
  }) : super(key: key);
  @override
  _AddEditIRLMatchesPage createState() => _AddEditIRLMatchesPage();
}

class _AddEditIRLMatchesPage extends State<AddEditIRLMatchesPage> {
  final _formKey = GlobalKey<FormState>();
  late String stipulation;
  late String s1;
  late String s2;
  late String s3;
  late String s4;
  late String s5;
  late String s6;
  late String s7;
  late String s8;
  late String s9;
  late String s10;
  late String gagnant;
  late String ordre;
  late String showId;

  @override
  void initState() {
    super.initState();

    stipulation = widget.irlMatches?.stipulation ?? '';
    s1 = widget.irlMatches?.s1 ?? '';
    s2 = widget.irlMatches?.s2 ?? '';
    s3 = widget.irlMatches?.s3 ?? '';
    s4 = widget.irlMatches?.s4 ?? '';
    s5 = widget.irlMatches?.s5 ?? '';
    s6 = widget.irlMatches?.s6 ?? '';
    s7 = widget.irlMatches?.s7 ?? '';
    s8 = widget.irlMatches?.s8 ?? '';
    s9 = widget.irlMatches?.s9 ?? '';
    s10 = widget.irlMatches?.s10 ?? '';
    gagnant = widget.irlMatches?.gagnant ?? '';
    ordre = widget.irlMatches?.ordre ?? '';
    showId = widget.irlMatches?.showId ?? widget.irlShows!.id;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          actions: [buildButton()],
        ),
        body: Form(
          key: _formKey,
          child: IRLMatchesFormWidget(
            stipulation: stipulation,
            s1 : s1,
            s2 : s2,
            s3 : s3,
            s4 : s4,
            s5 : s5,
            s6 : s6,
            s7 : s7,
            s8 : s8,
            s9 : s9,
            s10 : s10,
            gagnant : gagnant,
            ordre : ordre,
            showId : widget.irlShows!.id,
            onChangedStipulation: (stipulation) => setState(() => this.stipulation = stipulation!),
            onChangedS1: (s1) => setState(() => this.s1 = s1!),
            onChangedS2: (s2) => setState(() => this.s2 = s2!),
            onChangedS3: (s3) => setState(() => this.s3 = s3!),
            onChangedS4: (s4) => setState(() => this.s4 = s4!),
            onChangedS5: (s5) => setState(() => this.s5 = s5!),
            onChangedS6: (s6) => setState(() => this.s6 = s6!),
            onChangedS7: (s7) => setState(() => this.s7 = s7!),
            onChangedS8: (s8) => setState(() => this.s8 = s8!),
            onChangedS9: (s9) => setState(() => this.s9 = s9!),
            onChangedS10: (s10) => setState(() => this.s10 = s10!),
            onChangedGagnant: (gagnant) => setState(() => this.gagnant = gagnant!),
            onChangedOrdre: (ordre) => setState(() => this.ordre = ordre!),

          ),
        ),
      );

  Widget buildButton() {
    // final isFormValid = stipulation.isNotEmpty;
    final isFormValid = (stipulation == null);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          onPrimary: Colors.white,
          primary: isFormValid ? null : Colors.grey.shade700,
        ),
        onPressed: addOrUpdateIRLMatches,
        child: Text('Save'),
      ),
    );
  }

  void addOrUpdateIRLMatches() async {
    final isValid = _formKey.currentState!.validate();

    if (isValid) {
      final isUpdating = widget.irlMatches != null;

      if (isUpdating) {
        await updateIRLMatches();
      } else {
        await addIRLMatches();
      }

      Navigator.of(context).pop();
    }
  }

  Future updateIRLMatches() async {
    final docIRLMatches = FirebaseFirestore.instance.collection('IRLMatches').doc(widget.irlMatches!.id);
    docIRLMatches.update({
      'stipulation': stipulation,
      's1' : s1,
      's2' : s2,
      's3' : s3,
      's4' : s4,
      's5' : s5,
      's6' : s6,
      's7' : s7,
      's8' : s8,
      's9' : s9,
      's10' : s10,
      'gagnant' : gagnant,
      'ordre' : ordre,
      'showId' : widget.irlShows!.id,
    });
  }

  Future addIRLMatches() async {
    final docIRLMatches = FirebaseFirestore.instance.collection('IRLMatches').doc();
    final irlMatches = IRLMatches(
      id: docIRLMatches.id,
      stipulation: stipulation,
      s1 : s1,
      s2 : s2,
      s3 : s3,
      s4 : s4,
      s5 : s5,
      s6 : s6,
      s7 : s7,
      s8 : s8,
      s9 : s9,
      s10 : s10,
      gagnant : gagnant,
      ordre : ordre,
      showId : widget.irlShows!.id,
    );

    final json = irlMatches.toJson();
    await docIRLMatches.set(json);
  }
}