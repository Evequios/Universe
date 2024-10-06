import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/stipulations.dart';
import 'package:wwe_universe/database/stipulations_database_helper.dart';
import 'package:wwe_universe/pages/Settings/Stipulations/add_edit_stipulations_page.dart';

class StipulationsDetailPage extends StatefulWidget {
  final int stipulationId;

  const StipulationsDetailPage({
    Key? key,
    required this.stipulationId,
  }) : super(key: key);

  @override
  _StipulationsDetailPage createState() => _StipulationsDetailPage();
}

class _StipulationsDetailPage extends State<StipulationsDetailPage> {
  late Stipulations stipulation;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    refreshStipulations();
  }

  Future refreshStipulations() async {
    setState(() => isLoading = true);

    stipulation = await StipulationsDatabaseHelper.readStipulation(widget.stipulationId);

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      actions: [editButton(), deleteButton()],
    ),
    body: isLoading
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(12),
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                Text(
                  stipulation.type,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  stipulation.stipulation,
                  style: const TextStyle(color: Colors.black, fontSize: 18),
                ),
              ],
            ),
          ),
  );

  Widget editButton() => IconButton(
      icon: const Icon(Icons.edit_outlined),
      onPressed: () async {
        if (isLoading) return;

        await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => AddEditStipulationsPage(stipulation: stipulation),
        ));

        refreshStipulations();
      });

  Widget deleteButton() => IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () async {
          await StipulationsDatabaseHelper.deleteStipulation(widget.stipulationId);

          if(context.mounted) Navigator.of(context).pop();
        },
      );
}