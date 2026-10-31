
import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/brands.dart';
import 'package:wwe_universe/widget/app_form_widgets.dart';

const List<String> listOrientations = [
  'Face',
  'Tweener',
  'Heel',
];

class SuperstarsFormWidget extends StatelessWidget {
  final List<Brands> listBrands;

  final String name;
  final int? selectedBrandId;
  final String orientation;

  final ValueChanged<String?> onChangedName;
  final ValueChanged<int?> onChangedBrand;
  final ValueChanged<String?> onChangedOrientation;

  const SuperstarsFormWidget({
    super.key,
    required this.listBrands,
    required this.name,
    required this.selectedBrandId,
    required this.orientation,
    required this.onChangedName,
    required this.onChangedBrand,
    required this.onChangedOrientation,
  });

  @override
  Widget build(BuildContext context) {
    final brandExists = listBrands.any(
      (brand) => brand.id == selectedBrandId,
    );

    final orientations = [
      ...listOrientations,
      if (!listOrientations.contains(orientation)) orientation,
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppFormSection(
            title: 'Superstar information',
            child: Column(
              children: [
                TextFormField(
                  initialValue: name,
                  textCapitalization: TextCapitalization.words,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: AppFormStyles.inputDecoration(
                    label: 'Superstar name',
                    hint: 'Enter the Superstar name',
                    icon: Icons.person_outline,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'The name cannot be empty';
                    }
                    return null;
                  },
                  onChanged: onChangedName,
                ),
                const SizedBox(height: 18),
                DropdownButtonFormField<int?>(
                  initialValue: brandExists ? selectedBrandId : null,
                  isExpanded: true,
                  dropdownColor: AppFormStyles.surface,
                  style: const TextStyle(color: Colors.white),
                  decoration: AppFormStyles.inputDecoration(
                    label: 'Brand',
                    hint: 'Select a brand',
                    icon: Icons.branding_watermark_outlined,
                  ),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text(
                        'No brand',
                        style: TextStyle(
                          color: AppFormStyles.secondaryText,
                        ),
                      ),
                    ),
                    ...listBrands
                        .where((brand) => brand.id != null)
                        .map(
                          (brand) => DropdownMenuItem<int?>(
                            value: brand.id,
                            child: Text(
                              brand.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                  ],
                  onChanged: onChangedBrand,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppFormSection(
            title: 'In-ring alignment',
            child: DropdownButtonFormField<String>(
              initialValue: orientations.contains(orientation)
                  ? orientation
                  : orientations.first,
              isExpanded: true,
              dropdownColor: AppFormStyles.surface,
              style: const TextStyle(color: Colors.white),
              decoration: AppFormStyles.inputDecoration(
                label: 'Orientation',
                hint: 'Select an orientation',
                icon: Icons.sports_mma_outlined,
              ),
              items: orientations.map((value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select an orientation';
                }
                return null;
              },
              onChanged: onChangedOrientation,
            ),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'Face, Tweener and Heel describe the Superstar’s current alignment.',
              style: TextStyle(
                color: AppFormStyles.secondaryText,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
