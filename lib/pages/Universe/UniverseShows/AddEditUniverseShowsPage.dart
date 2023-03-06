import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/Universe/UniverseShows.dart';
import 'package:wwe_universe/database.dart';
import 'package:wwe_universe/widget/Universe/UniverseShowsFormWidget.dart';

class AddEditUniverseShowsPage extends StatefulWidget {
  final UniverseShows? show;

  const AddEditUniverseShowsPage({
    Key? key,
    this.show,
  }) : super(key: key);
  @override
  _AddEditUniverseShowsPage createState() => _AddEditUniverseShowsPage();
}

class _AddEditUniverseShowsPage extends State<AddEditUniverseShowsPage> {
  final _formKey = GlobalKey<FormState>();
  late String nom;
  late int annee;
  late int semaine;
  late String resume;

  @override
  void initState() {
    super.initState();

    nom = widget.show?.nom ?? '';
    annee = widget.show?.annee ?? 0;
    semaine = widget.show?.semaine ?? 0;
    resume = widget.show?.resume ?? '';
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
        annee : annee,
        semaine: semaine,
        resume: resume,
        onChangedNom: (nom) => setState(() => this.nom = nom),
        onChangedAnnee: (annee) => setState(() => this.annee = int.parse(annee)),
        onChangedSemaine: (semaine) => setState(() => this.semaine = int.parse(semaine)),
        onChangedResume: (resume) => setState(() => this.resume = resume),
      ),
    ),
  );

  Widget buildButton() {
    final isFormValid = nom.isNotEmpty && nom.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white, 
          backgroundColor: isFormValid ? null : Colors.grey.shade700,
        ),
        onPressed: addOrUpdateUniverseShows,
        child: const Text('Save'),
      ),
    );
  }

  void addOrUpdateUniverseShows() async {
    final isValid = _formKey.currentState!.validate();

    if (isValid) {
      final isUpdating = widget.show != null;

      if (isUpdating) {
        await updateUniverseShows();
      } else {
        await addUniverseShows();
      }

      if(context.mounted) Navigator.of(context).pop();
    }
  }

  Future updateUniverseShows() async {
    final show = widget.show!.copy(
      nom: nom,
      annee: annee,
      semaine: semaine,
      resume: resume,
    );

    await UniverseDatabase.instance.updateShow(show);
  }

  Future addUniverseShows() async {
    final show = UniverseShows(
      nom: nom,
      annee: annee,
      semaine: semaine,
      resume: resume
    );
    await UniverseDatabase.instance.createShow(show);
  }
}