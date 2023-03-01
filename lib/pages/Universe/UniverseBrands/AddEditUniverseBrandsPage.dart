import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/Universe/UniverseBrands.dart';
import 'package:wwe_universe/classes/Universe/UniverseNews.dart';
import 'package:wwe_universe/database.dart';
import 'package:wwe_universe/widget/Universe/UniverseBrandsFormWidget.dart';
import 'package:wwe_universe/widget/Universe/UniverseNewsFormWidget.dart';

class AddEditUniverseBrandsPage extends StatefulWidget {
  final UniverseBrands? brand;

  const AddEditUniverseBrandsPage({
    Key? key,
    this.brand,
  }) : super(key: key);
  @override
  _AddEditUniverseBrandsPage createState() => _AddEditUniverseBrandsPage();
}

class _AddEditUniverseBrandsPage extends State<AddEditUniverseBrandsPage> {
  final _formKey = GlobalKey<FormState>();
  late String nom;

  @override
  void initState() {
    super.initState();

    nom = widget.brand?.nom ?? '';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      actions: [buildButton()],
    ),
    body: Form(
      key: _formKey,
      child: UniverseBrandsFormWidget(
        nom: nom,
        onChangedNom: (nom) => setState(() => this.nom = nom),
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
        onPressed: addOrUpdateUniverseBrand,
        child: Text('Save'),
      ),
    );
  }

  void addOrUpdateUniverseBrand() async {
    final isValid = _formKey.currentState!.validate();

    if (isValid) {
      final isUpdating = widget.brand != null;

      if (isUpdating) {
        await updateUniverseBrand();
      } else {
        await addUniverseBrand();
      }

      Navigator.of(context).pop();
    }
  }

  Future updateUniverseBrand() async {
    final brand = widget.brand!.copy(
      nom : nom,
    );

    await UniverseDatabase.instance.updateBrand(brand);
  }

  Future addUniverseBrand() async {
    final brand = UniverseBrands(
      nom : nom
    );

    await UniverseDatabase.instance.createBrand(brand);
  }
}