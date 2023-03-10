import 'package:wwe_universe/classes/Universe/UniverseStorylines.dart';
import 'package:wwe_universe/NavBar.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/database.dart';
import 'package:wwe_universe/pages/Universe/UniverseStorylines/AddEditUniverseStorylinesPage.dart';
import 'package:wwe_universe/pages/Universe/UniverseStorylines/UniverseStorylinesDetailPage.dart';

class UniverseStorylinesPage extends StatefulWidget{
  const UniverseStorylinesPage({super.key});

  @override
  _UniverseStorylinesPage createState() => _UniverseStorylinesPage();
}

class _UniverseStorylinesPage extends State<UniverseStorylinesPage> with AutomaticKeepAliveClientMixin {
  late List<UniverseStorylines> storylinesList;
  bool isLoading = false;
  Icon customIcon = const Icon(Icons.search);
  Widget customSearchBar = const Text('Storylines');
  String searchString = '';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    refreshStorylines();
  }

  Future refreshStorylines() async {
    setState(() => isLoading = true);

    storylinesList = await UniverseDatabase.instance.readAllStorylines();

    setState(() => isLoading = false);
  }

  void setStorylinesList(String search) async {
    setState(() => isLoading = true);

    storylinesList = await UniverseDatabase.instance.readAllStorylinesSearch(search);
  
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
                      hintText: "type in storylines content...",
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
                    onChanged: (searchString) => ((){this.searchString = searchString; setStorylinesList(searchString);}()),
                  ),
                );
              } else {
                  searchString = '';
                  customIcon = const Icon(Icons.search);
                  customSearchBar = const Text('Storylines');
                  setStorylinesList(searchString);
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
        : storylinesList.isEmpty
          ? const Text(
            'No created storylines'
          )
        : buildUniverseStorylines(),
    ),
    floatingActionButton: FloatingActionButton(
      backgroundColor: Colors.black,
      child: const Icon(Icons.add),
      onPressed: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const AddEditUniverseStorylinesPage()),
        );

        refreshStorylines();
      },
    ),
  );
  }


  Widget buildUniverseStorylines() => ListView.builder(
  padding : const EdgeInsets.all(8),
  itemCount: storylinesList.length,
  itemBuilder: (context,index){
    final storyline = storylinesList[index];
    return Card(
      color : storyline.end != 0 ? Colors.white70 : Colors.white,
      shape:RoundedRectangleBorder(
      side: const BorderSide(color: Color.fromARGB(189, 96, 125, 139)),
      borderRadius: BorderRadius.circular(4.0)),
      elevation : 2,
      child: ListTile(
      onTap: () async {
        await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => UniverseStorylinesDetailPage(storylineId: storyline.id!),
      )).then((value) => refreshStorylines());
      },
      title: Text(storyline.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      subtitle: Row(
        children: [
        Text('Start : Year ${storyline.yearStart} Week ${storyline.start}',style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blueGrey)),
        const Spacer(),
        storyline.end != 0 ? Text('End : Year ${storyline.yearEnd} Week ${storyline.end}', textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blueGrey))
          : const Text(''),
      ])
    ));
  });
}