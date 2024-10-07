import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/stipulations.dart';
import 'package:wwe_universe/database/stipulations_database_helper.dart';
import 'package:wwe_universe/widget/stipulations_form_widget.dart';

class AddEditStipulationsPage extends StatefulWidget {
  final Stipulations? stipulation;

  const AddEditStipulationsPage({
    super.key,
    this.stipulation,
  });
  @override
  AddEditStipulationsPageState createState() => AddEditStipulationsPageState();
}

class AddEditStipulationsPageState extends State<AddEditStipulationsPage> {
  final _formKey = GlobalKey<FormState>();
  late String type;
  late String stipulation;

  @override
  void initState() {
    super.initState();

    type = widget.stipulation?.type ?? '';
    stipulation = widget.stipulation?.stipulation ?? '';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      actions: [buildButton()],
    ),
    body: Form(
      key: _formKey,
      child: StipulationsFormWidget(
        type: type,
        stipulation: stipulation,
        onChangedType: (type) => setState(() => this.type = type!),
        onChangedStipulation: (stipulation) => setState(() => this.stipulation = stipulation!),
      ),
    ),
  );

  Widget buildButton() {
    final isFormValid = type.isNotEmpty && stipulation.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white, 
          backgroundColor: isFormValid ? null : Colors.grey.shade700,
        ),
        onPressed: addOrUpdateUniverseStipulations,
        child: const Text('Save'),
      ),
    );
  }

  void addOrUpdateUniverseStipulations() async {
    final isValid = _formKey.currentState!.validate();

    if (isValid) {
      final isUpdating = widget.stipulation != null;

      if (isUpdating) {
        await updateUniverseStipulations();
      } else {
        await addUniverseStipulations();
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  Future updateUniverseStipulations() async {
    final stipulation = widget.stipulation!.copy(
      type: type,
      stipulation: this.stipulation,
    );

    await StipulationsDatabaseHelper.updateStipulation(stipulation);
  }

  Future addUniverseStipulations() async {
    final stipulation = Stipulations(
      type: type, 
      stipulation: this.stipulation
    );

    await StipulationsDatabaseHelper.createStipulation(stipulation);
  }
}