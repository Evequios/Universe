
import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/brands.dart';
import 'package:wwe_universe/classes/superstars.dart';
import 'package:wwe_universe/database/brands_database_helper.dart';
import 'package:wwe_universe/database/superstars_database_helper.dart';
import 'package:wwe_universe/widget/app_form_widgets.dart';
import 'package:wwe_universe/widget/superstars_form_widget.dart';

class AddEditSuperstarsPage extends StatefulWidget {
  final Superstars? superstar;
  final List<Brands>? listBrands;
  final List<Superstars>? listSuperstars;

  const AddEditSuperstarsPage({
    super.key,
    this.superstar,
    this.listBrands,
    this.listSuperstars,
  });

  @override
  AddEditSuperstarsPageState createState() => AddEditSuperstarsPageState();
}

class AddEditSuperstarsPageState extends State<AddEditSuperstarsPage> {
  final _formKey = GlobalKey<FormState>();

  List<Brands> listBrands = [];

  String name = '';
  int? selectedBrandId;
  String orientation = 'Face';
  int? division;

  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    listBrands = widget.listBrands ?? [];

    name = widget.superstar?.name ?? '';
    selectedBrandId = widget.superstar?.brand?.id;
    orientation = widget.superstar?.orientation ?? 'Face';
    division = widget.superstar?.division;

    if (widget.listBrands == null) {
      loadBrands();
    }
  }

  Future<void> loadBrands() async {
    try {
      final brands = await BrandsDatabaseHelper.readAllBrands();

      if (!mounted) return;

      setState(() {
        listBrands = brands;
      });
    } catch (e) {
      debugPrint('Error loading brands: $e');
    }
  }

  Brands? get selectedBrand {
    if (selectedBrandId == null) return null;

    for (final brand in listBrands) {
      if (brand.id == selectedBrandId) {
        return brand;
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.superstar != null;

    return Scaffold(
      backgroundColor: AppFormStyles.background,
      appBar: AppBar(
        backgroundColor: AppFormStyles.background,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          isEditing ? 'EDIT SUPERSTAR' : 'CREATE SUPERSTAR',
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 1.4,
            fontSize: 16,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            child: FilledButton.icon(
              onPressed: isSaving ? null : saveSuperstar,
              icon: isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save_outlined),
              label: const Text('SAVE'),
              style: FilledButton.styleFrom(
                backgroundColor: AppFormStyles.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SuperstarsFormWidget(
          listBrands: listBrands,
          name: name,
          selectedBrandId: selectedBrandId,
          orientation: orientation,
          onChangedName: (value) {
            name = value ?? '';
          },
          onChangedBrand: (value) {
            setState(() => selectedBrandId = value);
          },
          onChangedOrientation: (value) {
            if (value != null) {
              setState(() => orientation = value);
            }
          },
        ),
      ),
    );
  }

  Future<void> saveSuperstar() async {
    if (isSaving) return;

    if (!_formKey.currentState!.validate()) return;

    setState(() => isSaving = true);

    try {
      final superstar = Superstars(
        id: widget.superstar?.id,
        name: name.trim(),
        brand: selectedBrand,
        orientation: orientation,
        // Division is not currently editable in the form.
        // Preserve its existing value when updating.
        division: division,
      );

      if (widget.superstar == null) {
        await SuperstarsDatabaseHelper.createSuperstar(superstar);
      } else {
        await SuperstarsDatabaseHelper.updateSuperstar(superstar);
      }

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to save Superstar: $e'),
        ),
      );

      setState(() => isSaving = false);
    }
  }
}
