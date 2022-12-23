import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/IRL/IRLNews.dart';
import 'package:wwe_universe/pages/IRL/IRLNews/AddEditIRLNewsPage.dart';
// import 'package:sqflite_database_example/page/edit_note_page.dart';

class IRLNewsDetailPage extends StatefulWidget {
  final IRLNews irlNews;

  const IRLNewsDetailPage({
    Key? key,
    required this.irlNews,
  }) : super(key: key);

  @override
  _IRLNewsDetailPage createState() => _IRLNewsDetailPage();
}

class _IRLNewsDetailPage extends State<IRLNewsDetailPage> {
  late IRLNews? irlNews = widget.irlNews;
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
                      irlNews!.titre,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    SizedBox(height: 8),
                    Text(
                      irlNews!.texte,
                      style: TextStyle(color: Colors.black, fontSize: 18),
                    ),
                  ],
                ),
              ),
      );

  Widget editButton() => IconButton(
      icon: Icon(Icons.edit_outlined),
      onPressed: () async {
        if (isLoading) return;

        await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => AddEditIRLNewsPage(irlNews: irlNews),
        ));
      });

  Widget deleteButton() => IconButton(
        icon: Icon(Icons.delete),
        onPressed: () {
          final docIRLNews = FirebaseFirestore.instance.collection('IRLNews').doc(irlNews!.id);
          docIRLNews.delete();
          Navigator.of(context).pop();
        },
      );
}