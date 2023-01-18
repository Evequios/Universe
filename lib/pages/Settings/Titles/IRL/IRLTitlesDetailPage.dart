import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/IRL/IRLTitles.dart';
import 'package:wwe_universe/pages/Settings/Titles/IRL/AddEditIRLTitlesPage.dart';
// import 'package:sqflite_database_example/page/edit_note_page.dart';

class IRLTitlesDetailPage extends StatefulWidget {
  final IRLTitles irlTitles;

  const IRLTitlesDetailPage({
    Key? key,
    required this.irlTitles,
  }) : super(key: key);

  @override
  _IRLTitlesDetailPage createState() => _IRLTitlesDetailPage();
}

class _IRLTitlesDetailPage extends State<IRLTitlesDetailPage> {
  late IRLTitles? irlTitles = widget.irlTitles;
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
                      irlTitles!.nom,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    SizedBox(height: 8),
                    Text("Show : ${irlTitles!.show}",
                      style: TextStyle(color: Colors.black, fontSize: 18)
                    ),
                    SizedBox(height: 8),
                    irlTitles!.tag == 'false' ?
                    Text("Champion : ${irlTitles!.holder1}",
                      style: TextStyle(color: Colors.black, fontSize: 18),
                    )
                    :Text("Champions : ${irlTitles!.holder1} & ${irlTitles!.holder2}",
                      style: TextStyle(color: Colors.black, fontSize: 18),
                    )
                    ,
                  ],
                ),
              ),
      );

  Widget editButton() => IconButton(
      icon: Icon(Icons.edit_outlined),
      onPressed: () async {
        if (isLoading) return;

        await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => AddEditIRLTitlesPage(irlTitles: irlTitles),
        ));
      });

  Widget deleteButton() => IconButton(
        icon: Icon(Icons.delete),
        onPressed: () {
          final docIRLTitles = FirebaseFirestore.instance.collection('IRLTitles').doc(irlTitles!.id);
          docIRLTitles.delete();
          Navigator.of(context).pop();
        },
      );
}