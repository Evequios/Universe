import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/IRL/IRLStipulations.dart';
import 'package:wwe_universe/widget/IRL/IRLStipulationsFormWidget.dart';

class AddEditIRLStipulationsPage extends StatefulWidget {
  final IRLStipulations? irlStipulations;

  const AddEditIRLStipulationsPage({
    Key? key,
    this.irlStipulations,
  }) : super(key: key);
  @override
  _AddEditIRLStipulationsPage createState() => _AddEditIRLStipulationsPage();
}

class _AddEditIRLStipulationsPage extends State<AddEditIRLStipulationsPage> {
  final _formKey = GlobalKey<FormState>();
  late String type;
  late String stipulation;

  @override
  void initState() {
    super.initState();

    type = widget.irlStipulations?.type ?? '';
    stipulation = widget.irlStipulations?.stipulation ?? '';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          actions: [buildButton()],
        ),
        body: Form(
          key: _formKey,
          child: IRLStipulationsFormWidget(
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
        onPressed: addOrUpdateIRLStipulations,
        child: Text('Save'),
      ),
    );
  }

  void addOrUpdateIRLStipulations() async {
    final isValid = _formKey.currentState!.validate();

    if (isValid) {
      final isUpdating = widget.irlStipulations != null;

      if (isUpdating) {
        await updateIRLStipulations();
      } else {
        await addIRLStipulations();
      }

      Navigator.of(context).pop();
    }
  }

  Future updateIRLStipulations() async {
    final docIRLStipulations = FirebaseFirestore.instance.collection('IRLStipulations').doc(widget.irlStipulations!.id);
    docIRLStipulations.update({
      'type': type,
      'stipulation': stipulation,
    });
  }

  Future addIRLStipulations() async {
    final docIRLStipulations = FirebaseFirestore.instance.collection('IRLStipulations').doc();
    final irlStipulations = IRLStipulations(
      id : docIRLStipulations.id,
      type: type,
      stipulation: stipulation
    );

    final json = irlStipulations.toJson();
    await docIRLStipulations.set(json);
  }
}