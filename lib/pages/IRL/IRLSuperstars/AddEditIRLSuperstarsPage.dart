import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/IRL/IRLSuperstars.dart';
import 'package:wwe_universe/widget/IRL/IRLSuperstarsFormWidget.dart';

class AddEditIRLSuperstarsPage extends StatefulWidget {
  final IRLSuperstars? irlSuperstars;

  const AddEditIRLSuperstarsPage({
    Key? key,
    this.irlSuperstars,
  }) : super(key: key);
  @override
  _AddEditIRLSuperstarsPage createState() => _AddEditIRLSuperstarsPage();
}

class _AddEditIRLSuperstarsPage extends State<AddEditIRLSuperstarsPage> {
  final _formKey = GlobalKey<FormState>();
  late String prenom;
  late String nom;
  late String show;
  late String orientation;
  late String titre;

  @override
  void initState() {
    super.initState();

    prenom = widget.irlSuperstars?.prenom ?? '';
    nom = widget.irlSuperstars?.nom ?? '';
    show = widget.irlSuperstars?.show ?? '';
    orientation = widget.irlSuperstars?.orientation ?? '';
    titre = widget.irlSuperstars?.titre ?? '';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          actions: [buildButton()],
        ),
        body: Form(
          key: _formKey,
          child: IRLSuperstarsFormWidget(
            prenom: prenom,
            nom: nom,
            show: show,
            orientation: orientation,
            titre: titre,
            onChangedPrenom: (prenom) => setState(() => this.prenom = prenom),
            onChangedNom: (nom) => setState(() => this.nom = nom),
            onChangedShow: (show) => setState(() => this.show = show.toString()),
            onChangedOrientation: (orientation) => setState(() => this.orientation = orientation.toString()),
            onChangedTitre: (titre) => setState(() => this.titre = titre.toString()),
          ),
        ),
      );

  Widget buildButton() {
    final isFormValid = prenom.isNotEmpty && nom.isNotEmpty && orientation.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white, 
          backgroundColor: isFormValid ? null : Colors.grey.shade700,
        ),
        onPressed: addOrUpdateIRLSuperstars,
        child: const Text('Save'),
      ),
    );
  }

  void addOrUpdateIRLSuperstars() async {
    final isValid = _formKey.currentState!.validate();

    if (isValid) {
      final isUpdating = widget.irlSuperstars != null;

      if (isUpdating) {
        await updateIRLSuperstars();
      } else {
        await addIRLSuperstars();
      }

      if(context.mounted) Navigator.of(context).pop();
    }
  }

  Future updateIRLSuperstars() async {
    final docIRLSuperstars = FirebaseFirestore.instance.collection('IRLSuperstars').doc(widget.irlSuperstars!.id);
    docIRLSuperstars.update({
      'nom': nom,
      'prenom': prenom,
      'show': show,
      'orientation': orientation,
      'titre': titre
    }
    );
  }

  Future addIRLSuperstars() async {
    final docIRLSuperstars = FirebaseFirestore.instance.collection('IRLSuperstars').doc();
    
    final irlSuperstars = IRLSuperstars(
      id : docIRLSuperstars.id,
      nom: nom,
      prenom: prenom,
      show: show,
      orientation: orientation,
      titre: titre
    );

    final json = irlSuperstars.toJson();
    await docIRLSuperstars.set(json);
  }
}