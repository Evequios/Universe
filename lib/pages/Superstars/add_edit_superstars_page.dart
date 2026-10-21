import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/brands.dart';
import 'package:wwe_universe/classes/superstars.dart';
import 'package:wwe_universe/database/superstars_database_helper.dart';
import 'package:wwe_universe/widget/superstars_form_widget.dart';

class AddEditSuperstarsPage extends StatefulWidget {
  final Superstars? superstar;
  final List<Brands>? listBrands;
  final List<Superstars>? listSuperstars;

  const AddEditSuperstarsPage({
    super.key,
    this.superstar,
    this.listBrands,
    this.listSuperstars
  });
  @override
  AddEditSuperstarsPageState createState() => AddEditSuperstarsPageState();
}

class AddEditSuperstarsPageState extends State<AddEditSuperstarsPage> {
  final _formKey = GlobalKey<FormState>();
  late List<Brands> listBrands = [];
  late List<Superstars> listSuperstars = [];
  late String name;
  late Brands? brand;
  late String orientation;
  late int division;

  @override
  void initState() {
    super.initState();

    name = widget.superstar?.name ?? '';
    brand = widget.superstar?.brand;
    orientation = widget.superstar?.orientation ?? '';
    division = widget.superstar?.division ?? 0;
    listBrands = widget.listBrands!;
    if(widget.listSuperstars != null) listSuperstars = widget.listSuperstars!;

  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      actions: [buildButton()],
    ),
    body: Form(
      key: _formKey,
      child: SuperstarsFormWidget(
        listSuperstars: listSuperstars,
        listBrands: listBrands,
        name: name,
        brand: brand,
        orientation: orientation,
        division : division,
        onChangedName: (name) => setState(() => this.name = name!),
        onChangedBrand: (brand) => setState(() => this.brand = brand!),
        onChangedOrientation: (orientation) => setState(() => this.orientation = orientation.toString()),
        onChangedDivision:(division) => setState(() => this.division = division!)
      ),
    ),
  );

  Widget buildButton() {
    final isFormValid = name.isNotEmpty && orientation.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white, 
          backgroundColor: isFormValid ? null : Colors.grey.shade700,
        ),
        onPressed: addOrUpdateUniverseSuperstars,
        child: const Text('Save'),
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

      if (mounted) {
        Navigator.of(context).pop();
      }

    }
  }

  Future updateUniverseSuperstars() async {
    final superstar = widget.superstar!.copy(
      name: name,
      brand: brand,
      orientation: orientation,
      division: division,
    );
    await SuperstarsDatabaseHelper.updateSuperstar(superstar);
  }

  Future addUniverseSuperstars() async {
    final superstar = Superstars(
      name: name,
      brand: brand,
      orientation: orientation,
      division: division
    );
    await SuperstarsDatabaseHelper.createSuperstar(superstar);
  }
}