import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/Universe/UniverseNews.dart';
import 'package:wwe_universe/database.dart';
import 'package:wwe_universe/pages/Universe/UniverseNews/AddEditUniverseNewsPage.dart';
// import 'package:sqflite_database_example/page/edit_note_page.dart';

class UniverseNewsDetailPage extends StatefulWidget {
  final int newsId;

  const UniverseNewsDetailPage({
    Key? key,
    required this.newsId,
  }) : super(key: key);

  @override
  _UniverseNewsDetailPage createState() => _UniverseNewsDetailPage();
}

class _UniverseNewsDetailPage extends State<UniverseNewsDetailPage> {
  late UniverseNews news;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    refreshNews();
  }

  Future refreshNews() async {
    setState(() => isLoading = true);

    this.news = await UniverseDatabase.instance.readNews(widget.newsId);

    setState(() => isLoading = false);  
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
                      news.titre,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    SizedBox(height: 8),
                    Text(
                      news.texte,
                      style: TextStyle(color: Colors.black, fontSize: 18),
                    ),
                  ],
                ),
              ),
      );

  Widget editButton() => IconButton(
      icon: Icon(Icons.edit_outlined),
      onPressed: () async {
        // if (isLoading) return;

        await Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => AddEditUniverseNewsPage(news: news),)
        );

        refreshNews();
      });

  Widget deleteButton() => IconButton(
        icon: Icon(Icons.delete),
        onPressed: () async {
          await UniverseDatabase.instance.deleteNews(widget.newsId);
          Navigator.of(context).pop();
        },
      );
}