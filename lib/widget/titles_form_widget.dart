
import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/brands.dart';
import 'package:wwe_universe/classes/superstars.dart';
import 'package:wwe_universe/widget/app_form_widgets.dart';

class TitlesFormWidget extends StatelessWidget {
  final List<Superstars> listSuperstars;
  final List<Brands> listBrands;

  final String name;
  final Brands? brand;
  final int tag;
  final Superstars? holder1;
  final Superstars? holder2;

  final ValueChanged<String?> onChangedName;
  final ValueChanged<Brands?> onChangedBrand;
  final ValueChanged<int?> onChangedTag;
  final ValueChanged<Superstars?> onChangedHolder1;
  final ValueChanged<Superstars?> onChangedHolder2;

  const TitlesFormWidget({
    super.key,
    required this.listBrands,
    required this.listSuperstars,
    required this.name,
    required this.brand,
    required this.tag,
    required this.holder1,
    required this.holder2,
    required this.onChangedName,
    required this.onChangedBrand,
    required this.onChangedTag,
    required this.onChangedHolder1,
    required this.onChangedHolder2,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppFormSection(
            title: 'Title information',
            child: Column(
              children: [
                buildName(),
                const SizedBox(height: 16),
                buildBrand(),
                const SizedBox(height: 16),
                buildTag(),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppFormSection(
            title: tag == 1 ? 'Champions' : 'Champion',
            child: Column(
              children: [
                buildHolder1(),
                if (tag == 1) ...[
                  const SizedBox(height: 16),
                  buildHolder2(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildName() {
    return TextFormField(
      initialValue: name,
      textCapitalization: TextCapitalization.words,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
      ),
      decoration: AppFormStyles.inputDecoration(
        label: 'Title name',
        hint: 'Enter the title name',
        icon: Icons.emoji_events_outlined,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'The title name cannot be empty';
        }
        return null;
      },
      onChanged: onChangedName,
    );
  }

  
  Widget buildBrand() {
    final selectedBrand = _findBrandInList(brand);

    return DropdownButtonFormField<Brands?>(
      initialValue: selectedBrand,
      isExpanded: true,
      dropdownColor: AppFormStyles.surface,
      style: const TextStyle(color: Colors.white),
      decoration: AppFormStyles.inputDecoration(
        label: 'Brand (optional)',
        icon: Icons.branding_watermark_outlined,
      ),
      items: [
        const DropdownMenuItem<Brands?>(
          value: null,
          child: Text('None'),
        ),
        ...listBrands.map(
          (item) => DropdownMenuItem<Brands?>(
            value: item,
            child: Text(
              item.name,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
      onChanged: onChangedBrand,
    );
  }


  Widget buildTag() {
    return DropdownButtonFormField<int>(
      initialValue: tag,
      isExpanded: true,
      dropdownColor: AppFormStyles.surface,
      style: const TextStyle(color: Colors.white),
      decoration: AppFormStyles.inputDecoration(
        label: 'Title type',
        icon: Icons.groups_outlined,
      ),
      items: const [
        DropdownMenuItem<int>(
          value: 0,
          child: Text('Singles'),
        ),
        DropdownMenuItem<int>(
          value: 1,
          child: Text('Tag Team'),
        ),
      ],
      onChanged: onChangedTag,
    );
  }

  Widget buildHolder1() {
    return DropdownButtonFormField<Superstars>(
      initialValue: _findSuperstarInList(holder1),
      isExpanded: true,
      dropdownColor: AppFormStyles.surface,
      style: const TextStyle(color: Colors.white),
      decoration: AppFormStyles.inputDecoration(
        label: 'Champion',
        icon: Icons.person_outline,
      ),
      items: listSuperstars.map((item) {
        return DropdownMenuItem<Superstars>(
          value: item,
          child: Text(
            item.name,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: onChangedHolder1,
    );
  }

  Widget buildHolder2() {
    return DropdownButtonFormField<Superstars>(
      initialValue: _findSuperstarInList(holder2),
      isExpanded: true,
      dropdownColor: AppFormStyles.surface,
      style: const TextStyle(color: Colors.white),
      decoration: AppFormStyles.inputDecoration(
        label: 'Second champion',
        icon: Icons.person_outline,
      ),
      items: listSuperstars.map((item) {
        return DropdownMenuItem<Superstars>(
          value: item,
          child: Text(
            item.name,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: onChangedHolder2,
    );
  }

  Brands? _findBrandInList(Brands? selected) {
    if (selected == null) return null;

    for (final item in listBrands) {
      if (selected.id != null && item.id == selected.id) {
        return item;
      }

      if (selected.id == null && item.name == selected.name) {
        return item;
      }
    }

    return null;
  }

  Superstars? _findSuperstarInList(Superstars? selected) {
    if (selected == null) return null;

    for (final item in listSuperstars) {
      if (selected.id != null && item.id == selected.id) {
        return item;
      }

      if (selected.id == null && item.name == selected.name) {
        return item;
      }
    }

    return null;
  }
}