import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/brands.dart';
import 'package:wwe_universe/classes/superstars.dart';
import 'package:wwe_universe/classes/titles.dart';
import 'package:wwe_universe/database/titles_database_helper.dart';
import 'package:wwe_universe/widget/titles_form_widget.dart';

class AddEditTitlesPage extends StatefulWidget {
  final Titles? title;
  final List<Brands>? listBrands;
  final List<Superstars>? listSuperstars;

  const AddEditTitlesPage({
    Key? key,
    this.title,
    this.listBrands,
    this.listSuperstars
  }) : super(key: key);
  @override
  _AddEditTitlesPage createState() => _AddEditTitlesPage();
}

class _AddEditTitlesPage extends State<AddEditTitlesPage> {
  final _formKey = GlobalKey<FormState>();
  late List<Superstars> listSuperstars = [];
  late List<Brands> listBrands = [];
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
          child: TitlesFormWidget(
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

    await TitlesDatabaseHelper.updateTitle(title);
  }

  Future addUniverseTitles() async {
    final title = Titles(
      name: name,
      brand: brand,
      tag: tag,
      holder1: holder1,
      holder2: holder2,
    );

    await TitlesDatabaseHelper.createTitle(title);
  }
}