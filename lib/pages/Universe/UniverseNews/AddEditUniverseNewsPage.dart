import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/Universe/UniverseNews.dart';
import 'package:wwe_universe/database.dart';
import 'package:wwe_universe/widget/Universe/UniverseNewsFormWidget.dart';

class AddEditUniverseNewsPage extends StatefulWidget {
  final UniverseNews? news;

  const AddEditUniverseNewsPage({
    Key? key,
    this.news,
  }) : super(key: key);
  @override
  _AddEditUniverseNewsPage createState() => _AddEditUniverseNewsPage();
}

class _AddEditUniverseNewsPage extends State<AddEditUniverseNewsPage> {
  final _formKey = GlobalKey<FormState>();
  late String titre;
  late String texte;
  late String categorie;

  @override
  void initState() {
    super.initState();

    titre = widget.news?.title ?? '';
    texte = widget.news?.text ?? '';
    categorie = widget.news?.type ?? '';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      actions: [buildButton()],
    ),
    body: Form(
      key: _formKey,
      child: UniverseNewsFormWidget(
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
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white, 
          backgroundColor: isFormValid ? null : Colors.grey.shade700,
        ),
        onPressed: addOrUpdateUniverseNews,
        child: const Text('Save'),
      ),
    );
  }

  void addOrUpdateUniverseNews() async {
    final isValid = _formKey.currentState!.validate();

    if (isValid) {
      final isUpdating = widget.news != null;

      if (isUpdating) {
        await updateUniverseNews();
      } else {
        await addUniverseNews();
      }

      if(context.mounted) Navigator.of(context).pop();
    }
  }

  Future updateUniverseNews() async {
    final news = widget.news!.copy(
      title: titre,
      text: texte,
      type: categorie != '' ? categorie : "Annonce",
    );

    await UniverseDatabase.instance.updateNews(news);
  }

  Future addUniverseNews() async {
    final news = UniverseNews(
      title: titre,
      text: texte,
      createdTime: DateTime.now(),
      type: categorie != '' ? categorie : "Annonce" 
    );

    await UniverseDatabase.instance.createNews(news);
  }
}