import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/Universe/UniverseBrands.dart';
import 'package:wwe_universe/classes/Universe/UniverseSuperstars.dart';
import 'package:wwe_universe/database.dart';
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
  late String name;
  late int brand;
  late String orientation;
  late int ally1, ally2, ally3, ally4, ally5;
  late int rival1, rival2, rival3, rival4, rival5;
  late int division;

  @override
  void initState() {
    super.initState();

    name = widget.superstar?.name ?? '';
    brand = widget.superstar?.brand ?? 0;
    orientation = widget.superstar?.orientation ?? '';
    ally1 = widget.superstar?.ally1 ?? 0;
    ally2 = widget.superstar?.ally2 ?? 0;
    ally3 = widget.superstar?.ally3 ?? 0;
    ally4 = widget.superstar?.ally4 ?? 0;
    ally5 = widget.superstar?.ally5 ?? 0;
    rival1 = widget.superstar?.rival1 ?? 0;
    rival2 = widget.superstar?.rival2 ?? 0;
    rival3 = widget.superstar?.rival3 ?? 0;
    rival4 = widget.superstar?.rival4 ?? 0;
    rival5 = widget.superstar?.rival5 ?? 0;
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
      child: UniverseSuperstarsFormWidget(
        listSuperstars: listSuperstars,
        listBrands: listBrands,
        name: name,
        brand: brand,
        orientation: orientation,
        ally1 : ally1,
        ally2 : ally2,
        ally3 : ally3,
        ally4 : ally4,
        ally5 : ally5,
        rival1 : rival1,
        rival2 : rival2,
        rival3 : rival3,
        rival4 : rival4,
        rival5 : rival5,
        division : division,
        onChangedName: (name) => setState(() => this.name = name!),
        onChangedBrand: (brand) => setState(() => this.brand = brand!),
        onChangedOrientation: (orientation) => setState(() => this.orientation = orientation.toString()),
        onChangedAlly1: (ally1) => setState(() => this.ally1 = ally1!),
        onChangedAlly2: (ally2) => setState(() => this.ally2 = ally2!),
        onChangedAlly3: (ally3) => setState(() => this.ally3 = ally3!),
        onChangedAlly4: (ally4) => setState(() => this.ally4 = ally4!),
        onChangedAlly5: (ally5) => setState(() => this.ally5 = ally5!),
        onChangedRival1: (rival1) => setState(() => this.rival1 = rival1!),
        onChangedRival2: (rival2) => setState(() => this.rival2 = rival2!),
        onChangedRival3: (rival3) => setState(() => this.rival3 = rival3!),
        onChangedRival4: (rival4) => setState(() => this.rival4 = rival4!),
        onChangedRival5: (rival5) => setState(() => this.rival5 = rival5!),
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

      if(context.mounted) Navigator.of(context).pop();

    }
  }

  Future updateUniverseSuperstars() async {
    final superstar = widget.superstar!.copy(
      name: name,
      brand: brand,
      orientation: orientation,
      ally1: ally1,
      ally2: ally2,
      ally3: ally3,
      ally4: ally4,
      ally5: ally5,
      rival1: rival1,
      rival2: rival2,
      rival3: rival3,
      rival4: rival4,
      rival5: rival5,
      division: division,
    );
    await UniverseDatabase.instance.updateSuperstar(superstar);
  }

  Future addUniverseSuperstars() async {
    final superstar = UniverseSuperstars(
      name: name,
      brand: brand,
      orientation: orientation,
      ally1: ally1,
      ally2: ally2,
      ally3: ally3,
      ally4: ally4,
      ally5: ally5,
      rival1: rival1,
      rival2: rival2,
      rival3: rival3,
      rival4: rival4,
      rival5: rival5,
      division: division
    );
    await UniverseDatabase.instance.createSuperstar(superstar);
  }
}