import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/IRL/IRLSuperstars.dart';
import 'package:wwe_universe/classes/IRL/IRLNews.dart';
import 'package:wwe_universe/widget/IRL/IRLNewsFormWidget.dart';
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

  @override
  void initState() {
    super.initState();

    prenom = widget.irlSuperstars?.prenom ?? '';
    nom = widget.irlSuperstars?.nom ?? '';
    show = widget.irlSuperstars?.show ?? '';
    orientation = widget.irlSuperstars?.orientation ?? '';
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
            onChangedPrenom: (prenom) => setState(() => this.prenom = prenom),
            onChangedNom: (nom) => setState(() => this.nom = nom),
            onChangedShow: (show) => setState(() => this.show = show.toString()),
            onChangedOrientation: (orientation) => setState(() => this.orientation = orientation.toString()),
          ),
        ),
      );

  Widget buildButton() {
    final isFormValid = prenom.isNotEmpty && nom.isNotEmpty && orientation.isNotEmpty;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          onPrimary: Colors.white,
          primary: isFormValid ? null : Colors.grey.shade700,
        ),
        onPressed: addOrUpdateIRLSuperstars,
        child: Text('Save'),
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

      Navigator.of(context).pop();
    }
  }

  Future updateIRLSuperstars() async {
    final docIRLSuperstars = FirebaseFirestore.instance.collection('IRLSuperstars').doc(widget.irlSuperstars!.id);
    docIRLSuperstars.update({
      'nom': nom,
      'prenom': prenom,
      'show': show,
      'orientation': orientation,
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
    );

    final json = irlSuperstars.toJson();
    await docIRLSuperstars.set(json);
  }
}