import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/Universe/UniverseMatches.dart';
import 'package:wwe_universe/classes/Universe/UniverseShows.dart';
import 'package:wwe_universe/classes/Universe/UniverseNews.dart';
import 'package:wwe_universe/widget/Universe/UniverseMatchesFormWidget.dart';
import 'package:wwe_universe/widget/Universe/UniverseNewsFormWidget.dart';

class AddEditUniverseMatchesPage extends StatefulWidget {
  final UniverseMatches? universeMatches;
  final UniverseShows? universeShows;
  const AddEditUniverseMatchesPage({
    Key? key,
    this.universeMatches,
    this.universeShows,
  }) : super(key: key);
  @override
  _AddEditUniverseMatchesPage createState() => _AddEditUniverseMatchesPage();
}

class _AddEditUniverseMatchesPage extends State<AddEditUniverseMatchesPage> {
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

    stipulation = widget.universeMatches?.stipulation ?? '';
    s1 = widget.universeMatches?.s1 ?? '';
    s2 = widget.universeMatches?.s2 ?? '';
    s3 = widget.universeMatches?.s3 ?? '';
    s4 = widget.universeMatches?.s4 ?? '';
    s5 = widget.universeMatches?.s5 ?? '';
    s6 = widget.universeMatches?.s6 ?? '';
    s7 = widget.universeMatches?.s7 ?? '';
    s8 = widget.universeMatches?.s8 ?? '';
    s9 = widget.universeMatches?.s9 ?? '';
    s10 = widget.universeMatches?.s10 ?? '';
    gagnant = widget.universeMatches?.gagnant ?? '';
    ordre = widget.universeMatches?.ordre ?? '';
    showId = widget.universeMatches?.showId ?? widget.universeShows!.id;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          actions: [buildButton()],
        ),
        body: Form(
          key: _formKey,
          child: UniverseMatchesFormWidget(
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
            showId : widget.universeShows!.id,
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
    final isFormValid = stipulation.isNotEmpty;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          onPrimary: Colors.white,
          primary: isFormValid ? null : Colors.grey.shade700,
        ),
        onPressed: addOrUpdateUniverseMatches,
        child: Text('Save'),
      ),
    );
  }

  void addOrUpdateUniverseMatches() async {
    final isValid = _formKey.currentState!.validate();

    if (isValid) {
      final isUpdating = widget.universeMatches != null;

      if (isUpdating) {
        await updateUniverseMatches();
      } else {
        await addUniverseMatches();
      }

      Navigator.of(context).pop();
    }
  }

  Future updateUniverseMatches() async {
    final docUniverseMatches = FirebaseFirestore.instance.collection('UniverseMatches').doc(widget.universeMatches!.id);
    docUniverseMatches.update({
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
      'showId' : widget.universeShows!.id,
    });
  }

  Future addUniverseMatches() async {
    final docUniverseMatches = FirebaseFirestore.instance.collection('UniverseMatches').doc();
    final universeMatches = UniverseMatches(
      id: docUniverseMatches.id,
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
      showId : widget.universeShows!.id,
    );

    final json = universeMatches.toJson();
    await docUniverseMatches.set(json);
  }
}