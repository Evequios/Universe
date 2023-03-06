import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/Universe/UniverseBrands.dart';
import 'package:wwe_universe/classes/Universe/UniverseSuperstars.dart';
import 'package:wwe_universe/classes/Universe/UniverseTitles.dart';
import 'package:wwe_universe/database.dart';
import 'package:wwe_universe/widget/Universe/UniverseTitlesFormWidget.dart';

class AddEditUniverseTitlesPage extends StatefulWidget {
  final UniverseTitles? title;
  final List<UniverseBrands>? listBrands;
  final List<UniverseSuperstars>? listSuperstars;

  const AddEditUniverseTitlesPage({
    Key? key,
    this.title,
    this.listBrands,
    this.listSuperstars
  }) : super(key: key);
  @override
  _AddEditUniverseTitlesPage createState() => _AddEditUniverseTitlesPage();
}

class _AddEditUniverseTitlesPage extends State<AddEditUniverseTitlesPage> {
  final _formKey = GlobalKey<FormState>();
  late List<UniverseSuperstars> listSuperstars = [];
  late List<UniverseBrands> listBrands = [];
  late String name;
  late int brand;
  late int tag;
  late int holder1;
  late int holder2;

  @override
  void initState() {
    super.initState();

    name = widget.title?.name ?? '';
    brand = widget.title?.brand ?? 0;
    tag = widget.title?.tag ?? 0;
    holder1 = widget.title?.holder1 ?? 0;
    holder2 = widget.title?.holder2 ?? 0;
    listBrands = widget.listBrands!;
    listSuperstars = widget.listSuperstars!;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          actions: [buildButton()],
        ),
        body: Form(
          key: _formKey,
          child: UniverseTitlesFormWidget(
            listSuperstars: listSuperstars,
            listBrands: listBrands,
            name: name,
            brand: brand,
            tag: tag,
            holder1 : holder1,
            holder2 : holder2,
            onChangedName: (name) => setState(() => this.name = name!),
            onChangedBrand: (brand) => setState(() => this.brand = brand!),
            onChangedTag: (tag) => setState(() => this.tag = tag!),
            onChangedHolder1: (holder1) => setState(() => this.holder1 = holder1!),
            onChangedHolder2: (holder2) => setState(() => this.holder2 = holder2!),
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
        onPressed: addOrUpdateUniverseTitles,
        child: const Text('Save'),
      ),
    );
  }

  void addOrUpdateUniverseTitles() async {
    final isValid = _formKey.currentState!.validate();

    if (isValid) {
      final isUpdating = widget.title != null;

      if (isUpdating) {
        await updateUniverseTitles();
      } else {
        await addUniverseTitles();
      }

      if(context.mounted) Navigator.of(context).pop();
    }
  }

  Future updateUniverseTitles() async {
    final title = widget.title!.copy(
      name: name,
      brand: brand,
      tag: tag,
      holder1: holder1,
      holder2: holder2,
    );

    await UniverseDatabase.instance.updateTitle(title);
  }

  Future addUniverseTitles() async {
    final title = UniverseTitles(
      name: name,
      brand: brand,
      tag: tag,
      holder1: holder1,
      holder2: holder2,
    );

    await UniverseDatabase.instance.createTitle(title);
  }
}