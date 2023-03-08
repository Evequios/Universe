import 'package:wwe_universe/classes/Universe/UniverseNews.dart';
import 'package:wwe_universe/NavBar.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/database.dart';
import 'package:wwe_universe/pages/Universe/UniverseNews/AddEditUniverseNewsPage.dart';
import 'package:wwe_universe/pages/Universe/UniverseNews/UniverseNewsDetailPage.dart';

class UniverseNewsPage extends StatefulWidget{
  const UniverseNewsPage({super.key});

  @override
  _UniverseNewsPageState createState() => _UniverseNewsPageState();
}

class _UniverseNewsPageState extends State<UniverseNewsPage> {
  late List<UniverseNews> newsList;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    refreshNews();
  }

  Future refreshNews() async {
    setState(() => isLoading = true);

    newsList = await UniverseDatabase.instance.readAllNews();

    setState(() => isLoading = false);
  }



  @override
  Widget build(BuildContext context) => Scaffold(
    drawer: const Navbar(),
    appBar: AppBar(
      title: const Text(
        'News',
      ),
    ),
    body: Center(
      child: isLoading
        ? const CircularProgressIndicator()
        : newsList.isEmpty
          ? const Text(
            'No created news'
          )
        : buildUniverseNews(),
    ),
    floatingActionButton: FloatingActionButton(
      backgroundColor: Colors.black,
      child: const Icon(Icons.add),
      onPressed: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const AddEditUniverseNewsPage()),
        );

        refreshNews();
      },
    ),
  );

  Widget buildUniverseNews() => ListView.builder(
    padding : const EdgeInsets.all(8),
    itemCount: newsList.length,
    itemBuilder: (context, index) {
      final news = newsList[index];
      return Card(
        shape:RoundedRectangleBorder( 
          side: const BorderSide(color: Color.fromARGB(189, 96, 125, 139)),
          borderRadius: BorderRadius.circular(4.0)
        ),
        elevation : 2,
        child: ListTile(
          onTap: () async {
            await Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => UniverseNewsDetailPage(newsId: news.id!),
            )).then((value) => refreshNews());
          },
          title: Text(news.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          subtitle: Row(
            children: [
              Text('${news.createdTime.year}-${news.createdTime.month}-${news.createdTime.day}',
                style: const TextStyle(color:Colors.blueGrey)
              ),
              const Spacer(),
              Text(news.type, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color:Colors.blueGrey)),
            ]
          ),
        )
      );
    }
  );
}