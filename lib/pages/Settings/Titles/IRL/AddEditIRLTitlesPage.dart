import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/IRL/IRLTitles.dart';
import 'package:wwe_universe/widget/IRL/IRLTitlesFormWidget.dart';

class AddEditIRLTitlesPage extends StatefulWidget {
  final IRLTitles? irlTitles;

  const AddEditIRLTitlesPage({
    Key? key,
    this.irlTitles,
  }) : super(key: key);
  @override
  _AddEditIRLTitlesPage createState() => _AddEditIRLTitlesPage();
}

class _AddEditIRLTitlesPage extends State<AddEditIRLTitlesPage> {
  final _formKey = GlobalKey<FormState>();
  late String nom;
  late String show;
  late String tag;
  late String holder1;
  late String holder2;

  @override
  void initState() {
    super.initState();

    nom = widget.irlTitles?.nom ?? '';
    show = widget.irlTitles?.show ?? '';
    tag = widget.irlTitles?.tag ?? '';
    holder1 = widget.irlTitles?.holder1 ?? '';
    holder2 = widget.irlTitles?.holder2 ?? '';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          actions: [buildButton()],
        ),
        body: Form(
          key: _formKey,
          child: IRLTitlesFormWidget(
            nom: nom,
            show: show,
            tag: tag,
            holder1 : holder1,
            holder2 : holder2,
            onChangedNom: (nom) => setState(() => this.nom = nom),
            onChangedShow: (show) => setState(() => this.show = show),
            onChangedTag: (tag) => setState(() => this.tag = tag.toString()),
            onChangedHolder1: (holder1) => setState(() => this.holder1 = holder1.toString()),
            onChangedHolder2: (holder2) => setState(() => this.holder2 = holder2.toString()),
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
        onPressed: addOrUpdateIRLTitles,
        child: Text('Save'),
      ),
    );
  }

  void addOrUpdateIRLTitles() async {
    final isValid = _formKey.currentState!.validate();

    if (isValid) {
      final isUpdating = widget.irlTitles != null;

      if (isUpdating) {
        await updateIRLTitles();
      } else {
        await addIRLTitles();
      }

      Navigator.of(context).pop();
    }
  }

  Future updateIRLTitles() async {
    final docIRLTitles = FirebaseFirestore.instance.collection('IRLTitles').doc(widget.irlTitles!.id);
    docIRLTitles.update({
      'nom': nom,
      'show': show,
      'tag': tag,
      'holder1': holder1,
      'holder2': holder2,
    });
  }

  Future addIRLTitles() async {
    final docIRLTitles = FirebaseFirestore.instance.collection('IRLTitles').doc();
    final irlTitles = IRLTitles(
      id : docIRLTitles.id,
      nom: nom,
      show: show,
      tag: tag,
      holder1: holder1,
      holder2: holder2,
    );

    final json = irlTitles.toJson();
    await docIRLTitles.set(json);
  }
}