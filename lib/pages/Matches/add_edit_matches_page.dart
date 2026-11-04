import 'package:flutter/material.dart';

import 'package:wwe_universe/classes/match_formats.dart';
import 'package:wwe_universe/classes/match_participants.dart';
import 'package:wwe_universe/classes/match_record.dart';
import 'package:wwe_universe/classes/match_sides.dart';
import 'package:wwe_universe/classes/match_types.dart';
import 'package:wwe_universe/classes/show.dart';
import 'package:wwe_universe/classes/superstars.dart';
import 'package:wwe_universe/classes/teams.dart';
import 'package:wwe_universe/classes/titles.dart';
import 'package:wwe_universe/database/matches_database_helper.dart';
import 'package:wwe_universe/database/match_formats_database_helper.dart';
import 'package:wwe_universe/database/match_type_formats_database_helper.dart';
import 'package:wwe_universe/database/match_types_database_helper.dart';
import 'package:wwe_universe/database/superstars_database_helper.dart';
import 'package:wwe_universe/database/teams_database_helper.dart';
import 'package:wwe_universe/database/titles_database_helper.dart';
import 'package:wwe_universe/widget/app_form_widgets.dart';
import 'package:wwe_universe/widget/entity_picker.dart';
import 'package:wwe_universe/pages/Superstars/select_superstars_page.dart';

class AddEditMatchesPage extends StatefulWidget {
  final MatchRecord? match;
  final Show show;

  const AddEditMatchesPage({super.key, this.match, required this.show});

  @override
  State<AddEditMatchesPage> createState() => _AddEditMatchesPageState();
}

class _ParticipantDraft {
  final int? superstarId;
  final String name;

  const _ParticipantDraft({required this.name, this.superstarId});

  factory _ParticipantDraft.fromSuperstar(Superstars value) =>
      _ParticipantDraft(name: value.name, superstarId: value.id);

  factory _ParticipantDraft.fromHistorical(MatchParticipants value) =>
      _ParticipantDraft(name: value.superstarName, superstarId: value.superstarId);
}

class _SideDraft {
  String name;
  int? teamId;
  final List<_ParticipantDraft> participants;

  _SideDraft({required this.name, this.teamId, List<_ParticipantDraft>? participants})
      : participants = participants ?? [];
}

class _AddEditMatchesPageState extends State<AddEditMatchesPage> {
  final _formKey = GlobalKey<FormState>();

  List<MatchTypes> types = [];
  List<MatchFormats> formats = [];
  List<Superstars> superstars = [];
  List<Teams> teams = [];
  List<Titles> titles = [];

  MatchTypes? selectedType;
  MatchFormats? selectedFormat;
  Titles? selectedTitle;

  final List<_SideDraft> sides = [];
  final List<_ParticipantDraft> specialParticipants = [];

  String resultStatus = MatchResultStatus.pending;
  int? winnerSideOrder;
  int? winnerSuperstarId;
  String? winnerName;
  bool titleChange = false;
  bool loading = true;
  bool saving = false;

