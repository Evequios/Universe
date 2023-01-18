import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/Universe/UniverseSuperstars.dart';
import 'package:wwe_universe/classes/Universe/UniverseNews.dart';
import 'package:wwe_universe/widget/Universe/UniverseNewsFormWidget.dart';
import 'package:wwe_universe/widget/Universe/UniverseSuperstarsFormWidget.dart';

class AddEditUniverseSuperstarsPage extends StatefulWidget {
  final UniverseSuperstars? universeSuperstars;

  const AddEditUniverseSuperstarsPage({
    Key? key,
    this.universeSuperstars,
  }) : super(key: key);
  @override
  _AddEditUniverseSuperstarsPage createState() => _AddEditUniverseSuperstarsPage();
}

class _AddEditUniverseSuperstarsPage extends State<AddEditUniverseSuperstarsPage> {
  final _formKey = GlobalKey<FormState>();
  late String prenom;
  late String nom;
  late String show;
  late String orientation;
  late String titre;

  @override
  void initState() {
    super.initState();

    prenom = widget.universeSuperstars?.prenom ?? '';
    nom = widget.universeSuperstars?.nom ?? '';
    show = widget.universeSuperstars?.show ?? '';
    orientation = widget.universeSuperstars?.orientation ?? '';
    titre = widget.universeSuperstars?.titre ?? '';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          actions: [buildButton()],
        ),
        body: Form(
          key: _formKey,
          child: UniverseSuperstarsFormWidget(
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
      final isUpdating = widget.universeSuperstars != null;

      if (isUpdating) {
        await updateUniverseSuperstars();
      } else {
        await addUniverseSuperstars();
      }

      Navigator.of(context).pop();
    }
  }

  Future updateUniverseSuperstars() async {
    final docUniverseSuperstars = FirebaseFirestore.instance.collection('UniverseSuperstars').doc(widget.universeSuperstars!.id);
    docUniverseSuperstars.update({
      'nom': nom,
      'prenom': prenom,
      'show': show,
      'orientation': orientation,
      'titre': titre
    }
    );
  }

  Future addUniverseSuperstars() async {
    final docUniverseSuperstars = FirebaseFirestore.instance.collection('UniverseSuperstars').doc();
    
    final universeSuperstars = UniverseSuperstars(
      id : docUniverseSuperstars.id,
      nom: nom,
      prenom: prenom,
      show: show,
      orientation: orientation,
      titre: titre
    );

    final json = universeSuperstars.toJson();
    await docUniverseSuperstars.set(json);
  }
}