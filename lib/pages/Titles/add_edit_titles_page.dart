
import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/brands.dart';
import 'package:wwe_universe/classes/superstars.dart';
import 'package:wwe_universe/classes/titles.dart';
import 'package:wwe_universe/database/brands_database_helper.dart';
import 'package:wwe_universe/database/superstars_database_helper.dart';
import 'package:wwe_universe/database/titles_database_helper.dart';
import 'package:wwe_universe/database/reings_database_helper.dart';
import 'package:wwe_universe/widget/wwe_date_dialog.dart';
import 'package:wwe_universe/widget/app_form_widgets.dart';
import 'package:wwe_universe/widget/titles_form_widget.dart';

class AddEditTitlesPage extends StatefulWidget {
  final Titles? title;

  // Optional for compatibility with existing callers.
  // If omitted, this page loads the lists itself.
  final List<Brands>? listBrands;
  final List<Superstars>? listSuperstars;

  const AddEditTitlesPage({
    super.key,
    this.title,
    this.listBrands,
    this.listSuperstars,
  });

  @override
  AddEditTitlesPageState createState() => AddEditTitlesPageState();
}

class AddEditTitlesPageState extends State<AddEditTitlesPage> {
  final _formKey = GlobalKey<FormState>();

  List<Brands> listBrands = [];
  List<Superstars> listSuperstars = [];

  String name = '';
  Brands? brand;
  int tag = 0;
  Superstars? holder1;
  Superstars? holder2;

  bool isLoading = true;
  bool isSaving = false;
  String? loadError;

  @override
  void initState() {
    super.initState();
    _loadFormData();
  }

  Future<void> _loadFormData() async {
    try {
      final loadedBrands = widget.listBrands ??
          await BrandsDatabaseHelper.readAllBrands();

      final loadedSuperstars = widget.listSuperstars ??
          await SuperstarsDatabaseHelper.readAllSuperstars();

      if (!mounted) return;

      setState(() {
        listBrands = loadedBrands;
        listSuperstars = loadedSuperstars;

        name = widget.title?.name ?? '';
        tag = widget.title?.tag ?? 0;

        brand = _findBrand(widget.title?.brand, loadedBrands);

        holder1 = _findSuperstar(
          widget.title?.holder1,
          loadedSuperstars,
        );

        holder2 = tag == 1
            ? _findSuperstar(
                widget.title?.holder2,
                loadedSuperstars,
              )
            : null;

        isLoading = false;
        loadError = null;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        loadError = 'Unable to load the title form.';
      });
    }
  }

  Brands? _findBrand(Brands? selected, List<Brands> items) {
    if (selected == null) return null;

    for (final item in items) {
      if (selected.id != null && item.id == selected.id) {
        return item;
      }

      if (selected.id == null && item.name == selected.name) {
        return item;
      }
    }

    return null;
  }

  Superstars? _findSuperstar(
    Superstars? selected,
    List<Superstars> items,
  ) {
    if (selected == null) return null;

    for (final item in items) {
      if (selected.id != null && item.id == selected.id) {
        return item;
      }

      if (selected.id == null && item.name == selected.name) {
        return item;
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppFormStyles.background,
      appBar: AppBar(
        backgroundColor: AppFormStyles.background,
        foregroundColor: Colors.white,
        title: Text(
          widget.title == null ? 'Add title' : 'Edit title',
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8,
              horizontal: 12,
            ),
            child: ElevatedButton.icon(
              onPressed: isLoading || isSaving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppFormStyles.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFF444444),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save_outlined, size: 18),
              label: const Text('Save'),
            ),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppFormStyles.primary,
        ),
      );
    }

    if (loadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.redAccent,
                size: 40,
              ),
              const SizedBox(height: 12),
              Text(
                loadError!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isLoading = true;
                    loadError = null;
                  });
                  _loadFormData();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Form(
      key: _formKey,
      child: TitlesFormWidget(
        listBrands: listBrands,
        listSuperstars: listSuperstars,
        name: name,
        brand: brand,
        tag: tag,
        holder1: holder1,
        holder2: holder2,
        onChangedName: (value) {
          name = value ?? '';
        },
        onChangedBrand: (value) {
          setState(() => brand = value);
        },
        onChangedTag: (value) {
          setState(() {
            tag = value ?? 0;

            // A Singles title must never retain a second champion.
            if (tag == 0) {
              holder2 = null;
            }
          });
        },
        onChangedHolder1: (value) {
          setState(() => holder1 = value);
        },
        onChangedHolder2: (value) {
          setState(() => holder2 = value);
        },
      ),
    );
  }

  Future<Map<String, int>?> _askWweDate() {
    return showDialog<Map<String, int>>(
      context: context,
      builder: (_) => const WweDateDialog(
        title: 'Date de début du règne',
      ),
    );
  }

  Future<void> _save() async {
    if (isSaving) return;
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final oldHolder1 = widget.title?.holder1?.id;
    final oldHolder2 = widget.title?.holder2?.id;
    final newHolder1 = holder1?.id;
    final newHolder2 = tag == 1 ? holder2?.id : null;
    final championChanged = oldHolder1 != newHolder1 || oldHolder2 != newHolder2;
    final assigningChampion = newHolder1 != null && championChanged;
    Map<String, int>? reignDate;
    if (assigningChampion) {
      reignDate = await _askWweDate();
      if (reignDate == null) return;
    }

    setState(() => isSaving = true);
    try {
      final title = Titles(
        name: name.trim(), brand: brand, tag: tag,
        holder1: holder1, holder2: tag == 1 ? holder2 : null,
      );

      int? savedTitleId;
      if (widget.title != null) {
        await TitlesDatabaseHelper.updateTitle(widget.title!.copy(
          name: title.name, tag: title.tag, brand: title.brand,
          holder1: title.holder1, holder2: title.holder2,
          clearBrand: title.brand == null,
          clearHolder2: tag == 0 || holder2 == null,
        ));
        savedTitleId = widget.title!.id;
      } else {
        final created = await TitlesDatabaseHelper.createTitle(title);
        savedTitleId = created.id;
      }

      if (assigningChampion && savedTitleId != null && reignDate != null) {
        await ReignsDatabaseHelper.recordManualChange(
          titleId: savedTitleId,
          year: reignDate['year']!, week: reignDate['week']!,
          dayOfWeek: reignDate['day']!,
          holder1Id: holder1!.id!, holder1Name: holder1!.name,
          holder2Id: tag == 1 ? holder2?.id : null,
          holder2Name: tag == 1 ? holder2?.name : null,
        );
      }

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossible d’enregistrer le titre : $error')),
      );
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }
}