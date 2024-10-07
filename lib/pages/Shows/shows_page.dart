import 'package:wwe_universe/navbar.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/shows.dart';
import 'package:wwe_universe/database/shows_database_helper.dart';
import 'package:wwe_universe/pages/Shows/add_edit_shows_page.dart';
import 'package:wwe_universe/pages/Shows/shows_detail_page.dart';

class ShowsPage extends StatefulWidget{
  const ShowsPage({super.key});

  @override
  ShowsPageState createState() => ShowsPageState();
}

class ShowsPageState extends State<ShowsPage> with AutomaticKeepAliveClientMixin {
  late List<Shows> showsList;
  bool isLoading = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    refreshShows();
  }

  Future refreshShows() async {
    setState(() => isLoading = true);

    showsList = await ShowsDatabaseHelper.readAllShows();

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
    drawer: const Navbar(),
    appBar: AppBar(
      title: const Text('Shows'),
      centerTitle: true,
    ),
    body: Center(
      child: isLoading
        ? const CircularProgressIndicator()
        : showsList.isEmpty
          ? const Text(
            'No created shows'
          )
        : buildUniverseShows(),
    ),
    floatingActionButton: FloatingActionButton(
      backgroundColor: Colors.black,
      child: const Icon(Icons.add),
      onPressed: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const AddEditShowsPage()),
        );

        refreshShows();
      },
    ),
  );
  }

  Widget buildUniverseShows() => ListView.builder(
    padding: const EdgeInsets.all(8),
    itemCount : showsList.length,
    itemBuilder: (context, index){
      final show = showsList[index];
      String image = 'assets/${show.name.toLowerCase()}.png';
      return GestureDetector(
        onTap: () async {
         await Navigator.of(context).push(MaterialPageRoute(
           builder: (context) => ShowsDetailPage(showId: show.id!),
         )).then((value) => refreshShows());
        },
        child: SizedBox( 
          height: 100,
          child:Card(
            shape:RoundedRectangleBorder(
              side: const BorderSide(color: Color.fromARGB(189, 96, 125, 139)),
              borderRadius: BorderRadius.circular(4.0)
            ),
            elevation: 2,      
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical:8.0, horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    flex:10,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft, 
                      child: 
                        show.name.toLowerCase() == 'raw' || 
                        show.name.toLowerCase() == 'smackdown' ||
                        show.name.toLowerCase() == 'nxt' ?
                          Image(image: AssetImage(image))
                          : Text(show.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    )
                  ),
                  const Spacer(),
                  Text('Year ${show.year} Week ${show.week}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18), ),                      
                ],
              )
            )
          )
        )
      );
    }
  );
}
