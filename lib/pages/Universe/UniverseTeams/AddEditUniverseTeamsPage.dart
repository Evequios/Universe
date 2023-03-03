import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/Universe/UniverseBrands.dart';
import 'package:wwe_universe/classes/Universe/UniverseSuperstars.dart';
import 'package:wwe_universe/classes/Universe/UniverseNews.dart';
import 'package:wwe_universe/classes/Universe/UniverseTeams.dart';
import 'package:wwe_universe/database.dart';
import 'package:wwe_universe/widget/Universe/UniverseNewsFormWidget.dart';
import 'package:wwe_universe/widget/Universe/UniverseSuperstarsFormWidget.dart';
import 'package:wwe_universe/widget/Universe/UniverseTeamsFormWidget.dart';

class AddEditUniverseTeamsPage extends StatefulWidget {
  final UniverseTeams? team;
  final List<UniverseSuperstars>? listSuperstars;

  const AddEditUniverseTeamsPage({
    Key? key,
    this.team,
    this.listSuperstars
  }) : super(key: key);
  @override
  _AddEditUniverseTeamsPage createState() => _AddEditUniverseTeamsPage();
}

class _AddEditUniverseTeamsPage extends State<AddEditUniverseTeamsPage> {
  final _formKey = GlobalKey<FormState>();
  late List<UniverseSuperstars> listSuperstars = [];
  late String nom;
  late int m1;
  late int m2;
  late int m3;
  late int m4;
  late int m5;

  @override
  void initState() {
    super.initState();

    nom = widget.team?.nom ?? '';
    m1 = widget.team?.member1 ?? 0;
    m2 = widget.team?.member2 ?? 0;
    m3 = widget.team?.member3 ?? 0;
    m4 = widget.team?.member4 ?? 0;
    m5 = widget.team?.member5 ?? 0;
    listSuperstars = widget.listSuperstars!;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          actions: [buildButton()],
        ),
        body: Form(
          key: _formKey,
          child: UniverseTeamsFormWidget(
            listSuperstars: listSuperstars,
            nom: nom,
            m1: m1,
            m2: m2,
            m3: m3,
            m4: m4,
            m5: m5,
            onChangedNom: (nom) => setState(() => this.nom = nom!),
            onChangedM1: (m1) => setState(() => this.m1 = m1!),
            onChangedM2: (m2) => setState(() => this.m2 = m2!),
            onChangedM3: (m3) => setState(() => this.m3 = m3!),
            onChangedM4: (m4) => setState(() => this.m4 = m4!),
            onChangedM5: (m5) => setState(() => this.m5 = m5!),
          ),
        ),
      );

  Widget buildButton() {
    final isFormValid = nom.isNotEmpty;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          onPrimary: Colors.white,
          primary: isFormValid ? null : Colors.grey.shade700,
        ),
        onPressed: addOrUpdateUniverseTeams,
        child: Text('Save'),
      ),
    );
  }

  void addOrUpdateUniverseTeams() async {
    final isValid = _formKey.currentState!.validate();

    if (isValid) {
      final isUpdating = widget.team != null;

      if (isUpdating) {
        await updateUniverseTeams();
      } else {
        await addUniverseTeams();
      }

      Navigator.of(context).pop();

    }
  }

  Future updateUniverseTeams() async {
    final team = widget.team!.copy(
      nom: nom,
      member1: m1,
      member2: m2,
      member3: m3,
      member4: m4,
      member5: m5,
    );
    await UniverseDatabase.instance.updateTeam(team);
  }

  Future addUniverseTeams() async {
    final team = UniverseTeams(
      nom: nom,
      member1 : m1,
      member2 : m2,
      member3 : m3,
      member4 : m4,
      member5 : m5,
    );

    await UniverseDatabase.instance.createTeam(team);
  }
}