import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/Universe/UniverseMatches.dart';
import 'package:wwe_universe/classes/Universe/UniverseShows.dart';
import 'package:wwe_universe/classes/Universe/UniverseStipulations.dart';
import 'package:wwe_universe/classes/Universe/UniverseSuperstars.dart';
import 'package:wwe_universe/database.dart';
import 'package:wwe_universe/widget/Universe/UniverseMatchesFormWidget.dart';

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
  late int winner;
  late int order;
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
    winner = widget.match?.winner ?? 0;
    order = widget.match?.matchOrder ?? 0;
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
        winner : winner,
        order : order,
        showId : widget.show!.id,
        onChangedStipulation: (stipulation) async { setState(() => {this.stipulation = stipulation!, getDetails(stipulation), winner = 0});},
        onChangedS1: (s1) => setState(() => this.s1 = s1!),
        onChangedS2: (s2) => setState(() => this.s2 = s2!),
        onChangedS3: (s3) => setState(() => this.s3 = s3!),
        onChangedS4: (s4) => setState(() => this.s4 = s4!),
        onChangedS5: (s5) => setState(() => this.s5 = s5!),
        onChangedS6: (s6) => setState(() => this.s6 = s6!),
        onChangedS7: (s7) => setState(() => this.s7 = s7!),
        onChangedS8: (s8) => setState(() => this.s8 = s8!),
        onChangedWinner: (winner) => setState(() => this.winner = winner!),
        onChangedOrder: (order) => setState(() => this.order = int.parse(order!)),

      ),
    ),
  );

  Widget buildButton() {
    final isFormValid = stipulation != 0 ;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white, 
          backgroundColor: isFormValid ? null : Colors.grey.shade700,
        ),
        onPressed: addOrUpdateUniverseMatches,
        child: const Text('Save'),
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

      if(context.mounted) Navigator.of(context).pop();
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
      winner : winner,
      matchOrder : order,
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
      winner : winner,
      matchOrder : order,
      showId : widget.show!.id,
    );

    await UniverseDatabase.instance.createMatch(match);
  }
}