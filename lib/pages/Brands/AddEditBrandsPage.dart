import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/Brands.dart';
import 'package:wwe_universe/database.dart';
import 'package:wwe_universe/widget/BrandsFormWidget.dart';

class AddEditBrandsPage extends StatefulWidget {
  final Brands? brand;

  const AddEditBrandsPage({
    Key? key,
    this.brand,
  }) : super(key: key);
  @override
  _AddEditBrandsPage createState() => _AddEditBrandsPage();
}

class _AddEditBrandsPage extends State<AddEditBrandsPage> {
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
      child: BrandsFormWidget(
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
        onPressed: addOrUpdateBrand,
        child: const Text('Save'),
      ),
    );
  }

  void addOrUpdateBrand() async {
    final isValid = _formKey.currentState!.validate();

    if (isValid) {
      final isUpdating = widget.brand != null;

      if (isUpdating) {
        await updateBrand();
      } else {
        await addBrand();
      }

      if(context.mounted) Navigator.of(context).pop();
    }
  }

  Future updateBrand() async {
    final brand = widget.brand!.copy(
      name : name,
    );

    await DatabaseService.instance.updateBrand(brand);
  }

  Future addBrand() async {
    final brand = Brands(
      name : name
    );

    await DatabaseService.instance.createBrand(brand);
  }
}