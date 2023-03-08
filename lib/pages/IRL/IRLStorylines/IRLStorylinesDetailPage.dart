import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/IRL/IRLStorylines.dart';
import 'package:wwe_universe/pages/IRL/IRLStorylines/AddEditIRLStorylinesPage.dart';

class IRLStorylinesDetailPage extends StatefulWidget {
  final IRLStorylines irlStorylines;

  const IRLStorylinesDetailPage({
    Key? key,
    required this.irlStorylines,
  }) : super(key: key);

  @override
  _IRLStorylinesDetailPage createState() => _IRLStorylinesDetailPage();
}

class _IRLStorylinesDetailPage extends State<IRLStorylinesDetailPage> {
  late IRLStorylines? irlStorylines = widget.irlStorylines;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
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
                      irlStorylines!.titre,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const SizedBox(height: 8),
                    Text(
                      irlStorylines!.texte,
                      style: const TextStyle(color: Colors.black, fontSize: 18),
                    ),
                    const SizedBox(height: 20,),
                    Row(
                      children: [
                      Text('Début : ${irlStorylines!.debut}',style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blueGrey)),
                      const Spacer(),
                      Text('Fin : ${irlStorylines!.fin}', textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blueGrey)),
                      ]
                    )
                  ],
                ),
              ),
      );

  Widget editButton() => IconButton(
      icon: const Icon(Icons.edit_outlined),
      onPressed: () async {
        if (isLoading) return;

        await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => AddEditIRLStorylinesPage(irlStorylines: irlStorylines),
        ));
      });

  Widget deleteButton() => IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () {
          final docIRLStorylines= FirebaseFirestore.instance.collection('IRLStorylines').doc(irlStorylines!.id);
          docIRLStorylines.delete();
          Navigator.of(context).pop();
        },
  );
}

