import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/Universe/UniverseBrands.dart';
import 'package:wwe_universe/classes/Universe/UniverseSuperstars.dart';
import 'package:wwe_universe/classes/Universe/UniverseNews.dart';
import 'package:wwe_universe/database.dart';
import 'package:wwe_universe/widget/Universe/UniverseNewsFormWidget.dart';
import 'package:wwe_universe/widget/Universe/UniverseSuperstarsFormWidget.dart';

class AddEditUniverseSuperstarsPage extends StatefulWidget {
  final UniverseSuperstars? superstar;
  final List<UniverseBrands>? listBrands;
  final List<UniverseSuperstars>? listSuperstars;

  const AddEditUniverseSuperstarsPage({
    Key? key,
    this.superstar,
    this.listBrands,
    this.listSuperstars
  }) : super(key: key);
  @override
  _AddEditUniverseSuperstarsPage createState() => _AddEditUniverseSuperstarsPage();
}

class _AddEditUniverseSuperstarsPage extends State<AddEditUniverseSuperstarsPage> {
  final _formKey = GlobalKey<FormState>();
  late List<UniverseBrands> listBrands = [];
  late List<UniverseSuperstars> listSuperstars = [];
  late String nom;
  late int brand;
  late String orientation;
  late int rival1;

  @override
  void initState() {
    super.initState();

    nom = widget.superstar?.nom ?? '';
    brand = widget.superstar?.brand ?? 0;
    orientation = widget.superstar?.orientation ?? '';
    rival1 = widget.superstar?.rival1 ?? 0;
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
          child: UniverseSuperstarsFormWidget(
            listSuperstars: listSuperstars,
            listBrands: listBrands,
            nom: nom,
            brand: brand,
            orientation: orientation,
            rival1 : rival1,
            onChangedNom: (nom) => setState(() => this.nom = nom!),
            onChangedBrand: (brand) => setState(() => this.brand = brand!),
            onChangedOrientation: (orientation) => setState(() => this.orientation = orientation.toString()),
            onChangedRival1: (rival1) => setState(() => this.rival1 = rival1!)
          ),
        ),
      );

  Widget buildButton() {
    final isFormValid = nom.isNotEmpty && orientation.isNotEmpty;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          onPrimary: Colors.white,
          primary: isFormValid ? null : Colors.grey.shade700,
        ),
        onPressed: addOrUpdateUniverseSuperstars,
        child: Text('Save'),
      ),
    );
  }

  void addOrUpdateUniverseSuperstars() async {
    final isValid = _formKey.currentState!.validate();

    if (isValid) {
      final isUpdating = widget.superstar != null;

      if (isUpdating) {
        await updateUniverseSuperstars();
      } else {
        await addUniverseSuperstars();
      }

      Navigator.of(context).pop();

    }
  }

  Future updateUniverseSuperstars() async {
    final superstar = widget.superstar!.copy(
      nom: nom,
      brand: brand,
      orientation: orientation,
      rival1: rival1
    );
    await UniverseDatabase.instance.updateSuperstar(superstar);
  }

  Future addUniverseSuperstars() async {
    final superstar = UniverseSuperstars(
      nom: nom,
      brand: brand,
      orientation: orientation,
      rival1: rival1
    );
    await UniverseDatabase.instance.createSuperstar(superstar);
  }
}