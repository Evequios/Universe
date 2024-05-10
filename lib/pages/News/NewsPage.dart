import 'package:wwe_universe/NavBar.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/News.dart';
import 'package:wwe_universe/database.dart';
import 'package:wwe_universe/pages/News/AddEditNewsPage.dart';
import 'package:wwe_universe/pages/News/NewsDetailPage.dart';

class NewsPage extends StatefulWidget{
  const NewsPage({super.key});

  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> with AutomaticKeepAliveClientMixin {
  late List<News> newsList;
  bool isLoading = false;
  Icon customIcon = const Icon(Icons.search);
  Widget customSearchBar = const Text('News');
  String searchString = '';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    refreshNews();
  }

  Future refreshNews() async {
    setState(() => isLoading = true);

    newsList = await DatabaseService.instance.readAllNews();

    setState(() => isLoading = false);
  }

  void setNewsList(String search) async {
    setState(() => isLoading = true);

    newsList = await DatabaseService.instance.readAllNewsSearch(search);
  
    setState(() => isLoading = false); 
  }



  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
    drawer: const Navbar(),
    appBar: AppBar(
      title: customSearchBar,
      actions: [
        IconButton(
          onPressed: () {
            setState(() {
              if (customIcon.icon == Icons.search) {
                customIcon = const Icon(Icons.cancel);
                customSearchBar =  ListTile(
                  leading: const Icon(
                    Icons.search,
                    color: Colors.white,
                    size: 28,
                  ),
                  title: TextFormField(
                    initialValue: searchString,
                    decoration: const InputDecoration(
                      hintText: "type in news content...",
                      hintStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontStyle: FontStyle.italic,
                      ),
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                    onChanged: (searchString) => ((){this.searchString = searchString; setNewsList(searchString);}()),
                  ),
                );
              } else {
                  searchString = '';
                  customIcon = const Icon(Icons.search);
                  customSearchBar = const Text('News');
                  setNewsList(searchString);
              }
            });
          },
          icon : customIcon,
        ),
      ],
      centerTitle: true,
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
          MaterialPageRoute(builder: (context) => const AddEditNewsPage()),
        );

        refreshNews();
      },
    ),
  );
  }

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
              builder: (context) => NewsDetailPage(newsId: news.id!),
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