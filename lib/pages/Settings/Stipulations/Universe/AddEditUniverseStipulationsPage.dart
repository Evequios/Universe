import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/Universe/UniverseStipulations.dart';
import 'package:wwe_universe/widget/Universe/UniverseStipulationsFormWidget.dart';

class AddEditUniverseStipulationsPage extends StatefulWidget {
  final UniverseStipulations? universeStipulations;

  const AddEditUniverseStipulationsPage({
    Key? key,
    this.universeStipulations,
  }) : super(key: key);
  @override
  _AddEditUniverseStipulationsPage createState() => _AddEditUniverseStipulationsPage();
}

class _AddEditUniverseStipulationsPage extends State<AddEditUniverseStipulationsPage> {
  final _formKey = GlobalKey<FormState>();
  late String type;
  late String stipulation;

  @override
  void initState() {
    super.initState();

    type = widget.universeStipulations?.type ?? '';
    stipulation = widget.universeStipulations?.stipulation ?? '';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          actions: [buildButton()],
        ),
        body: Form(
          key: _formKey,
          child: UniverseStipulationsFormWidget(
            type: type,
            stipulation: stipulation,
            onChangedType: (type) => setState(() => this.type = type),
            onChangedStipulation: (stipulation) => setState(() => this.stipulation = stipulation),
          ),
        ),
      );

  Widget buildButton() {
    final isFormValid = type.isNotEmpty && stipulation.isNotEmpty;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          onPrimary: Colors.white,
          primary: isFormValid ? null : Colors.grey.shade700,
        ),
        onPressed: addOrUpdateUniverseStipulations,
        child: Text('Save'),
      ),
    );
  }

  void addOrUpdateUniverseStipulations() async {
    final isValid = _formKey.currentState!.validate();

    if (isValid) {
      final isUpdating = widget.universeStipulations != null;

      if (isUpdating) {
        await updateUniverseStipulations();
      } else {
        await addUniverseStipulations();
      }

      Navigator.of(context).pop();
    }
  }

  Future updateUniverseStipulations() async {
    final docUniverseStipulations = FirebaseFirestore.instance.collection('UniverseStipulations').doc(widget.universeStipulations!.id);
    docUniverseStipulations.update({
      'type': type,
      'stipulation': stipulation,
    });
  }

  Future addUniverseStipulations() async {
    final docUniverseStipulations = FirebaseFirestore.instance.collection('UniverseStipulations').doc();
    final universeStipulations = UniverseStipulations(
      id : docUniverseStipulations.id,
      type: type,
      stipulation: stipulation
    );

    final json = universeStipulations.toJson();
    await docUniverseStipulations.set(json);
  }
}