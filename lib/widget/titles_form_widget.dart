
import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/brands.dart';
import 'package:wwe_universe/classes/superstars.dart';
import 'package:wwe_universe/classes/teams.dart';
import 'package:wwe_universe/widget/app_form_widgets.dart';
import 'package:wwe_universe/widget/superstar_picker.dart';
import 'package:wwe_universe/widget/superstar_avatar.dart';

class TitlesFormWidget extends StatelessWidget {
  final List<Superstars> listSuperstars;
  final List<Brands> listBrands;
  final List<Teams> listTeams;
  final Teams? championTeam;
  final ValueChanged<Teams?> onChangedChampionTeam;

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
    required this.listTeams,
    required this.championTeam,
    required this.onChangedChampionTeam,
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
                buildHolder1(context),
                if (tag == 1) ...[
                  const SizedBox(height: 16),
                  buildHolder2(context),
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

  Widget buildHolder1(BuildContext context) => _superstarField(
    context, label: 'Champion', selected: holder1, onChanged: onChangedHolder1,
  );

  Widget buildHolder2(BuildContext context) => _superstarField(
    context, label: 'Second champion', selected: holder2, onChanged: onChangedHolder2,
  );

  Widget buildChampionTeam() => DropdownButtonFormField<Teams?>(
    value: championTeam,
    isExpanded: true,
    dropdownColor: AppFormStyles.surface,
    style: const TextStyle(color: Colors.white),
    decoration: AppFormStyles.inputDecoration(
      label: 'Champion Team (optional)',
      icon: Icons.groups_outlined,
    ),
    items: [
      const DropdownMenuItem<Teams?>(value: null, child: Text('No Team linked')),
      ...listTeams.map((team) => DropdownMenuItem<Teams?>(
        value: team,
        child: Text(team.name, overflow: TextOverflow.ellipsis),
      )),
    ],
    onChanged: onChangedChampionTeam,
  );

  Widget _superstarField(BuildContext context, {required String label, required Superstars? selected, required ValueChanged<Superstars?> onChanged}) => FormField<Superstars>(
    initialValue: selected,
    validator: (value) => value == null ? 'Please select a Superstar' : null,
    builder: (state) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: selected == null ? const CircleAvatar(child: Icon(Icons.person_outline)) : SuperstarAvatar(superstar: selected, size: 48),
        title: Text(label, style: const TextStyle(color: Colors.white)),
        subtitle: Text(selected?.name ?? 'Select a Superstar', style: TextStyle(color: state.hasError ? Colors.redAccent : AppFormStyles.secondaryText)),
        trailing: const Icon(Icons.search),
        onTap: () async {
          final value = await pickOneSuperstar(context: context, available: listSuperstars, selectedId: selected?.id, title: label);
          if (value != null) { onChanged(value); state.didChange(value); }
        },
      ),
      if (state.hasError) Padding(padding: const EdgeInsets.only(left: 12), child: Text(state.errorText!, style: const TextStyle(color: Colors.redAccent, fontSize: 12))),
    ]),
  );

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