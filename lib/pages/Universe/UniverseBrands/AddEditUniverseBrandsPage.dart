import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/Universe/UniverseBrands.dart';
import 'package:wwe_universe/database.dart';
import 'package:wwe_universe/widget/Universe/UniverseBrandsFormWidget.dart';

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
  late String name;

  @override
  void initState() {
    super.initState();

    name = widget.brand?.name ?? '';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      actions: [buildButton()],
    ),
    body: Form(
      key: _formKey,
      child: UniverseBrandsFormWidget(
        name: name,
        onChangedName: (name) => setState(() => this.name = name),
      ),
    ),
  );

  Widget buildButton() {
    final isFormValid = name.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white, 
          backgroundColor: isFormValid ? null : Colors.grey.shade700,
        ),
        onPressed: addOrUpdateUniverseBrand,
        child: const Text('Save'),
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

      if(context.mounted) Navigator.of(context).pop();
    }
  }

  Future updateUniverseBrand() async {
    final brand = widget.brand!.copy(
      name : name,
    );

    await UniverseDatabase.instance.updateBrand(brand);
  }

  Future addUniverseBrand() async {
    final brand = UniverseBrands(
      name : name
    );

    await UniverseDatabase.instance.createBrand(brand);
  }
}