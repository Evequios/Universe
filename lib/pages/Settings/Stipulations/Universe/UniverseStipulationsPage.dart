import 'package:wwe_universe/classes/Universe/UniverseStipulations.dart';
import 'package:wwe_universe/NavBar.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/database.dart';
import 'package:wwe_universe/pages/Settings/Stipulations/Universe/AddEditUniverseStipulationsPage.dart';
import 'package:wwe_universe/pages/Settings/Stipulations/Universe/UniverseStipulationsDetailPage.dart';



class UniverseStipulationsPage extends StatefulWidget{
  const UniverseStipulationsPage({super.key});

  @override
  _UniverseStipulationsPageState createState() => _UniverseStipulationsPageState();
}

class _UniverseStipulationsPageState extends State<UniverseStipulationsPage> {
  late List<UniverseStipulations> stipulationsList;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    refreshStipulations();
  }

  Future refreshStipulations() async {
    setState(() => isLoading = true);

    stipulationsList = await UniverseDatabase.instance.readAllStipulations();

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    drawer: Navbar(),
    appBar: AppBar(
      title: const Text(
        'Stipulations',
      ),
      actions: const [Icon(Icons.search), SizedBox(width: 12)],
    ),
    body: Center(
      child: isLoading
        ? const CircularProgressIndicator()
        : stipulationsList.isEmpty
          ? const Text(
            'No created stipulations'
          )
        : buildUniverseStipulations(),
    ),
    floatingActionButton: FloatingActionButton(
      backgroundColor: Colors.black,
      child: const Icon(Icons.add),
      onPressed: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const AddEditUniverseStipulationsPage()),
        );

        refreshStipulations();
      },
    ),
  );

  Widget buildUniverseStipulations() => ListView.builder(
    padding: const EdgeInsets.all(8),
    itemCount: stipulationsList.length,
    itemBuilder: (context, index) {
      final stipulation = stipulationsList[index];
      return Card(
        shape:RoundedRectangleBorder(
          side: const BorderSide(color: Color.fromARGB(189, 96, 125, 139)),
          borderRadius: BorderRadius.circular(4.0)
        ),
        elevation : 2,
        child: ListTile(
          onTap: () async {
            await Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => UniverseStipulationsDetailPage(stipulationId: stipulation.id!),
          )).then((value) => refreshStipulations());
          },
          title: Text('${stipulation.type} ${stipulation.stipulation}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        )
      );
    }
  );
}