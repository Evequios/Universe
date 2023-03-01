import 'package:wwe_universe/classes/Universe/UniverseNews.dart';
import 'package:wwe_universe/NavBar.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/database.dart';
import 'package:wwe_universe/pages/Universe/UniverseNews/AddEditUniverseNewsPage.dart';
import 'package:wwe_universe/pages/Universe/UniverseNews/UniverseNewsDetailPage.dart';



class UniverseNewsPage extends StatefulWidget{
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

    this.newsList = await UniverseDatabase.instance.readAllNews();

    setState(() => isLoading = false);
  }



  @override
  Widget build(BuildContext context) => Scaffold(
        // backgroundColor: Color.fromARGB(227, 242, 237, 237),
        drawer: Navbar(),
        appBar: AppBar(
          title: const Text(
            'News',
            // style : TextStyle(fontWeight: FontWeight.bold,fontSize: 22)
          ),
          // actions: const [Icon(Icons.search), SizedBox(width: 12)],
          
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
              MaterialPageRoute(builder: (context) => AddEditUniverseNewsPage()),
            );

            refreshNews();
          },
        ),
      );

  Widget buildUniverseNews() => ListView.builder(
    padding : EdgeInsets.all(8),
    itemCount: newsList.length,
    itemBuilder: (context, index) {
      final news = newsList[index];
      return Card(
        shape:RoundedRectangleBorder( 
          side: new BorderSide(color: Color.fromARGB(189, 96, 125, 139)),
          borderRadius: BorderRadius.circular(4.0)
        ),
        elevation : 2,
        child: ListTile(
          onTap: () async {
            await Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => UniverseNewsDetailPage(newsId: news.id!),
            )).then((value) => refreshNews());
          },
          title: Text(news.titre, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          subtitle: Row(
            children: [
              // Text('${news.createdTime.toDate().day}/${news.createdTime.toDate().month}/${universeNews.createdTime.toDate().year}  ${universeNews.createdTime.toDate().hour}h${universeNews.createdTime.toDate().minute.toString().padLeft(2, '0')}',
              Text('${news.createdTime}',
                style: TextStyle(color:Colors.blueGrey)
              ),
              const Spacer(),
              Text(news.categorie, textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color:Colors.blueGrey)),
            ]
          ),
              // subtitle: Text('${irlNews.createdTime.toDate().day}/${irlNews.createdTime.toDate().month}/${irlNews.createdTime.toDate().year}  ${irlNews.createdTime.toDate().hour}h${irlNews.createdTime.toDate().minute.toString().padLeft(2, '0')}                                      ${irlNews.categorie}'),
        )
      );
    }
  );
}