import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/brands.dart';
import 'package:wwe_universe/database/brands_database_helper.dart';
import 'package:wwe_universe/classes/superstars.dart';
import 'package:wwe_universe/database/superstars_database_helper.dart';
import 'package:wwe_universe/widget/superstar_picker.dart';
import 'package:wwe_universe/widget/superstar_avatar.dart';
import 'package:wwe_universe/widget/app_form_widgets.dart';
import 'package:wwe_universe/widget/brands_form_widget.dart';

class AddEditBrandsPage extends StatefulWidget {
  final Brands? brand;

  const AddEditBrandsPage({
    super.key,
    this.brand,
  });
  @override
  AddEditBrandsPageState createState() => AddEditBrandsPageState();
}

class AddEditBrandsPageState extends State<AddEditBrandsPage> {
  final _formKey = GlobalKey<FormState>();
  late String name;
  List<Superstars> _allSuperstars = [];
  Set<int> _selectedIds = {};
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();

    name = widget.brand?.name ?? '';
    _loadMembers();
  }


  Future<void> _loadMembers() async {
    final all = await SuperstarsDatabaseHelper.readAllSuperstars();
    if (!mounted) return;
    setState(() {
      _allSuperstars = all;
      _selectedIds = all.where((s) => s.brand?.id == widget.brand?.id && widget.brand != null).map((s) => s.id!).toSet();
      _loading = false;
    });
  }

  Future<void> _selectMembers() async {
    final picked = await pickSuperstars(context: context, available: _allSuperstars, selectedIds: _selectedIds, title: 'Select Brand Superstars');
    setState(() => _selectedIds = picked.map((s) => s.id!).toSet());
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      actions: [buildButton()],
    ),
    body: Form(
      key: _formKey,
      child: ListView(padding: const EdgeInsets.all(16), children: [
        BrandsFormWidget(name: name, onChangedName: (value) => setState(() => name = value)),
        const SizedBox(height: 16),
        AppFormSection(title: 'Brand Superstars', children: [
          ListTile(contentPadding: EdgeInsets.zero, title: const Text('Superstars'), subtitle: Text('${_selectedIds.length} selected'), trailing: const Icon(Icons.search), onTap: _loading ? null : _selectMembers),
          if (_loading) const Center(child: CircularProgressIndicator()),
          ..._allSuperstars.where((s) => _selectedIds.contains(s.id)).map((s) => ListTile(dense: true, leading: SuperstarAvatar(superstar: s, size: 42), title: Text(s.name))),
        ]),
      ]),
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
        onPressed: _saving || _loading ? null : addOrUpdateBrand,
        child: const Text('Save'),
      ),
    );
  }

  Future<void> addOrUpdateBrand() async {
    if (!_formKey.currentState!.validate() || _saving) return;
    setState(() => _saving = true);
    try {
      final savedBrand = widget.brand == null
          ? await BrandsDatabaseHelper.createBrand(Brands(name: name.trim()))
          : widget.brand!.copy(name: name.trim());
      if (widget.brand != null) await BrandsDatabaseHelper.updateBrand(savedBrand);

      for (final superstar in _allSuperstars) {
        final shouldBelong = _selectedIds.contains(superstar.id);
        final currentlyBelongs = superstar.brand?.id == savedBrand.id;
        if (shouldBelong != currentlyBelongs) {
          await SuperstarsDatabaseHelper.updateSuperstar(
            superstar.copy(brand: savedBrand, clearBrand: !shouldBelong),
          );
        }
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Unable to save Brand: $error')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future updateBrand() async {
    final brand = widget.brand!.copy(
      name : name,
    );

    await BrandsDatabaseHelper.updateBrand(brand);
  }

  Future addBrand() async {
    final brand = Brands(
      name : name
    );

    await BrandsDatabaseHelper.createBrand(brand);
  }
}