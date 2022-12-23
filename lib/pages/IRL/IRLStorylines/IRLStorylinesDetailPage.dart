import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/IRL/IRLStorylines.dart';
import 'package:wwe_universe/classes/IRL/IRLNews.dart';
import 'package:wwe_universe/pages/IRL/IRLNews/AddEditIRLNewsPage.dart';
import 'package:wwe_universe/pages/IRL/IRLStorylines/AddEditIRLStorylinesPage.dart';
// import 'package:sqflite_database_example/page/edit_note_page.dart';

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
            ? Center(child: CircularProgressIndicator())
            : Padding(
                padding: EdgeInsets.all(12),
                child: ListView(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  children: [
                    Text(
                      irlStorylines!.titre,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    SizedBox(height: 8),
                    Text(
                      irlStorylines!.texte,
                      style: TextStyle(color: Colors.black, fontSize: 18),
                    )
                  ],
                ),
              ),
      );

  Widget editButton() => IconButton(
      icon: Icon(Icons.edit_outlined),
      onPressed: () async {
        if (isLoading) return;

        await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => AddEditIRLStorylinesPage(irlStorylines: irlStorylines),
        ));
      });

  Widget deleteButton() => IconButton(
        icon: Icon(Icons.delete),
        onPressed: () {
          final docIRLStorylines= FirebaseFirestore.instance.collection('IRLStorylines').doc(irlStorylines!.id);
          docIRLStorylines.delete();
          Navigator.of(context).pop();
        },
  );
}

