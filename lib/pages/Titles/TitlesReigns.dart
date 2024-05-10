import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/Reigns.dart';
import 'package:wwe_universe/classes/Superstars.dart';
import 'package:wwe_universe/database.dart';
import 'package:wwe_universe/pages/News/AddEditNewsPage.dart';

class TitlesReigns extends StatefulWidget{
  final int titleId;
  const TitlesReigns({super.key, required this.titleId});

  @override
  _TitlesReignsState createState() => _TitlesReignsState();
}

class _TitlesReignsState extends State<TitlesReigns> with AutomaticKeepAliveClientMixin {
  late List<Reigns> reignsList;
  Superstars holder1 = const Superstars(name: 'name', brand: 0, orientation: 'orientation', ally1: 0, ally2: 0, ally3: 0, ally4: 0, ally5: 0, rival1: 0, rival2: 0, rival3: 0, rival4: 0, rival5: 0, division: 0);
  Superstars holder2 = const Superstars(name: 'name', brand: 0, orientation: 'orientation', ally1: 0, ally2: 0, ally3: 0, ally4: 0, ally5: 0, rival1: 0, rival2: 0, rival3: 0, rival4: 0, rival5: 0, division: 0);
  bool isLoading = false;
  Icon customIcon = const Icon(Icons.search);
  Widget customSearchBar = const Text('Reigns');
  String searchString = '';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    refreshReigns();
  }

  Future refreshReigns() async {
    setState(() => isLoading = true);

    reignsList = await DatabaseService.instance.readAllReignsTitle(widget.titleId);

    setState(() => isLoading = false);
  }

  void setReignsList(String search) async {
    setState(() => isLoading = true);

    // reignsList = await UniverseDatabase.instance.readAllNewsSearch(search);
  
    setState(() => isLoading = false); 
  }



  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
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
                    onChanged: (searchString) => ((){this.searchString = searchString; setReignsList(searchString);}()),
                  ),
                );
              } else {
                  searchString = '';
                  customIcon = const Icon(Icons.search);
                  customSearchBar = const Text('News');
                  setReignsList(searchString);
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
        : reignsList.isEmpty
          ? const Text(
            'No existing reigns'
          )
          : null
        // : buildUniverseReigns(),
    ),
    floatingActionButton: FloatingActionButton(
      backgroundColor: Colors.black,
      child: const Icon(Icons.add),
      onPressed: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const AddEditNewsPage()),
        );

        refreshReigns();
      },
    ),
  );
  }

  // Widget buildUniverseReigns() => ListView.builder(
  //   padding : const EdgeInsets.all(8),
  //   itemCount: reignsList.length,
  //   itemBuilder: (context, index) {
  //     final reign = reignsList[index];
  //     return Card(
  //       shape:RoundedRectangleBorder( 
  //         side: const BorderSide(color: Color.fromARGB(189, 96, 125, 139)),
  //         borderRadius: BorderRadius.circular(4.0)
  //       ),
  //       elevation : 2,
  //       child: ListTile(
  //         onTap: () async {
  //           await Navigator.of(context).push(MaterialPageRoute(
  //             builder: (context) => UniverseNewsDetailPage(newsId: reign.id!),
  //           )).then((value) => refreshReigns());
  //         },
  //         title: reign.holder2 == 0 ? Text('${reign.holder1} & ${reign.holder2}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)) 
  //           : Text(reign.holder1),
  //         subtitle: Row(
  //           children: [
  //             Text('${reign.createdTime.year}-${reign.createdTime.month}-${reign.createdTime.day}',
  //               style: const TextStyle(color:Colors.blueGrey)
  //             ),
  //             const Spacer(),
  //             Text(reign.type, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color:Colors.blueGrey)),
  //           ]
  //         ),
  //       )
  //     );
  //   }
  // );
}