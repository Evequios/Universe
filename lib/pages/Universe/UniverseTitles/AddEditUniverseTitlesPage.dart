import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/Universe/UniverseBrands.dart';
import 'package:wwe_universe/classes/Universe/UniverseSuperstars.dart';
import 'package:wwe_universe/classes/Universe/UniverseTitles.dart';
import 'package:wwe_universe/database.dart';
import 'package:wwe_universe/widget/Universe/UniverseTitlesFormWidget.dart';

class AddEditUniverseTitlesPage extends StatefulWidget {
  final UniverseTitles? title;
  final List<UniverseBrands>? listBrands;
  final List<UniverseSuperstars>? listSuperstars;

  const AddEditUniverseTitlesPage({
    Key? key,
    this.title,
    this.listBrands,
    this.listSuperstars
  }) : super(key: key);
  @override
  _AddEditUniverseTitlesPage createState() => _AddEditUniverseTitlesPage();
}

class _AddEditUniverseTitlesPage extends State<AddEditUniverseTitlesPage> {
  final _formKey = GlobalKey<FormState>();
  late List<UniverseSuperstars> listSuperstars = [];
  late List<UniverseBrands> listBrands = [];
  late String nom;
  late int brand;
  late int tag;
  late int holder1;
  late int holder2;

  @override
  void initState() {
    super.initState();

    nom = widget.title?.nom ?? '';
    brand = widget.title?.brand ?? 0;
    tag = widget.title?.tag ?? 0;
    holder1 = widget.title?.holder1 ?? 0;
    holder2 = widget.title?.holder2 ?? 0;
    listBrands = widget.listBrands!;
    listSuperstars = widget.listSuperstars!;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          actions: [buildButton()],
        ),
        body: Form(
          key: _formKey,
          child: UniverseTitlesFormWidget(
            listSuperstars: listSuperstars,
            listBrands: listBrands,
            nom: nom,
            brand: brand,
            tag: tag,
            holder1 : holder1,
            holder2 : holder2,
            onChangedNom: (nom) => setState(() => this.nom = nom!),
            onChangedBrand: (brand) => setState(() => this.brand = brand!),
            onChangedTag: (tag) => setState(() => this.tag = tag!),
            onChangedHolder1: (holder1) => setState(() => this.holder1 = holder1!),
            onChangedHolder2: (holder2) => setState(() => this.holder2 = holder2!),
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
      final isUpdating = widget.title != null;

      if (isUpdating) {
        await updateUniverseTitles();
      } else {
        await addUniverseTitles();
      }

      Navigator.of(context).pop();
    }
  }

  Future updateUniverseTitles() async {
    final title = widget.title!.copy(
      nom: nom,
      brand: brand,
      tag: tag,
      holder1: holder1,
      holder2: holder2,
    );

    await UniverseDatabase.instance.updateTitle(title);
  }

  Future addUniverseTitles() async {
    final title = UniverseTitles(
      nom: nom,
      brand: brand,
      tag: tag,
      holder1: holder1,
      holder2: holder2,
    );

    await UniverseDatabase.instance.createTitle(title);
  }
}