
import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/brands.dart';
import 'package:wwe_universe/widget/app_form_widgets.dart';
import 'package:wwe_universe/widget/entity_picker.dart';

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
  final String photoUrl;

  final ValueChanged<String?> onChangedName;
  final ValueChanged<int?> onChangedBrand;
  final ValueChanged<String?> onChangedOrientation;
  final ValueChanged<String?> onChangedPhotoUrl;

  const SuperstarsFormWidget({
    super.key,
    required this.listBrands,
    required this.name,
    required this.selectedBrandId,
    required this.orientation,
    required this.photoUrl,
    required this.onChangedName,
    required this.onChangedBrand,
    required this.onChangedOrientation,
    required this.onChangedPhotoUrl,
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
                FormField<int?>(
                  initialValue: brandExists ? selectedBrandId : null,
                  builder: (state) {
                    final selected = listBrands.where((b) => b.id == state.value).firstOrNull;
                    return ListTile(contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.branding_watermark_outlined),
                      title: const Text('Brand'),
                      subtitle: Text(selected?.name ?? 'No Brand', style: const TextStyle(color: AppFormStyles.secondaryText)),
                      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                        if (state.value != null) IconButton(onPressed: () { onChangedBrand(null); state.didChange(null); }, icon: const Icon(Icons.clear)),
                        const Icon(Icons.search),
                      ]),
                      onTap: () async {
                        final value = await pickOneEntity(context: context, available: listBrands, idOf: (v) => v.id, nameOf: (v) => v.name, selectedId: state.value, title: 'Select a Brand');
                        if (value != null) { onChangedBrand(value.id); state.didChange(value.id); }
                      });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppFormSection(
            title: 'Profile photo',
            child: TextFormField(
              initialValue: photoUrl,
              keyboardType: TextInputType.url,
              style: const TextStyle(color: Colors.white),
              decoration: AppFormStyles.inputDecoration(
                label: 'Photo URL',
                hint: 'https://…',
                icon: Icons.image_outlined,
              ),
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) return null;
                final uri = Uri.tryParse(text);
                if (uri == null || !uri.hasScheme ||
                    (uri.scheme != 'http' && uri.scheme != 'https') ||
                    uri.host.isEmpty) {
                  return 'Enter a valid http or https URL';
                }
                return null;
              },
              onChanged: onChangedPhotoUrl,
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

extension _BrandFirstOrNull<T> on Iterable<T> { T? get firstOrNull => isEmpty ? null : first; }
