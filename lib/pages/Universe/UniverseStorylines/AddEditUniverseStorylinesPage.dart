import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/Universe/UniverseStorylines.dart';
import 'package:wwe_universe/database.dart';
import 'package:wwe_universe/widget/Universe/UniverseStorylinesFormWidget.dart';

class AddEditUniverseStorylinesPage extends StatefulWidget {
  final UniverseStorylines? storyline;

  const AddEditUniverseStorylinesPage({
    Key? key,
    this.storyline,
  }) : super(key: key);
  @override
  _AddEditUniverseStorylinesPage createState() => _AddEditUniverseStorylinesPage();
}

class _AddEditUniverseStorylinesPage extends State<AddEditUniverseStorylinesPage> {
  final _formKey = GlobalKey<FormState>();
  late String titre;
  late String texte;
  late String debut;
  late String fin;

  @override
  void initState() {
    super.initState();

    titre = widget.storyline?.titre ?? '';
    texte = widget.storyline?.texte ?? '';
    debut = widget.storyline?.debut?? '';
    fin = widget.storyline?.fin ?? '';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          actions: [buildButton()],
        ),
        body: Form(
          key: _formKey,
          child: UniverseStorylinesFormWidget(
            titre: titre,
            texte: texte,
            debut : debut,
            fin : fin,
            onChangedTitre: (titre) => setState(() => this.titre = titre),
            onChangedTexte: (texte) => setState(() => this.texte = texte),
            onChangedDebut: (debut) => setState(() => this.debut = debut),
            onChangedFin: (fin) => setState(() => this.fin = fin),
          ),
        ),
      );

  Widget buildButton() {
    final isFormValid = titre.isNotEmpty && texte.isNotEmpty;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          onPrimary: Colors.white,
          primary: isFormValid ? null : Colors.grey.shade700,
        ),
        onPressed: addOrUpdateUniverseStorylines,
        child: Text('Save'),
      ),
    );
  }

  void addOrUpdateUniverseStorylines() async {
    final isValid = _formKey.currentState!.validate();

    if (isValid) {
      final isUpdating = widget.storyline != null;

      if (isUpdating) {
        await updateUniverseStorylines();
      } else {
        await addUniverseStorylines();
      }
    
      Navigator.of(context).pop();

    }
  }

  Future updateUniverseStorylines() async {
    final storyline = widget.storyline!.copy(
      titre: titre,
      texte: texte,
      debut: debut,
      fin: fin
    );

    await UniverseDatabase.instance.updateStoryline(storyline);
  }

  Future addUniverseStorylines() async {
    final storyline = UniverseStorylines(
      titre: titre,
      texte: texte, 
      debut: debut, 
      fin: fin
    );

    await UniverseDatabase.instance.createStoryline(storyline);
  }
}