  bool get isEditing => widget.match != null;
  bool get usesSides => selectedFormat?.usesSides ?? true;
  bool get isIndividualFormat => selectedFormat?.category == 'individual';
  List<_ParticipantDraft> get allDraftParticipants => [
        ...sides.expand((side) => side.participants),
        ...specialParticipants,
      ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final values = await Future.wait([
        MatchTypesDatabaseHelper.readAll(),
        SuperstarsDatabaseHelper.readAllSuperstars(),
        TeamsDatabaseHelper.readAllTeams(),
        TitlesDatabaseHelper.readAllTitles(),
      ]);
      types = values[0] as List<MatchTypes>;
      superstars = values[1] as List<Superstars>;
      teams = values[2] as List<Teams>;
      titles = values[3] as List<Titles>;

      final existing = widget.match;
      if (existing != null) {
        selectedType = types.where((e) => e.id == existing.matchType?.id).firstOrNull;
        selectedTitle = titles.where((e) => e.id == existing.title?.id).firstOrNull;
      } else if (types.isNotEmpty) {
        selectedType = types.first;
      }

      if (selectedType?.id != null) {
        formats = await MatchTypeFormatsDatabaseHelper.readFormatsForType(selectedType!.id!);
      } else {
        formats = await MatchFormatsDatabaseHelper.readAllFormats();
      }

      if (existing != null) {
        // Reconstruit le format historique depuis le snapshot du combat.
        selectedFormat = MatchFormats(
          id: existing.format?.id,
          name: existing.formatName,
          description: existing.format?.description,
          category: existing.snapshotCategory,
          participantCount: existing.snapshotParticipantCount,
          sideCount: existing.snapshotSideCount,
          participantsPerSide: List<int>.from(
            existing.snapshotParticipantsPerSide,
          ),
          isActive: existing.format?.isActive ?? true,
        );

        // Remplace éventuellement la version actuelle du catalogue
        // par la version historique utilisée par ce combat.
        formats = formats
            .where((e) => e.id != selectedFormat!.id)
            .toList();

        formats.add(selectedFormat!);
        resultStatus = existing.resultStatus;
        winnerSideOrder = existing.winnerSideOrder;
        winnerSuperstarId = existing.winnerSuperstarId;
        winnerName = existing.winnerName;
        titleChange = existing.titleChange;
        for (final side in existing.sides) {
          sides.add(_SideDraft(
            name: side.name,
            teamId: side.teamId,
            participants: side.participants.map(_ParticipantDraft.fromHistorical).toList(),
          ));
        }
        specialParticipants.addAll(existing.specialParticipants.map(_ParticipantDraft.fromHistorical));
      } else if (formats.isNotEmpty) {
        selectedFormat = formats.first;
        _initializeStructure(selectedFormat!);
      }

      if (mounted) setState(() => loading = false);
    } catch (error) {
      if (!mounted) return;
      setState(() => loading = false);
      _showMessage('Unable to load data: $error');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<bool> _confirmStructureReset() async {
    if (allDraftParticipants.isEmpty) return true;
    return await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            backgroundColor: AppFormStyles.surface,
            title: const Text('Edit match structure?', style: TextStyle(color: Colors.white)),
            content: const Text(
              'Changing the match type or format will reset the selected sides and participants. Continue?',
              style: TextStyle(color: AppFormStyles.secondaryText),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
              TextButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Continue')),
            ],
          ),
        ) ??
        false;
  }

  void _clearStructure() {
    sides.clear();
    specialParticipants.clear();
    winnerSideOrder = null;
    winnerSuperstarId = null;
    winnerName = null;
    if (resultStatus == MatchResultStatus.winner) resultStatus = MatchResultStatus.pending;
  }

  void _initializeStructure(MatchFormats format) {
    _clearStructure();
    if (format.usesSides) {
      for (var i = 0; i < format.sideCount; i++) {
        sides.add(_SideDraft(
          name: format.category == 'individual' ? 'Participant ${i + 1}' : 'Side ${i + 1}',
        ));
      }
    }
  }

  Future<void> _onTypeChanged(MatchTypes? value) async {
    if (value == null || value.id == null || value.id == selectedType?.id) return;
    if (!await _confirmStructureReset()) return;
    try {
      final compatible = await MatchTypeFormatsDatabaseHelper.readFormatsForType(value.id!);
      if (!mounted) return;
      setState(() {
        selectedType = value;
        formats = compatible;
        selectedFormat = null;
        _clearStructure();
      });
    } catch (error) {
      _showMessage('Unable to load compatible formats: $error');
    }
  }

  Future<void> _onFormatChanged(MatchFormats? value) async {
    if (value == null || value.id == selectedFormat?.id) return;
    if (!await _confirmStructureReset()) return;
    setState(() {
      selectedFormat = value;
      _initializeStructure(value);
    });
  }

  int _expectedForSide(int index) {
    final values = selectedFormat?.participantsPerSide ?? const <int>[];
    return index < values.length ? values[index] : 1;
  }

  Set<int> _usedSuperstarIds({int? exceptSide, bool includeSpecial = true}) {
    final result = <int>{};
    for (var i = 0; i < sides.length; i++) {
      if (i == exceptSide) continue;
      for (final p in sides[i].participants) {
        if (p.superstarId != null) result.add(p.superstarId!);
      }
    }
    if (includeSpecial) {
      for (final p in specialParticipants) {
        if (p.superstarId != null) result.add(p.superstarId!);
      }
    }
    return result;
  }

  Future<List<_ParticipantDraft>?> _pickParticipants({
    required List<_ParticipantDraft> current,
    required int maximum,
    required Set<int> usedElsewhere,
    Set<int>? allowedIds,
  }) async {
    final selected = current.where((p) => p.superstarId != null).map((p) => p.superstarId!).toSet();
    final historicalCount = current.where((p) => p.superstarId == null).length;
    final selectableMaximum = (maximum - historicalCount).clamp(0, maximum);
    final result = await Navigator.of(context).push<List<int>>(
      MaterialPageRoute(
        builder: (_) => SelectSuperstarsPage(
          title: 'Select Match Participants',
          initiallySelected: selected,
          excludedIds: usedElsewhere,
          allowedIds: allowedIds,
          maximumSelection: selectableMaximum,
        ),
      ),
    );
    if (result == null) return null;
    final historical = current.where((p) => p.superstarId == null).toList();
    return [
      ...historical,
      ...result.map((id) => _ParticipantDraft.fromSuperstar(superstars.firstWhere((s) => s.id == id))),
    ];
  }


  Set<int>? _teamMemberIds(int? teamId) {
    if (teamId == null) return null;
    final team = teams.where((item) => item.id == teamId).firstOrNull;
    if (team == null) return null;
    return [team.member1, team.member2, team.member3, team.member4, team.member5]
        .where((member) => member != null && member.id != null)
        .map((member) => member!.id!)
        .toSet();
  }

  Future<void> _editSideParticipants(int index) async {
    final chosen = await _pickParticipants(
      current: sides[index].participants,
      maximum: _expectedForSide(index),
      usedElsewhere: _usedSuperstarIds(exceptSide: index),
      allowedIds: _teamMemberIds(sides[index].teamId),
    );
    if (chosen == null || !mounted) return;
    setState(() {
      sides[index].participants
        ..clear()
        ..addAll(chosen);
      _resetWinnerIfInvalid();
    });
  }

  Future<void> _editSpecialParticipants() async {
    final chosen = await _pickParticipants(
      current: specialParticipants,
      maximum: selectedFormat?.participantCount ?? 1,
      usedElsewhere: _usedSuperstarIds(includeSpecial: false),
    );
    if (chosen == null || !mounted) return;
    setState(() {
      specialParticipants
        ..clear()
        ..addAll(chosen);
      _resetWinnerIfInvalid();
    });
  }

  void _resetWinnerIfInvalid() {
    if (resultStatus != MatchResultStatus.winner || winnerSideOrder != null) return;
    final found = allDraftParticipants.any((p) =>
        winnerSuperstarId != null ? p.superstarId == winnerSuperstarId && p.name == winnerName : p.name == winnerName);
    if (!found) {
      winnerSuperstarId = null;
      winnerName = null;
      resultStatus = MatchResultStatus.pending;
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final format = selectedFormat;
    final type = selectedType;
    if (type == null) {
      _showMessage('Select a match type.');
      return;
    }
    if (format == null) {
      _showMessage('Select a compatible format.');
      return;
    }

    if (format.usesSides) {
      if (sides.length != format.sideCount) {
        _showMessage('This format requires ${format.sideCount} sides.');
        return;
      }
      for (var i = 0; i < sides.length; i++) {
        if (sides[i].participants.length != _expectedForSide(i)) {
          _showMessage('Side ${i + 1} must contain ${_expectedForSide(i)} participant(s).');
          return;
        }
        if (sides[i].name.trim().isEmpty) {
          _showMessage('Each side must have a name.');
          return;
        }
      }
    } else if (specialParticipants.length != format.participantCount) {
      _showMessage('This format requires exactly ${format.participantCount} participants.');
      return;
    }

    if (allDraftParticipants.isEmpty) {
      _showMessage('Add at least one participant.');
      return;
    }

    if (resultStatus == MatchResultStatus.winner) {
      final sideWinnerAllowed = format.usesSides && !isIndividualFormat;
      final hasSideWinner = winnerSideOrder != null;
      final hasIndividualWinner = winnerName != null && winnerName!.trim().isNotEmpty;
      if (sideWinnerAllowed && !hasSideWinner) {
        _showMessage('Select the winning side.');
        return;
      }
      if (!sideWinnerAllowed && !hasIndividualWinner) {
        _showMessage('Select the individual winner.');
        return;
      }
      if (hasIndividualWinner) {
        final winningSide = winnerSideOrder == null ? null : sides.firstWhere((side) => sides.indexOf(side) == winnerSideOrder);
        final eligible = winningSide == null ? allDraftParticipants : winningSide.participants;
        if (!eligible.any((p) => winnerSuperstarId != null ? p.superstarId == winnerSuperstarId && p.name == winnerName : p.name == winnerName)) {
          _showMessage('The individual winner must belong to the winning side.');
          return;
        }
      }
    }

    setState(() => saving = true);
    try {
      final matchSides = <MatchSides>[];
      for (var i = 0; i < sides.length; i++) {
        matchSides.add(MatchSides(
          matchId: widget.match?.id,
          sideOrder: i,
          name: sides[i].name.trim(),
          teamId: sides[i].teamId,
          participants: sides[i].participants.asMap().entries.map((entry) => MatchParticipants(
            matchId: widget.match?.id,
            sideId: null,
            position: entry.key,
            superstarId: entry.value.superstarId,
            superstarName: entry.value.name,
          )).toList(),
        ));
      }
      final matchSpecialParticipants = specialParticipants.asMap().entries.map((entry) => MatchParticipants(
        matchId: widget.match?.id,
        sideId: null,
        position: entry.key,
        superstarId: entry.value.superstarId,
        superstarName: entry.value.name,
      )).toList();

      final record = MatchRecord(
        id: widget.match?.id,
        format: format,
        formatName: format.name,
        formatCategory: format.category,
        formatParticipantCount: format.participantCount,
        formatSideCount: format.sideCount,
        formatParticipantsPerSide: List<int>.from(
          format.participantsPerSide,
        ),
        matchType: type,
        matchTypeName: type.name,
        sides: matchSides,
        specialParticipants: matchSpecialParticipants,
        resultStatus: resultStatus,
        winnerSideOrder: winnerSideOrder,
        winnerSuperstarId: winnerSuperstarId,
        winnerName: resultStatus == MatchResultStatus.winner ? winnerName : null,
        matchOrder: widget.match?.matchOrder ?? 0,
        show: widget.show,
        title: selectedTitle,
        titleChange: titleChange,
      );

      if (isEditing) {
        await MatchesDatabaseHelper.updateMatches(record);
      } else {
        await MatchesDatabaseHelper.createMatch(record);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      _showMessage('Unable to save match: $error');
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppFormStyles.background,
        appBar: AppBar(
          backgroundColor: AppFormStyles.background,
          foregroundColor: Colors.white,
          elevation: 0,
          title: Text(isEditing ? 'EDIT MATCH' : 'NEW MATCH', style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2)),
        ),
        body: loading
            ? const Center(child: CircularProgressIndicator(color: AppFormStyles.primary))
            : Form(
                key: _formKey,
                child: ListView(padding: const EdgeInsets.all(16), children: [
                  _buildGeneralSection(),
                  const SizedBox(height: 20),
                  _buildParticipantsSection(),
                  const SizedBox(height: 20),
                  _buildResultSection(),
                  const SizedBox(height: 20),
                  const SizedBox(height: 28),
                  _buildSaveButton(),
                  const SizedBox(height: 32),
                ]),
              ),
      );

  Widget _buildGeneralSection() => AppFormSection(title: 'MATCH INFORMATION', children: [
        _dropdown<MatchTypes>(
          label: 'Match Type', value: selectedType, items: types, itemLabel: (e) => e.name,
          onChanged: _onTypeChanged,
        ),
        const SizedBox(height: 14),
        _dropdown<MatchFormats>(
          label: 'Format', value: selectedFormat, items: formats, itemLabel: (e) => e.name,
          onChanged: _onFormatChanged,
        ),
        if (selectedType != null && formats.isEmpty) ...[
          const SizedBox(height: 8),
          const Text('No compatible format is configured for this type.', style: TextStyle(color: Colors.orangeAccent, fontSize: 12)),
        ],
        const SizedBox(height: 14),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.emoji_events_outlined, color: AppFormStyles.primary),
          title: const Text('Title (optional)'),
          subtitle: Text(selectedTitle?.name ?? 'No Title selected', style: const TextStyle(color: AppFormStyles.secondaryText)),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            if (selectedTitle != null) IconButton(onPressed: () => setState(() { selectedTitle = null; titleChange = false; }), icon: const Icon(Icons.clear)),
            const Icon(Icons.search),
          ]),
          onTap: () async {
            final value = await pickOneEntity<Titles>(context: context, available: titles,
              idOf: (item) => item.id, nameOf: (item) => item.name,
              selectedId: selectedTitle?.id, title: 'Select a Title');
            if (value != null && mounted) setState(() => selectedTitle = value);
          },
        ),
      ]);

  Widget _buildParticipantsSection() {
    final format = selectedFormat;
    return AppFormSection(title: 'PARTICIPANTS & SIDES', children: [
      if (format == null)
        const Text('Choose a format first to define the match structure.', style: TextStyle(color: AppFormStyles.secondaryText))
      else if (format.usesSides) ...[
        Text(
          '${format.sideCount} side(s) • ${format.participantCount} participants in total',
          style: const TextStyle(color: AppFormStyles.secondaryText, fontSize: 12),
        ),
        const SizedBox(height: 12),
        ...List.generate(sides.length, _buildSideCard),
      ] else ...[
        Text(
          'Special format • ${format.participantCount} participants • no sides',
          style: const TextStyle(color: AppFormStyles.secondaryText, fontSize: 12),
        ),
        const SizedBox(height: 12),
        if (specialParticipants.isNotEmpty)
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: true,
            itemCount: specialParticipants.length,
            onReorder: (oldIndex, newIndex) => setState(() {
              if (newIndex > oldIndex) newIndex--;
              final item = specialParticipants.removeAt(oldIndex);
              specialParticipants.insert(newIndex, item);
            }),
            itemBuilder: (context, index) {
              final participant = specialParticipants[index];
              return KeyedSubtree(
                key: ValueKey('special-${participant.superstarId ?? participant.name}'),
                child: _participantTile(participant, () => setState(() {
                  specialParticipants.remove(participant);
                  _resetWinnerIfInvalid();
                })),
              );
            },
          ),
        OutlinedButton.icon(
          onPressed: () => _editSpecialParticipants(),
          icon: const Icon(Icons.person_add_alt_1),
          label: Text('SELECT PARTICIPANTS (${specialParticipants.length}/${format.participantCount})'),
          style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: AppFormStyles.border)),
        ),
      ],
    ]);
  }

  Widget _buildSideCard(int index) {
    final side = sides[index];
    final expected = _expectedForSide(index);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppFormStyles.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppFormStyles.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(isIndividualFormat ? 'PARTICIPANT ${index + 1}' : 'SIDE ${index + 1}', style: const TextStyle(color: AppFormStyles.primary, fontWeight: FontWeight.w900, letterSpacing: 1)),
        if (!isIndividualFormat) ...[
          const SizedBox(height: 12),
          TextFormField(
            initialValue: side.name,
            style: const TextStyle(color: Colors.white),
            decoration: AppFormStyles.inputDecoration(label: 'Side name', hint: 'Ex. The Bloodline'),
            onChanged: (value) => side.name = value,
            validator: (value) => value == null || value.trim().isEmpty ? 'Name is required' : null,
          ),
          const SizedBox(height: 12),
          Builder(builder: (context) {
            final selectedTeam = teams.where((e) => e.id == side.teamId).firstOrNull;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.groups_outlined, color: AppFormStyles.primary),
              title: const Text('Official Tag Team (optional)'),
              subtitle: Text(selectedTeam?.name ?? 'No Team linked', style: const TextStyle(color: AppFormStyles.secondaryText)),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                if (selectedTeam != null) IconButton(onPressed: () => setState(() { side.teamId = null; }), icon: const Icon(Icons.clear)),
                const Icon(Icons.search),
              ]),
              onTap: () async {
                final team = await pickOneEntity<Teams>(context: context, available: teams,
                  idOf: (item) => item.id, nameOf: (item) => item.name,
                  selectedId: side.teamId, title: 'Select a Team');
                if (team == null || !mounted) return;
                setState(() {
                  side.teamId = team.id;
                  side.name = team.name;
                  final allowed = _teamMemberIds(team.id)!;
                  side.participants.removeWhere((p) => p.superstarId != null && !allowed.contains(p.superstarId));
                  _resetWinnerIfInvalid();
                });
              },
            );
          }),
        ],
        const SizedBox(height: 10),
        Text('Participants (${side.participants.length}/$expected)', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        if (side.participants.isEmpty)
          const Text('No participant selected.', style: TextStyle(color: AppFormStyles.secondaryText))
        else
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: true,
            itemCount: side.participants.length,
            onReorder: (oldIndex, newIndex) => setState(() {
              if (newIndex > oldIndex) newIndex--;
              final item = side.participants.removeAt(oldIndex);
              side.participants.insert(newIndex, item);
            }),
            itemBuilder: (context, participantIndex) {
              final participant = side.participants[participantIndex];
              return KeyedSubtree(
                key: ValueKey('side-$index-${participant.superstarId ?? participant.name}'),
                child: _participantTile(participant, () => setState(() {
                  side.participants.remove(participant);
                  _resetWinnerIfInvalid();
                })),
              );
            },
          ),
        OutlinedButton.icon(
          onPressed: side.participants.length >= expected ? null : () => _editSideParticipants(index),
          icon: const Icon(Icons.person_add_alt_1),
          label: const Text('SELECT SUPERSTARS'),
          style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: AppFormStyles.border)),
        ),
      ]),
    );
  }

  Widget _participantTile(_ParticipantDraft participant, VoidCallback onRemove) => ListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.person, color: AppFormStyles.primary),
        title: Text(participant.name, style: const TextStyle(color: Colors.white)),
        subtitle: participant.superstarId == null ? const Text('Historical participant', style: TextStyle(color: AppFormStyles.secondaryText, fontSize: 11)) : null,
        trailing: IconButton(onPressed: onRemove, icon: const Icon(Icons.close, color: Colors.redAccent)),
      );

  Widget _buildResultSection() {
    final canChooseSideWinner = usesSides && !isIndividualFormat;

    final winnerParticipant = allDraftParticipants.where((p) {
      if (winnerSuperstarId != null) {
        return p.superstarId == winnerSuperstarId &&
            p.name == winnerName;
      }
      return p.name == winnerName;
    }).firstOrNull;

    return AppFormSection(
      title: 'MATCH RESULT',
      children: [
        _dropdown<String>(
          label: 'Statut',
          value: resultStatus,
          items: const [
            MatchResultStatus.pending,
            MatchResultStatus.winner,
            MatchResultStatus.draw,
            MatchResultStatus.noContest,
          ],
          itemLabel: (value) {
            if (value == MatchResultStatus.pending) {
              return 'Pending';
            }
            if (value == MatchResultStatus.winner) {
              return 'Winner selected';
            }
            if (value == MatchResultStatus.draw) {
              return 'Draw';
            }
            if (value == MatchResultStatus.noContest) {
              return 'No Contest';
            }
            return value;
          },
          onChanged: (value) {
            setState(() {
              resultStatus = value ?? MatchResultStatus.pending;
              winnerSideOrder = null;
              winnerSuperstarId = null;
              winnerName = null;
              if (resultStatus != MatchResultStatus.winner) titleChange = false;
            });
          },
        ),
        if (resultStatus == MatchResultStatus.winner && selectedTitle != null) ...[
          const SizedBox(height: 10),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text('Title Change', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            subtitle: const Text('The winner becomes the new champion.', style: TextStyle(color: AppFormStyles.secondaryText, fontSize: 12)),
            value: titleChange,
            activeColor: AppFormStyles.primary,
            onChanged: (value) => setState(() => titleChange = value),
          ),
        ],
        if (resultStatus == MatchResultStatus.winner) ...[
          const SizedBox(height: 14),
          if (canChooseSideWinner)
            _dropdown<int>(
              label: 'Winning Side',
              value: winnerSideOrder,
              items: List.generate(sides.length, (i) => i),
              itemLabel: (i) => sides[i].name,
              allowNull: true,
              onChanged: (value) {
                setState(() {
                  winnerSideOrder = value;
                  winnerSuperstarId = null;
                  winnerName = null;
                });
              },
            ),
          if (canChooseSideWinner)
            const SizedBox(height: 14),
          _dropdown<_ParticipantDraft>(
            label: canChooseSideWinner ? 'Final pin / submission (optional)' : 'Individual winner',
            value: winnerParticipant,
            items: winnerSideOrder == null ? allDraftParticipants : sides[winnerSideOrder!].participants,
            itemLabel: (p) => p.name,
            allowNull: true,
            onChanged: (value) {
              setState(() {
                winnerSuperstarId = value?.superstarId;
                winnerName = value?.name;
              });
            },
          ),
        ],
      ],
    );
  }

  Widget _buildSaveButton() => SizedBox(
        height: 52,
        child: ElevatedButton.icon(
          onPressed: saving ? null : _save,
          icon: saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.save_outlined),
          label: Text(saving ? 'SAVING...' : isEditing ? 'SAVE' : 'CREATE MATCH', style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
          style: ElevatedButton.styleFrom(backgroundColor: AppFormStyles.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        ),
      );

  Widget _dropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required String Function(T) itemLabel,
    required ValueChanged<T?> onChanged,
    bool allowNull = false,
  }) {
    T? validValue;

    if (value != null && items.contains(value)) {
      validValue = value as T;
    }

    return DropdownButtonFormField<T>(
      value: validValue,
      isExpanded: true,
      dropdownColor: AppFormStyles.surface,
      style: const TextStyle(color: Colors.white),
      decoration: AppFormStyles.inputDecoration(label: label),
      items: [
        if (allowNull)
          DropdownMenuItem<T>(
            value: null,
            child: const Text(
              'None',
              style: TextStyle(
                color: AppFormStyles.secondaryText,
              ),
            ),
          ),
        ...items.map(
          (item) => DropdownMenuItem<T>(
            value: item,
            child: Text(
              itemLabel(item),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ),
      ],
      onChanged: onChanged,
    );
  }
}
