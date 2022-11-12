import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/IRLNews.dart';
import 'package:wwe_universe/widget/IRLNewsFormWidget.dart';

class AddEditIRLNewsPage extends StatefulWidget {
  final IRLNews? irlNews;

  const AddEditIRLNewsPage({
    Key? key,
    this.irlNews,
  }) : super(key: key);
  @override
  _AddEditIRLNewsPage createState() => _AddEditIRLNewsPage();
}

class _AddEditIRLNewsPage extends State<AddEditIRLNewsPage> {
  final _formKey = GlobalKey<FormState>();
  late String titre;
  late String texte;
  late String categorie;

  @override
  void initState() {
    super.initState();

    titre = widget.irlNews?.titre ?? '';
    texte = widget.irlNews?.texte ?? '';
    categorie = widget.irlNews?.categorie ?? '';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          actions: [buildButton()],
        ),
        body: Form(
          key: _formKey,
          child: IRLNewsFormWidget(
            titre: titre,
            texte: texte,
            categorie: categorie,
            onChangedTitre: (titre) => setState(() => this.titre = titre),
            onChangedTexte: (texte) => setState(() => this.texte = texte),
            onChangedCategorie: (categorie) => setState(() => this.categorie = categorie.toString()),
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
        onPressed: addOrUpdateIRLNews,
        child: Text('Save'),
      ),
    );
  }

  void addOrUpdateIRLNews() async {
    final isValid = _formKey.currentState!.validate();

    if (isValid) {
      final isUpdating = widget.irlNews != null;

      if (isUpdating) {
        await updateIRLNews();
      } else {
        await addIRLNews();
      }

      Navigator.of(context).pop();
    }
  }

  Future updateIRLNews() async {
    final docIRLNews = FirebaseFirestore.instance.collection('IRLNews').doc(widget.irlNews!.id);
    docIRLNews.update({
      'titre': titre,
      'texte': texte,
      'categorie': categorie != '' ? categorie : "Annonce",
    });
  }

  Future addIRLNews() async {
    final docIRLNews = FirebaseFirestore.instance.collection('IRLNews').doc();
    final irlNews = IRLNews(
      id : docIRLNews.id,
      titre: titre,
      texte: texte,
      createdTime: Timestamp.now(),
      categorie: categorie != '' ? categorie : "Annonce" 
    );

    final json = irlNews.toJson();
    await docIRLNews.set(json);
  }
}