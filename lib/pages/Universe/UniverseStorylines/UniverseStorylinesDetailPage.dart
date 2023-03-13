import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/Universe/UniverseStorylines.dart';
import 'package:wwe_universe/database.dart';
import 'package:wwe_universe/pages/Universe/UniverseStorylines/AddEditUniverseStorylinesPage.dart';

class UniverseStorylinesDetailPage extends StatefulWidget {
  final int storylineId;

  const UniverseStorylinesDetailPage({
    Key? key,
    required this.storylineId,
  }) : super(key: key);

  @override
  _UniverseStorylinesDetailPage createState() => _UniverseStorylinesDetailPage();
}

class _UniverseStorylinesDetailPage extends State<UniverseStorylinesDetailPage> {
  late UniverseStorylines storyline;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    refreshStorylines();
  }

  Future refreshStorylines() async {
    setState(() => isLoading = true);

    storyline = await UniverseDatabase.instance.readStoryline(widget.storylineId);

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
                  storyline.title,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const SizedBox(height: 8),
                Text(
                  storyline.text,
                  style: const TextStyle(color: Colors.black, fontSize: 18),
                )
              ],
            ),
          ),
  );

  Widget editButton() => IconButton(
    icon: const Icon(Icons.edit_outlined),
    onPressed: () async {
      await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => AddEditUniverseStorylinesPage(storyline : storyline),
      ));

      refreshStorylines();
    }
  );

  Widget deleteButton() => IconButton(
    icon: const Icon(Icons.delete),
    onPressed: () async {
      showAlertDialog(context);
    },
  );

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed:  () { 
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: const Text("Continue"),
      onPressed:  () async {
        await UniverseDatabase.instance.deleteStoryline(widget.storylineId);
        if(context.mounted){
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        }
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Confirmation"),
      content: Text("Are you sure you want to delete this storyline ?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

