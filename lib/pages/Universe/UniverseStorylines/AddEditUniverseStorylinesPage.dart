import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/Universe/UniverseStorylines.dart';
import 'package:wwe_universe/widget/Universe/UniverseStorylinesFormWidget.dart';

class AddEditUniverseStorylinesPage extends StatefulWidget {
  final UniverseStorylines? universeStorylines;

  const AddEditUniverseStorylinesPage({
    Key? key,
    this.universeStorylines,
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

    titre = widget.universeStorylines?.titre ?? '';
    texte = widget.universeStorylines?.texte ?? '';
    debut = widget.universeStorylines?.debut?? '';
    fin = widget.universeStorylines?.fin ?? '';
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
      final isUpdating = widget.universeStorylines != null;

      if (isUpdating) {
        await updateUniverseStorylines();
      } else {
        await addUniverseStorylines();
      }
      Navigator.of(context).pop();
    }
  }

  Future updateUniverseStorylines() async {
    final docUniverseStorylines = FirebaseFirestore.instance.collection('UniverseStorylines').doc(widget.universeStorylines!.id);
    docUniverseStorylines.update({
      'titre': titre,
      'texte': texte,
      'debut': debut,
      'fin': fin
    });
  }

  Future addUniverseStorylines() async {
    final docUniverseStorylines = FirebaseFirestore.instance.collection('UniverseStorylines').doc();

    final universeStoryline = UniverseStorylines(
      id : docUniverseStorylines.id,
      titre: titre,
      texte: texte, 
      debut: debut, 
      fin: fin
    );
    final json = universeStoryline.toJson();
    await docUniverseStorylines.set(json);
  }
}