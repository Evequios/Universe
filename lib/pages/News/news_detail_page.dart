import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/news.dart';
import 'package:wwe_universe/database/news_database_helper.dart';
import 'package:wwe_universe/pages/News/add_edit_news_page.dart';

class NewsDetailPage extends StatefulWidget {
  final int newsId;

  const NewsDetailPage({
    Key? key,
    required this.newsId,
  }) : super(key: key);

  @override
  _NewsDetailPage createState() => _NewsDetailPage();
}

class _NewsDetailPage extends State<NewsDetailPage> {
  late News news;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    refreshNews();
  }

  Future refreshNews() async {
    setState(() => isLoading = true);

    news = await NewsDatabaseHelper.readNews(widget.newsId);

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
              news.title,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const SizedBox(height: 8),
            Text(
              news.text,
              style: const TextStyle(color: Colors.black, fontSize: 18),
            ),
          ],
        ),
      ),
  );

  Widget editButton() => IconButton(
    icon: const Icon(Icons.edit_outlined),
    onPressed: () async {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => AddEditNewsPage(news: news),)
      );

      refreshNews();
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
        await NewsDatabaseHelper.deleteNews(widget.newsId);
        if(context.mounted){
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        }
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Confirmation"),
      content: const Text("Are you sure you want to delete this news ?"),
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