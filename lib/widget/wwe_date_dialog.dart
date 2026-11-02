import 'package:flutter/material.dart';

/// Collects a WWE calendar date. Controllers are owned by this State and are
/// disposed only after Flutter removes the dialog from the widget tree.
class WweDateDialog extends StatefulWidget {
  final String title;
  final String confirmLabel;
  final int initialDay;

  const WweDateDialog({
    super.key,
    required this.title,
    this.confirmLabel = 'Valider',
    this.initialDay = 1,
  });

  @override
  State<WweDateDialog> createState() => _WweDateDialogState();
}

class _WweDateDialogState extends State<WweDateDialog> {
  late final TextEditingController _yearController;
  late final TextEditingController _weekController;
  late final TextEditingController _dayController;
  String? _error;

  @override
  void initState() {
    super.initState();
    _yearController = TextEditingController();
    _weekController = TextEditingController();
    _dayController = TextEditingController(text: widget.initialDay.toString());
  }

  @override
  void dispose() {
    _yearController.dispose();
    _weekController.dispose();
    _dayController.dispose();
    super.dispose();
  }

  void _submit() {
    final year = int.tryParse(_yearController.text.trim());
    final week = int.tryParse(_weekController.text.trim());
    final day = int.tryParse(_dayController.text.trim());
    if (year == null || year < 1 || week == null || week < 1 || week > 48 ||
        day == null || day < 1 || day > 7) {
      setState(() => _error = 'Saisis une année valide, une semaine de 1 à 48 et un jour de 1 à 7.');
      return;
    }
    Navigator.of(context).pop(<String, int>{
      'year': year,
      'week': week,
      'day': day,
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
            controller: _yearController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Année WWE'),
          ),
          TextField(
            controller: _weekController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Semaine WWE (1 à 48)'),
          ),
          TextField(
            controller: _dayController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Jour (1 lundi – 7 dimanche)'),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(_error!, style: const TextStyle(color: Colors.redAccent)),
            ),
        ]),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Annuler'),
        ),
        TextButton(onPressed: _submit, child: Text(widget.confirmLabel)),
      ],
    );
  }
}
