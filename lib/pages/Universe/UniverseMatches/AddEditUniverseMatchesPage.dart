import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/Universe/UniverseMatches.dart';
import 'package:wwe_universe/classes/Universe/UniverseShows.dart';
import 'package:wwe_universe/classes/Universe/UniverseNews.dart';
import 'package:wwe_universe/classes/Universe/UniverseStipulations.dart';
import 'package:wwe_universe/classes/Universe/UniverseSuperstars.dart';
import 'package:wwe_universe/database.dart';
import 'package:wwe_universe/widget/Universe/UniverseMatchesFormWidget.dart';
import 'package:wwe_universe/widget/Universe/UniverseNewsFormWidget.dart';

class AddEditUniverseMatchesPage extends StatefulWidget {
  final UniverseMatches? match;
  final UniverseShows? show;
  final List<UniverseStipulations>? listStipulations;
  final List<UniverseSuperstars>? listSuperstars;
  const AddEditUniverseMatchesPage({
    Key? key,
    this.match,
    this.show,
    this.listStipulations,
    this.listSuperstars
  }) : super(key: key);
  @override
  _AddEditUniverseMatchesPage createState() => _AddEditUniverseMatchesPage();
}

class _AddEditUniverseMatchesPage extends State<AddEditUniverseMatchesPage> {
  final _formKey = GlobalKey<FormState>();
  late List<UniverseStipulations> listStipulations = [];
  late List<UniverseSuperstars> listSuperstars = [];
  late int stipulation;
  late int s1;
  late int s2;
  late int s3;
  late int s4;
  late int s5;
  late int s6;
  late int s7;
  late int s8;
  late int gagnant;
  late int ordre;
  late int showId;

  @override
  void initState() {
    super.initState();

    stipulation = widget.match?.stipulation ?? 0;
    s1 = widget.match?.s1 ?? 0;
    s2 = widget.match?.s2 ?? 0;
    s3 = widget.match?.s3 ?? 0;
    s4 = widget.match?.s4 ?? 0;
    s5 = widget.match?.s5 ?? 0;
    s6 = widget.match?.s6 ?? 0;
    s7 = widget.match?.s7 ?? 0;
    s8 = widget.match?.s8 ?? 0;
    gagnant = widget.match?.gagnant ?? 0;
    ordre = widget.match?.ordre ?? 0;
    showId = widget.match?.showId ?? 0;
    listStipulations = widget.listStipulations!;
    listSuperstars = widget.listSuperstars!;
  }

  

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          actions: [buildButton()],
        ),
        body: Form(
          key: _formKey,
          child: UniverseMatchesFormWidget(
            listSuperstars: listSuperstars,
            listStipulations: listStipulations,
            stipulation: stipulation,
            s1 : s1,
            s2 : s2,
            s3 : s3,
            s4 : s4,
            s5 : s5,
            s6 : s6,
            s7 : s7,
            s8 : s8,
            gagnant : gagnant,
            ordre : ordre,
            showId : widget.show!.id,
            onChangedStipulation: (stipulation) { setState(() => this.stipulation = stipulation!); getDetails(stipulation); gagnant = 0;},
            onChangedS1: (s1) => setState(() => this.s1 = s1!),
            onChangedS2: (s2) => setState(() => this.s2 = s2!),
            onChangedS3: (s3) => setState(() => this.s3 = s3!),
            onChangedS4: (s4) => setState(() => this.s4 = s4!),
            onChangedS5: (s5) => setState(() => this.s5 = s5!),
            onChangedS6: (s6) => setState(() => this.s6 = s6!),
            onChangedS7: (s7) => setState(() => this.s7 = s7!),
            onChangedS8: (s8) => setState(() => this.s8 = s8!),
            onChangedGagnant: (gagnant) => setState(() => this.gagnant = gagnant!),
            onChangedOrdre: (ordre) => setState(() => this.ordre = int.parse(ordre!)),

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
        onPressed: addOrUpdateUniverseMatches,
        child: Text('Save'),
      ),
    );
  }

  void addOrUpdateUniverseMatches() async {
    final isValid = _formKey.currentState!.validate();

    if (isValid) {
      final isUpdating = widget.match != null;

      if (isUpdating) {
        await updateUniverseMatches();
      } else {
        await addUniverseMatches();
      }

      Navigator.of(context).pop();
    }
  }

  Future updateUniverseMatches() async {
    final match = widget.match!.copy(
      stipulation: stipulation,
      s1 : s1,
      s2 : s2,
      s3 : s3,
      s4 : s4,
      s5 : s5,
      s6 : s6,
      s7 : s7,
      s8 : s8,
      gagnant : gagnant,
      ordre : ordre,
      showId : widget.show!.id,
    );

    await UniverseDatabase.instance.updateMatches(match);
  }

  Future addUniverseMatches() async {
    final stip = await UniverseDatabase.instance.readStipulation(stipulation);
    final match = UniverseMatches(
      stipulation: stipulation,
      s1 : s1,
      s2 : s2,

      s3 : stip.type == '1v1' ? 0 : s3,
      s4 : stip.type == '1v1' || stip.type == 'Triple Threat' ? 0 : s4,
      s5 : stip.type == '1v1' || stip.type == 'Triple Threat' || stip.type == '2v2' || stip.type == 'Fatal 4-Way' ? 0 : s5,
      s6 : stip.type == '1v1' || stip.type == 'Triple Threat' || stip.type == '2v2' || stip.type == 'Fatal 4-Way' || stip.type == '5-Way' ? 0 : s6,
      s7 : stip.type == '1v1' || stip.type == 'Triple Threat' || stip.type == '2v2' || stip.type == 'Fatal 4-Way' || stip.type == '5-Way' || stip.type == '3v3' || stip.type == '2v2v2' || stip.type == '6-Way' ? 0 : s7,
      s8 : stip.type == '1v1' || stip.type == 'Triple Threat' || stip.type == '2v2' || stip.type == 'Fatal 4-Way' || stip.type == '5-Way' || stip.type == '3v3' || stip.type == '2v2v2' || stip.type == '6-Way' ? 0 : s8,
      gagnant : gagnant,
      ordre : ordre,
      showId : widget.show!.id,
    );

    await UniverseDatabase.instance.createMatch(match);
  }
}