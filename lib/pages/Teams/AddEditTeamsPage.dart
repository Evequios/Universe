import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/Superstars.dart';
import 'package:wwe_universe/classes/Teams.dart';
import 'package:wwe_universe/database.dart';
import 'package:wwe_universe/widget/TeamsFormWidget.dart';

class AddEditTeamsPage extends StatefulWidget {
  final Teams? team;
  final List<Superstars>? listSuperstars;

  const AddEditTeamsPage({
    Key? key,
    this.team,
    this.listSuperstars
  }) : super(key: key);
  @override
  _AddEditTeamsPage createState() => _AddEditTeamsPage();
}

class _AddEditTeamsPage extends State<AddEditTeamsPage> {
  final _formKey = GlobalKey<FormState>();
  late List<Superstars> listSuperstars = [];
  late String name;
  late int m1;
  late int m2;
  late int m3;
  late int m4;
  late int m5;

  @override
  void initState() {
    super.initState();

    name = widget.team?.name ?? '';
    m1 = widget.team?.member1 ?? 0;
    m2 = widget.team?.member2 ?? 0;
    m3 = widget.team?.member3 ?? 0;
    m4 = widget.team?.member4 ?? 0;
    m5 = widget.team?.member5 ?? 0;
    if(widget.listSuperstars != null) listSuperstars = widget.listSuperstars!;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          actions: [buildButton()],
        ),
        body: Form(
          key: _formKey,
          child: TeamsFormWidget(
            listSuperstars: listSuperstars,
            name: name,
            m1: m1,
            m2: m2,
            m3: m3,
            m4: m4,
            m5: m5,
            onChangedName: (name) => setState(() => this.name = name!),
            onChangedM1: (m1) => setState(() => this.m1 = m1!),
            onChangedM2: (m2) => setState(() => this.m2 = m2!),
            onChangedM3: (m3) => setState(() => this.m3 = m3!),
            onChangedM4: (m4) => setState(() => this.m4 = m4!),
            onChangedM5: (m5) => setState(() => this.m5 = m5!),
          ),
        ),
      );

  Widget buildButton() {
    final isFormValid = name.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white, 
          backgroundColor: isFormValid ? null : Colors.grey.shade700,
        ),
        onPressed: addOrUpdateUniverseTeams,
        child: const Text('Save'),
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

      if(context.mounted) Navigator.of(context).pop();

    }
  }

  Future updateUniverseTeams() async {
    final team = widget.team!.copy(
      name: name,
      member1: m1,
      member2: m2,
      member3: m3,
      member4: m4,
      member5: m5,
    );
    await DatabaseService.instance.updateTeam(team);
  }

  Future addUniverseTeams() async {
    final team = Teams(
      name: name,
      member1 : m1,
      member2 : m2,
      member3 : m3,
      member4 : m4,
      member5 : m5,
    );

    await DatabaseService.instance.createTeam(team);
  }
}