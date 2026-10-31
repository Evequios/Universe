
import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/superstars.dart';
import 'package:wwe_universe/widget/app_form_widgets.dart';

class TeamsFormWidget extends StatelessWidget {
  final List<Superstars> listSuperstars;

  final String name;

  final int? m1;
  final int? m2;
  final int? m3;
  final int? m4;
  final int? m5;

  final ValueChanged<String?> onChangedName;
  final ValueChanged<int?> onChangedM1;
  final ValueChanged<int?> onChangedM2;
  final ValueChanged<int?> onChangedM3;
  final ValueChanged<int?> onChangedM4;
  final ValueChanged<int?> onChangedM5;

  const TeamsFormWidget({
    super.key,
    required this.listSuperstars,
    required this.name,
    required this.m1,
    required this.m2,
    required this.m3,
    required this.m4,
    required this.m5,
    required this.onChangedName,
    required this.onChangedM1,
    required this.onChangedM2,
    required this.onChangedM3,
    required this.onChangedM4,
    required this.onChangedM5,
  });

  List<Superstars> availableMembers(int? currentMember) {
    final selectedIds = {
      m1,
      m2,
      m3,
      m4,
      m5,
    }..remove(null);

    selectedIds.remove(currentMember);

    return listSuperstars.where((superstar) {
      return superstar.id != null &&
          !selectedIds.contains(superstar.id);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppFormSection(
            title: 'Team information',
            child: TextFormField(
              initialValue: name,
              textCapitalization: TextCapitalization.words,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              decoration: AppFormStyles.inputDecoration(
                label: 'Team name',
                hint: 'Enter the team name',
                icon: Icons.groups_outlined,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'The team name cannot be empty';
                }
                return null;
              },
              onChanged: onChangedName,
            ),
          ),
          const SizedBox(height: 16),
          AppFormSection(
            title: 'Team members',
            child: Column(
              children: [
                buildMember(
                  number: 1,
                  selectedId: m1,
                  required: true,
                  onChanged: onChangedM1,
                ),
                const SizedBox(height: 16),
                buildMember(
                  number: 2,
                  selectedId: m2,
                  required: true,
                  onChanged: onChangedM2,
                ),
                const SizedBox(height: 16),
                buildMember(
                  number: 3,
                  selectedId: m3,
                  required: false,
                  onChanged: onChangedM3,
                ),
                const SizedBox(height: 16),
                buildMember(
                  number: 4,
                  selectedId: m4,
                  required: false,
                  onChanged: onChangedM4,
                ),
                const SizedBox(height: 16),
                buildMember(
                  number: 5,
                  selectedId: m5,
                  required: false,
                  onChanged: onChangedM5,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'A team must have at least two members. '
              'Additional members are optional.',
              style: TextStyle(
                color: AppFormStyles.secondaryText,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMember({
    required int number,
    required int? selectedId,
    required bool required,
    required ValueChanged<int?> onChanged,
  }) {
    final options = availableMembers(selectedId);

    return DropdownButtonFormField<int?>(
      key: ValueKey('member-$number-$selectedId'),
      initialValue: selectedId,
      isExpanded: true,
      dropdownColor: AppFormStyles.surface,
      style: const TextStyle(color: Colors.white),
      decoration: AppFormStyles.inputDecoration(
        label: 'Member $number${required ? ' *' : ' (optional)'}',
        icon: Icons.person_outline,
      ),
      items: [
        DropdownMenuItem<int?>(
          value: null,
          child: Text(
            required ? 'Select a Superstar' : 'No member',
            style: const TextStyle(
              color: AppFormStyles.secondaryText,
            ),
          ),
        ),
        ...options.map(
          (superstar) => DropdownMenuItem<int?>(
            value: superstar.id,
            child: Text(
              superstar.name,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
      validator: required
          ? (value) {
              if (value == null) {
                return 'Please select a Superstar';
              }
              return null;
            }
          : null,
      onChanged: onChanged,
    );
  }
}
