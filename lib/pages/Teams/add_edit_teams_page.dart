
import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/superstars.dart';
import 'package:wwe_universe/classes/teams.dart';
import 'package:wwe_universe/database/teams_database_helper.dart';
import 'package:wwe_universe/widget/teams_form_widget.dart';

class AddEditTeamsPage extends StatefulWidget {
  final Teams? team;
  final List<Superstars>? listSuperstars;

  const AddEditTeamsPage({
    super.key,
    this.team,
    this.listSuperstars,
  });

  @override
  AddEditTeamsPageState createState() => AddEditTeamsPageState();
}

class AddEditTeamsPageState extends State<AddEditTeamsPage> {
  final _formKey = GlobalKey<FormState>();

  late List<Superstars> listSuperstars;

  late String name;

  int? m1;
  int? m2;
  int? m3;
  int? m4;
  int? m5;

  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    listSuperstars = widget.listSuperstars ?? [];

    name = widget.team?.name ?? '';

    m1 = widget.team?.member1.id;
    m2 = widget.team?.member2.id;
    m3 = widget.team?.member3?.id;
    m4 = widget.team?.member4?.id;
    m5 = widget.team?.member5?.id;
  }

  Superstars? getSuperstar(int? id) {
    if (id == null) return null;

    for (final superstar in listSuperstars) {
      if (superstar.id == id) return superstar;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.team != null;

    return Scaffold(
      backgroundColor: const Color(0xFF101010),
      appBar: AppBar(
        backgroundColor: const Color(0xFF101010),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          isEditing ? 'EDIT TEAM' : 'CREATE TEAM',
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            child: FilledButton.icon(
              onPressed: isSaving ? null : addOrUpdateUniverseTeams,
              icon: isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save_outlined),
              label: const Text('SAVE'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFD71920),
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
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
          onChangedName: (value) {
            name = value ?? '';
          },
          onChangedM1: (value) => setState(() => m1 = value),
          onChangedM2: (value) => setState(() => m2 = value),
          onChangedM3: (value) => setState(() => m3 = value),
          onChangedM4: (value) => setState(() => m4 = value),
          onChangedM5: (value) => setState(() => m5 = value),
        ),
      ),
    );
  }

  Future<void> addOrUpdateUniverseTeams() async {
    if (isSaving) return;

    if (!_formKey.currentState!.validate()) return;

    final member1 = getSuperstar(m1);
    final member2 = getSuperstar(m2);

    if (member1 == null || member2 == null) return;

    setState(() => isSaving = true);

    try {
      final team = Teams(
        id: widget.team?.id,
        name: name.trim(),
        member1: member1,
        member2: member2,
        member3: getSuperstar(m3),
        member4: getSuperstar(m4),
        member5: getSuperstar(m5),
      );

      if (widget.team == null) {
        await TeamsDatabaseHelper.createTeam(team);
      } else {
        await TeamsDatabaseHelper.updateTeam(team);
      }

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to save the team: $e'),
        ),
      );

      setState(() => isSaving = false);
    }
  }
}
