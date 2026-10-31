
import 'package:flutter/material.dart';

import 'package:wwe_universe/classes/match_formats.dart';
import 'package:wwe_universe/classes/match_record.dart';
import 'package:wwe_universe/classes/match_sides.dart';
import 'package:wwe_universe/classes/match_participants.dart';
import 'package:wwe_universe/classes/stipulations.dart';
import 'package:wwe_universe/classes/superstars.dart';
import 'package:wwe_universe/classes/teams.dart';
import 'package:wwe_universe/classes/titles.dart';
import 'package:wwe_universe/classes/show.dart';

import 'package:wwe_universe/database/matches_database_helper.dart';
import 'package:wwe_universe/database/match_formats_database_helper.dart';
import 'package:wwe_universe/database/stipulations_database_helper.dart';
import 'package:wwe_universe/database/superstars_database_helper.dart';
import 'package:wwe_universe/database/teams_database_helper.dart';
import 'package:wwe_universe/database/titles_database_helper.dart';

import 'package:wwe_universe/widget/app_form_widgets.dart';

class AddEditMatchesPage extends StatefulWidget {
  final MatchRecord? match;
  final Show show;

  const AddEditMatchesPage({
    super.key,
    this.match,
    required this.show,
  });

  @override
  State<AddEditMatchesPage> createState() => _AddEditMatchesPageState();
}

class _ParticipantDraft {
  final int? superstarId;
  final String name;

  const _ParticipantDraft({
    required this.name,
    this.superstarId,
  });

  factory _ParticipantDraft.fromSuperstar(Superstars superstar) {
    return _ParticipantDraft(
      name: superstar.name,
      superstarId: superstar.id,
    );
  }

  factory _ParticipantDraft.fromHistorical(
    MatchParticipants participant,
  ) {
    return _ParticipantDraft(
      name: participant.superstarName,
      superstarId: participant.superstarId,
    );
  }
}

class _SideDraft {
  String name;
  int? teamId;
  final List<_ParticipantDraft> participants;

  _SideDraft({
    required this.name,
    this.teamId,
    List<_ParticipantDraft>? participants,
  }) : participants = participants ?? [];
}

class _AddEditMatchesPageState extends State<AddEditMatchesPage> {
  final _formKey = GlobalKey<FormState>();

  List<MatchFormats> formats = [];
  List<Stipulations> stipulations = [];
  List<Superstars> superstars = [];
  List<Teams> teams = [];
  List<Titles> titles = [];

  MatchFormats? selectedFormat;
  Stipulations? selectedStipulation;
  Titles? selectedTitle;

  final List<_SideDraft> sides = [];

  String resultStatus = MatchResultStatus.pending;
  int? winnerSideOrder;
  int? winnerSuperstarId;
  String? winnerName;

  bool loading = true;
  bool saving = false;

  final TextEditingController orderController = TextEditingController();

  bool get isEditing => widget.match != null;

  @override
  void initState() {
    super.initState();
    orderController.text =
        (widget.match?.matchOrder ?? 0).toString();
    _loadData();
  }

