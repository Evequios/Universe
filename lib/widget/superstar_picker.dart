import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/superstars.dart';
import 'package:wwe_universe/pages/Superstars/select_superstars_page.dart';

/// Opens the shared searchable Superstar picker and resolves selected IDs.
Future<List<Superstars>> pickSuperstars({
  required BuildContext context,
  required List<Superstars> available,
  Set<int> selectedIds = const {},
  int? maximumSelection,
  String title = 'Select Superstars',
}) async {
  final ids = await Navigator.of(context).push<List<int>>(
    MaterialPageRoute(builder: (_) => SelectSuperstarsPage(
      initiallySelected: selectedIds,
      allowedIds: available.where((s) => s.id != null).map((s) => s.id!).toSet(),
      maximumSelection: maximumSelection,
      title: title,
    )),
  );
  if (ids == null) return available.where((s) => s.id != null && selectedIds.contains(s.id)).toList();
  final byId = {for (final s in available) if (s.id != null) s.id!: s};
  return ids.where(byId.containsKey).map((id) => byId[id]!).toList();
}

Future<Superstars?> pickOneSuperstar({
  required BuildContext context,
  required List<Superstars> available,
  int? selectedId,
  String title = 'Select Superstar',
}) async {
  final selected = await pickSuperstars(
    context: context,
    available: available,
    selectedIds: selectedId == null ? {} : {selectedId},
    maximumSelection: 1,
    title: title,
  );
  return selected.isEmpty ? null : selected.first;
}
