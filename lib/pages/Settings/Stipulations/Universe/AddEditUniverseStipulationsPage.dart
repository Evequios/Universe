import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/Universe/UniverseStipulations.dart';
import 'package:wwe_universe/database.dart';
import 'package:wwe_universe/widget/Universe/UniverseStipulationsFormWidget.dart';

class AddEditUniverseStipulationsPage extends StatefulWidget {
  final UniverseStipulations? stipulation;

  const AddEditUniverseStipulationsPage({
    Key? key,
    this.stipulation,
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

      if(context.mounted) Navigator.of(context).pop();
    }
  }

  Future updateUniverseStipulations() async {
    final stipulation = widget.stipulation!.copy(
      type: type,
      stipulation: this.stipulation,
    );

    await UniverseDatabase.instance.updateStipulation(stipulation);
  }

  Future addUniverseStipulations() async {
    final stipulation = UniverseStipulations(
      type: type, 
      stipulation: this.stipulation
    );

    await UniverseDatabase.instance.createStipulation(stipulation);
  }
}