  @override
  void dispose() {
    orderController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        MatchFormatsDatabaseHelper.readAllFormats(),
        StipulationsDatabaseHelper.readAllStipulations(),
        SuperstarsDatabaseHelper.readAllSuperstars(),
        TeamsDatabaseHelper.readAllTeams(),
        TitlesDatabaseHelper.readAllTitles(),
      ]);

      formats = results[0] as List<MatchFormats>;
      stipulations = results[1] as List<Stipulations>;
      superstars = results[2] as List<Superstars>;
      teams = results[3] as List<Teams>;
      titles = results[4] as List<Titles>;

      debugPrint('Nombre de formats : ${formats.length}');
      debugPrint('Nombre de stipulations : ${stipulations.length}');

      for (final format in formats) {
        debugPrint('Format chargé : ${format.id} - ${format.name}');
      }

      final match = widget.match;

      if (match != null) {
        selectedFormat = formats.where(
          (item) => item.id == match.format?.id,
        ).firstOrNull;

        selectedStipulation = stipulations.where(
          (item) => item.id == match.stipulation?.id,
        ).firstOrNull;

        selectedTitle = titles.where(
          (item) => item.id == match.title?.id,
        ).firstOrNull;

        resultStatus = match.resultStatus;
        winnerSideOrder = match.winnerSideOrder;
        winnerSuperstarId = match.winnerSuperstarId;
        winnerName = match.winnerName;

        for (final side in match.sides) {
          final draft = _SideDraft(
            name: side.name,
            teamId: side.teamId,
          );

          for (final participant in side.participants) {
            draft.participants.add(
              _ParticipantDraft.fromHistorical(participant),
            );
          }

          sides.add(draft);
        }
      } else {
        if (formats.isNotEmpty) selectedFormat = formats.first;
        if (stipulations.isNotEmpty) {
          selectedStipulation = stipulations.first;
        }

        sides.add(_SideDraft(name: 'Camp 1'));
        sides.add(_SideDraft(name: 'Camp 2'));
      }

      if (mounted) {
        setState(() => loading = false);
      }
    } catch (e) {
      debugPrint('Erreur chargement formulaire combat : $e');

      if (mounted) {
        setState(() => loading = false);
        _showMessage('Impossible de charger les données : $e');
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _addSide() {
    setState(() {
      sides.add(
        _SideDraft(name: 'Camp ${sides.length + 1}'),
      );
    });
  }

  void _removeSide(int index) {
    if (sides.length <= 2) return;

    setState(() {
      sides.removeAt(index);
      winnerSideOrder = null;
      winnerSuperstarId = null;
      winnerName = null;

      if (resultStatus == MatchResultStatus.winner) {
        resultStatus = MatchResultStatus.pending;
      }

      for (var i = 0; i < sides.length; i++) {
        if (sides[i].name.startsWith('Camp ')) {
          sides[i].name = 'Camp ${i + 1}';
        }
      }
    });
  }

  void _selectTeam(int sideIndex, int? teamId) {
    setState(() {
      final side = sides[sideIndex];
      side.teamId = teamId;

      if (teamId == null) return;

      final team = teams.firstWhere(
        (item) => item.id == teamId,
      );

      side.name = team.name;
    });
  }

  void _resetWinnerIfNoLongerParticipant() {
    if (resultStatus != MatchResultStatus.winner ||
        winnerSideOrder != null) {
      return;
    }

    final winnerStillExists = sides.any(
      (side) => side.participants.any((participant) {
        if (winnerSuperstarId != null) {
          return participant.superstarId == winnerSuperstarId &&
              participant.name == winnerName;
        }

        return winnerName != null &&
            participant.name == winnerName;
      }),
    );

    if (!winnerStillExists) {
      winnerSideOrder = null;
      winnerSuperstarId = null;
      winnerName = null;
      resultStatus = MatchResultStatus.pending;
    }
  }

  void _toggleParticipant(
    int sideIndex,
    _ParticipantDraft participant,
    bool selected,
  ) {
    setState(() {
      final participants = sides[sideIndex].participants;

      if (selected) {
        final alreadyExists = participants.any(
          (item) =>
              item.superstarId == participant.superstarId &&
              item.name == participant.name,
        );

        if (!alreadyExists) {
          participants.add(participant);
        }
      } else {
        participants.removeWhere(
          (item) =>
              item.superstarId == participant.superstarId &&
              item.name == participant.name,
        );

        _resetWinnerIfNoLongerParticipant();
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedFormat == null &&
        (!isEditing || widget.match!.formatName.trim().isEmpty)) {
      _showMessage('Sélectionne un format de combat.');
      return;
    }

    if (selectedStipulation == null &&
        (!isEditing || widget.match!.stipulationName.trim().isEmpty)) {
      _showMessage('Sélectionne une stipulation.');
      return;
    }

    if (sides.length < 2 || sides.any((side) => side.participants.isEmpty)) {
      _showMessage('Chaque camp doit avoir au moins un participant.');
      return;
    }

    if (sides.any((side) => side.name.trim().isEmpty)) {
      _showMessage('Chaque camp doit avoir un nom.');
      return;
    }

    if (resultStatus == MatchResultStatus.winner) {
      final hasSideWinner = winnerSideOrder != null;
      final hasIndividualWinner =
          winnerName != null && winnerName!.trim().isNotEmpty;

      if (hasSideWinner == hasIndividualWinner) {
        _showMessage('Sélectionne un seul type de vainqueur.');
        return;
      }

      if (hasSideWinner &&
          (winnerSideOrder! < 0 || winnerSideOrder! >= sides.length)) {
        _showMessage('Le camp gagnant est invalide.');
        return;
      }

      if (hasIndividualWinner) {
        final winnerExists = sides.any(
          (side) => side.participants.any((participant) {
            if (winnerSuperstarId != null) {
              return participant.superstarId == winnerSuperstarId &&
                  participant.name == winnerName;
            }

            return participant.name == winnerName;
          }),
        );

        if (!winnerExists) {
          _showMessage('Le vainqueur doit participer au combat.');
          return;
        }
      }
    }

    setState(() => saving = true);

    try {
      final matchSides = <MatchSides>[];

      for (var i = 0; i < sides.length; i++) {
        final draft = sides[i];

        final participants = <MatchParticipants>[];

        for (var j = 0; j < draft.participants.length; j++) {
          final participant = draft.participants[j];

          participants.add(
            MatchParticipants(
              matchId: widget.match?.id ?? 0,
              sideId: null,
              position: j,
              superstarId: participant.superstarId,
              superstarName: participant.name,
            ),
          );
        }

        matchSides.add(
          MatchSides(
            matchId: widget.match?.id ?? 0,
            sideOrder: i,
            name: draft.name.trim(),
            teamId: draft.teamId,
            participants: participants,
          ),
        );
      }

      final order = int.tryParse(orderController.text.trim()) ?? 0;

      final match = MatchRecord(
        id: widget.match?.id,
        format: selectedFormat,
        formatName: selectedFormat?.name ?? widget.match!.formatName,
        stipulation: selectedStipulation,
        stipulationName:
            selectedStipulation?.stipulation ?? widget.match!.stipulationName,
        sides: matchSides,
        resultStatus: resultStatus,
        winnerSideOrder: winnerSideOrder,
        winnerSuperstarId: winnerSuperstarId,
        winnerName: winnerName,
        matchOrder: order < 0 ? 0 : order,
        show: widget.show,
        title: selectedTitle
      );

      if (isEditing) {
        await MatchesDatabaseHelper.updateMatches(match);
      } else {
        await MatchesDatabaseHelper.createMatch(match);
      }

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      debugPrint('Erreur sauvegarde combat : $e');
      _showMessage('Impossible d’enregistrer le combat : $e');
    } finally {
      if (mounted) {
        setState(() => saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppFormStyles.background,
      appBar: AppBar(
        backgroundColor: AppFormStyles.background,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          isEditing ? 'EDIT MATCH' : 'NEW MATCH',
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppFormStyles.primary,
              ),
            )
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildGeneralSection(),
                  const SizedBox(height: 20),
                  _buildSidesSection(),
                  const SizedBox(height: 20),
                  _buildResultSection(),
                  const SizedBox(height: 20),
                  _buildOrderSection(),
                  const SizedBox(height: 28),
                  _buildSaveButton(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildGeneralSection() {
    return AppFormSection(
      title: 'MATCH INFORMATION',
      children: [
        _dropdown<MatchFormats>(
          label: 'Format',
          value: selectedFormat,
          items: formats,
          itemLabel: (item) => item.name,
          onChanged: (value) {
            setState(() => selectedFormat = value);
          },
        ),
        const SizedBox(height: 14),
        _dropdown<Stipulations>(
          label: 'Stipulation',
          value: selectedStipulation,
          items: stipulations,
          itemLabel: (item) => item.stipulation,
          onChanged: (value) {
            setState(() => selectedStipulation = value);
          },
        ),
        const SizedBox(height: 14),
        _dropdown<Titles>(
          label: 'Championship (optional)',
          value: selectedTitle,
          items: titles,
          itemLabel: (item) => item.name,
          onChanged: (value) {
            setState(() => selectedTitle = value);
          },
          allowNull: true,
        ),
      ],
    );
  }

  Widget _buildSidesSection() {
    return AppFormSection(
      title: 'PARTICIPANTS & SIDES',
      children: [
        const Text(
          'Create the sides involved in the match. You can associate a team '
          'with a side, then select only the members who actually participate.',
          style: TextStyle(
            color: AppFormStyles.secondaryText,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 14),
        ...List.generate(sides.length, _buildSideCard),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _addSide,
          icon: const Icon(Icons.add),
          label: const Text('ADD SIDE'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppFormStyles.primary,
            side: const BorderSide(color: AppFormStyles.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildSideCard(int index) {
    final side = sides[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppFormStyles.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppFormStyles.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'SIDE ${index + 1}',
                  style: const TextStyle(
                    color: AppFormStyles.primary,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ),
              if (sides.length > 2)
                IconButton(
                  onPressed: () => _removeSide(index),
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                  ),
                ),
            ],
          ),
          TextFormField(
            initialValue: side.name,
            style: const TextStyle(color: Colors.white),
            decoration: AppFormStyles.inputDecoration(
              label: 'Side name',
              hint: 'e.g. The Bloodline',
            ),
            onChanged: (value) => side.name = value,
            validator: (value) =>
                value == null || value.trim().isEmpty
                    ? 'Name required'
                    : null,
          ),
          const SizedBox(height: 12),
          _dropdown<Teams>(
            label: 'Associated team (optional)',
            value: side.teamId == null
                ? null
                : teams.where((team) => team.id == side.teamId).firstOrNull,
            items: teams,
            itemLabel: (team) => team.name,
            allowNull: true,
            onChanged: (team) {
              _selectTeam(index, team?.id);
            },
          ),
          const SizedBox(height: 14),
          const Text(
            'PARTICIPANTS',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          if (side.participants.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No participant selected',
                style: TextStyle(
                  color: AppFormStyles.secondaryText,
                ),
              ),
            )
          else
            ...side.participants.map(
              (participant) => ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.person,
                  color: AppFormStyles.primary,
                ),
                title: Text(
                  participant.name,
                  style: const TextStyle(color: Colors.white),
                ),
                trailing: IconButton(
                  onPressed: () => _toggleParticipant(
                    index,
                    participant,
                    false,
                  ),
                  icon: const Icon(
                    Icons.close,
                    color: Colors.redAccent,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _openParticipantPicker(index),
            icon: const Icon(Icons.person_add_alt_1),
            label: const Text('SELECT PARTICIPANTS'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: AppFormStyles.border),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openParticipantPicker(int sideIndex) async {
    final currentParticipants = sides[sideIndex].participants;

    final selectedIds = currentParticipants
        .where((item) => item.superstarId != null)
        .map((item) => item.superstarId!)
        .toSet();

    final idsUsedByOtherSides = <int>{};

    for (var i = 0; i < sides.length; i++) {
      if (i == sideIndex) continue;

      for (final participant in sides[i].participants) {
        if (participant.superstarId != null) {
          idsUsedByOtherSides.add(participant.superstarId!);
        }
      }
    }

    final result = await showModalBottomSheet<List<int>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppFormStyles.surface,
      builder: (context) {
        final temporarySelection = Set<int>.from(selectedIds);

        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.75,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'SELECT SUPERSTARS',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(
                                context,
                                temporarySelection.toList(),
                              );
                            },
                            child: const Text('DONE'),
                          ),
                        ],
                      ),
                    ),
                    const Divider(color: AppFormStyles.border),
                    Expanded(
                      child: ListView.builder(
                        itemCount: superstars.length,
                        itemBuilder: (context, index) {
                          final superstar = superstars[index];
                          final id = superstar.id!;

                          return CheckboxListTile(
                            value: temporarySelection.contains(id),
                            activeColor: AppFormStyles.primary,
                            title: Text(
                              superstar.name,
                              style: const TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              superstar.brand?.name ?? 'No brand',
                              style: const TextStyle(
                                color: AppFormStyles.secondaryText,
                              ),
                            ),
                            onChanged: idsUsedByOtherSides.contains(id) &&
                              !temporarySelection.contains(id)
                              ? null
                              : (selected) {
                                  setModalState(() {
                                    if (selected == true) {
                                      temporarySelection.add(id);
                                    } else {
                                      temporarySelection.remove(id);
                                    }
                                  });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (result == null) return;

    setState(() {
      final participants = sides[sideIndex].participants;

      // On conserve les participants historiques dont l'identifiant
      // Superstar est déjà nul.
      final historicalParticipants = participants
          .where((item) => item.superstarId == null)
          .toList();

      participants
        ..clear()
        ..addAll(historicalParticipants)
        ..addAll(
          result.map((id) {
            final superstar = superstars.firstWhere(
              (item) => item.id == id,
            );

            return _ParticipantDraft.fromSuperstar(superstar);
          }),
        );

        _resetWinnerIfNoLongerParticipant();
    });
  }
  
  Widget _buildResultSection() {
    return AppFormSection(
      title: 'MATCH RESULT',
      children: [
        _dropdown<String>(
          label: 'Status',
          value: resultStatus,
          items: const [
            MatchResultStatus.pending,
            MatchResultStatus.winner,
            MatchResultStatus.draw,
            MatchResultStatus.noContest,
          ],
          itemLabel: (value) {
            switch (value) {
              case MatchResultStatus.pending:
                return 'Pending';
              case MatchResultStatus.winner:
                return 'Winner declared';
              case MatchResultStatus.draw:
                return 'Draw';
              case MatchResultStatus.noContest:
                return 'No Contest';
              default:
                return value;
            }
          },
          onChanged: (value) {
            setState(() {
              resultStatus = value ?? MatchResultStatus.pending;
              winnerSideOrder = null;
              winnerSuperstarId = null;
              winnerName = null;
            });
          },
        ),
        if (resultStatus == MatchResultStatus.winner) ...[
          const SizedBox(height: 14),
          _dropdown<int>(
            label: 'Winning side',
            value: winnerSideOrder,
            items: List.generate(sides.length, (index) => index),
            itemLabel: (value) => sides[value].name,
            allowNull: true,
            onChanged: (value) {
              setState(() {
                winnerSideOrder = value;
                winnerSuperstarId = null;
                winnerName = null;
              });
            },
          ),
          const SizedBox(height: 14),
          const Center(
            child: Text(
              'OR',
              style: TextStyle(
                color: AppFormStyles.secondaryText,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 14),
          _dropdown<_ParticipantDraft>(
            label: 'Individual winner',
            value: sides
                .expand((side) => side.participants)
                .where((participant) {
                  if (winnerSuperstarId != null) {
                    return participant.superstarId == winnerSuperstarId;
                  }

                  return winnerName != null &&
                      participant.name == winnerName;
                })
                .firstOrNull,
            items: sides
                .expand((side) => side.participants)
                .toList(),
            itemLabel: (participant) => participant.name,
            allowNull: true,
            onChanged: (value) {
              setState(() {
                winnerSuperstarId = value?.superstarId;
                winnerName = value?.name;
                winnerSideOrder = null;
              });
            },
          ),
        ],
      ],
    );
  }

  Widget _buildOrderSection() {
    return AppFormSection(
      title: 'DISPLAY ORDER',
      children: [
        TextFormField(
          controller: orderController,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: AppFormStyles.inputDecoration(
            label: 'Match order',
            hint: '0',
          ),
          validator: (value) {
            final parsed = int.tryParse(value ?? '');
            if (parsed == null || parsed < 0) {
              return 'Enter a positive number';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      height: 52,
      child: ElevatedButton.icon(
        onPressed: saving ? null : _save,
        icon: saving
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.save_outlined),
        label: Text(
          saving
              ? 'SAVING...'
              : isEditing
                  ? 'SAVE CHANGES'
                  : 'CREATE MATCH',
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppFormStyles.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

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
      validValue = value;
    }

    return DropdownButtonFormField<T>(
      value: validValue,
      isExpanded: true,
      dropdownColor: AppFormStyles.surface,
      style: const TextStyle(color: Colors.white),
      decoration: AppFormStyles.inputDecoration(
        label: label,
      ),
      items: [
        if (allowNull)
          DropdownMenuItem<T>(
            value: null,
            child: const Text(
              'None',
              overflow: TextOverflow.ellipsis,
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
