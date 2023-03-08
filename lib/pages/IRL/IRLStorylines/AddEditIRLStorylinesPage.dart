import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/IRL/IRLStorylines.dart';
import 'package:wwe_universe/widget/IRL/IRLStorylinesFormWidget.dart';

class AddEditIRLStorylinesPage extends StatefulWidget {
  final IRLStorylines? irlStorylines;

  const AddEditIRLStorylinesPage({
    Key? key,
    this.irlStorylines,
  }) : super(key: key);
  @override
  _AddEditIRLStorylinesPage createState() => _AddEditIRLStorylinesPage();
}

class _AddEditIRLStorylinesPage extends State<AddEditIRLStorylinesPage> {
  final _formKey = GlobalKey<FormState>();
  late String titre;
  late String texte;
  late String debut;
  late String fin;

  @override
  void initState() {
    super.initState();

    titre = widget.irlStorylines?.titre ?? '';
    texte = widget.irlStorylines?.texte ?? '';
    debut = widget.irlStorylines?.debut?? '';
    fin = widget.irlStorylines?.fin ?? '';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          actions: [buildButton()],
        ),
        body: Form(
          key: _formKey,
          child: IRLStorylinesFormWidget(
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
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white, 
          backgroundColor: isFormValid ? null : Colors.grey.shade700,
        ),
        onPressed: addOrUpdateIRLStorylines,
        child: const Text('Save'),
      ),
    );
  }

  void addOrUpdateIRLStorylines() async {
    final isValid = _formKey.currentState!.validate();

    if (isValid) {
      final isUpdating = widget.irlStorylines != null;

      if (isUpdating) {
        await updateIRLStorylines();
      } else {
        await addIRLStorylines();
      }
      if(context.mounted) Navigator.of(context).pop();
    }
  }

  Future updateIRLStorylines() async {
    final docIRLStorylines = FirebaseFirestore.instance.collection('IRLStorylines').doc(widget.irlStorylines!.id);
    docIRLStorylines.update({
      'titre': titre,
      'texte': texte,
      'debut': debut,
      'fin': fin
    });
  }

  Future addIRLStorylines() async {
    final docIRLStorylines = FirebaseFirestore.instance.collection('IRLStorylines').doc();

    final irlStoryline = IRLStorylines(
      id : docIRLStorylines.id,
      titre: titre,
      texte: texte, 
      debut: debut, 
      fin: fin
    );
    final json = irlStoryline.toJson();
    await docIRLStorylines.set(json);
  }
}