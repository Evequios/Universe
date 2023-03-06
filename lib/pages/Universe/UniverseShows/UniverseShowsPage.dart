import 'package:wwe_universe/classes/Universe/UniverseShows.dart';
import 'package:wwe_universe/NavBar.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/database.dart';
import 'package:wwe_universe/pages/Universe/UniverseShows/AddEditUniverseShowsPage.dart';
import 'package:wwe_universe/pages/Universe/UniverseShows/UniverseShowsDetailPage.dart';

class UniverseShowsPage extends StatefulWidget{
  const UniverseShowsPage({super.key});

  @override
  _UniverseShowsPage createState() => _UniverseShowsPage();
}

class _UniverseShowsPage extends State<UniverseShowsPage> {
  late List<UniverseShows> showsList;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    refreshShows();
  }

  Future refreshShows() async {
    setState(() => isLoading = true);

    showsList = await UniverseDatabase.instance.readAllShows();

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    drawer: Navbar(),
    appBar: AppBar(
      title: const Text('Shows'),
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
          MaterialPageRoute(builder: (context) => const AddEditUniverseShowsPage()),
        );

        refreshShows();
      },
    ),
  );

  Widget buildUniverseShows() => ListView.builder(
    padding: const EdgeInsets.all(8),
    itemCount : showsList.length,
    itemBuilder: (context, index){
      final show = showsList[index];
      String image = 'assets/${show.name.toLowerCase()}.png';
      return GestureDetector(
        onTap: () async {
         await Navigator.of(context).push(MaterialPageRoute(
           builder: (context) => UniverseShowsDetailPage(showId: show.id!),
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
