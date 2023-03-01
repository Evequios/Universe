import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/Universe/UniverseSuperstars.dart';
import 'package:wwe_universe/classes/Universe/UniverseNews.dart';
import 'package:wwe_universe/database.dart';
import 'package:wwe_universe/widget/Universe/UniverseNewsFormWidget.dart';
import 'package:wwe_universe/widget/Universe/UniverseSuperstarsFormWidget.dart';

class AddEditUniverseSuperstarsPage extends StatefulWidget {
  final UniverseSuperstars? superstar;

  const AddEditUniverseSuperstarsPage({
    Key? key,
    this.superstar
  }) : super(key: key);
  @override
  _AddEditUniverseSuperstarsPage createState() => _AddEditUniverseSuperstarsPage();
}

class _AddEditUniverseSuperstarsPage extends State<AddEditUniverseSuperstarsPage> {
  final _formKey = GlobalKey<FormState>();
  late String nom;
  late String show;
  late String orientation;

  @override
  void initState() {
    super.initState();

    nom = widget.superstar?.nom ?? '';
    show = widget.superstar?.show ?? '';
    orientation = widget.superstar?.orientation ?? '';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          actions: [buildButton()],
        ),
        body: Form(
          key: _formKey,
          child: UniverseSuperstarsFormWidget(
            nom: nom,
            show: show,
            orientation: orientation,
            onChangedNom: (nom) => setState(() => this.nom = nom),
            onChangedShow: (show) => setState(() => this.show = show.toString()),
            onChangedOrientation: (orientation) => setState(() => this.orientation = orientation.toString())
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
      show: show,
      orientation: orientation,
    );
    await UniverseDatabase.instance.updateSuperstar(superstar);
  }

  Future addUniverseSuperstars() async {
    final superstar = UniverseSuperstars(
      nom: nom,
      show: show,
      orientation: orientation,
    );

    await UniverseDatabase.instance.createSuperstar(superstar);
  }
}