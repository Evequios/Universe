import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/Universe/UniverseTitles.dart';
import 'package:wwe_universe/widget/Universe/UniverseTitlesFormWidget.dart';

class AddEditUniverseTitlesPage extends StatefulWidget {
  final UniverseTitles? universeTitles;

  const AddEditUniverseTitlesPage({
    Key? key,
    this.universeTitles,
  }) : super(key: key);
  @override
  _AddEditUniverseTitlesPage createState() => _AddEditUniverseTitlesPage();
}

class _AddEditUniverseTitlesPage extends State<AddEditUniverseTitlesPage> {
  final _formKey = GlobalKey<FormState>();
  late String nom;
  late String show;
  late String tag;
  late String holder1;
  late String holder2;

  @override
  void initState() {
    super.initState();

    nom = widget.universeTitles?.nom ?? '';
    show = widget.universeTitles?.show ?? '';
    tag = widget.universeTitles?.tag ?? '';
    holder1 = widget.universeTitles?.holder1 ?? '';
    holder2 = widget.universeTitles?.holder2 ?? '';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          actions: [buildButton()],
        ),
        body: Form(
          key: _formKey,
          child: UniverseTitlesFormWidget(
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
        onPressed: addOrUpdateUniverseTitles,
        child: Text('Save'),
      ),
    );
  }

  void addOrUpdateUniverseTitles() async {
    final isValid = _formKey.currentState!.validate();

    if (isValid) {
      final isUpdating = widget.universeTitles != null;

      if (isUpdating) {
        await updateUniverseTitles();
      } else {
        await addUniverseTitles();
      }

      Navigator.of(context).pop();
    }
  }

  Future updateUniverseTitles() async {
    final docUniverseTitles = FirebaseFirestore.instance.collection('UniverseTitles').doc(widget.universeTitles!.id);
    docUniverseTitles.update({
      'nom': nom,
      'show': show,
      'tag': tag,
      'holder1': holder1,
      'holder2': holder2,
    });
  }

  Future addUniverseTitles() async {
    final docUniverseTitles = FirebaseFirestore.instance.collection('UniverseTitles').doc();
    final universeTitles = UniverseTitles(
      id : docUniverseTitles.id,
      nom: nom,
      show: show,
      tag: tag,
      holder1: holder1,
      holder2: holder2,
    );

    final json = universeTitles.toJson();
    await docUniverseTitles.set(json);
  }
}