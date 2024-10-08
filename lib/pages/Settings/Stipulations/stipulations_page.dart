import 'package:wwe_universe/navbar.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/stipulations.dart';
import 'package:wwe_universe/database/stipulations_database_helper.dart';
import 'package:wwe_universe/pages/Settings/Stipulations/add_edit_stipulations_page.dart';
import 'package:wwe_universe/pages/Settings/Stipulations/stipulations_detail_page.dart';

class StipulationsPage extends StatefulWidget{
  const StipulationsPage({super.key});

  @override
  StipulationsPageState createState() => StipulationsPageState();
}

class StipulationsPageState extends State<StipulationsPage> with AutomaticKeepAliveClientMixin{
  late List<Stipulations> stipulationsList;
  bool isLoading = false;
  Icon customIcon = const Icon(Icons.search);
  Widget customSearchBar = const Text('Stipulations');
  String searchString = '';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    refreshStipulations();
  }

  Future refreshStipulations() async {
    setState(() => isLoading = true);

    stipulationsList = await StipulationsDatabaseHelper.readAllStipulations();

    setState(() => isLoading = false);
  }

  void setStipulationsList(String search) async {
    setState(() => isLoading = true);

    stipulationsList = await StipulationsDatabaseHelper.readAllStipulationsSearch(search);
  
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
                      hintText: "type in stipulation's content...",
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
                    onChanged: (searchString) => ((){this.searchString = searchString; setStipulationsList(searchString);}()),
                  ),
                );
              } else {
                  searchString = '';
                  customIcon = const Icon(Icons.search);
                  customSearchBar = const Text('Stipulations');
                  setStipulationsList(searchString);
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
        : stipulationsList.isEmpty
          ? const Text(
            'No created stipulations'
          )
        : buildUniverseStipulations(),
    ),
    floatingActionButton: FloatingActionButton(
      backgroundColor: Colors.black,
      child: const Icon(Icons.add),
      onPressed: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const AddEditStipulationsPage()),
        );

        refreshStipulations();
      },
    ),
  );
  }

  Widget buildUniverseStipulations() => ListView.builder(
    padding: const EdgeInsets.all(8),
    itemCount: stipulationsList.length,
    itemBuilder: (context, index) {
      final stipulation = stipulationsList[index];
      return Card(
        shape:RoundedRectangleBorder(
          side: const BorderSide(color: Color.fromARGB(189, 96, 125, 139)),
          borderRadius: BorderRadius.circular(4.0)
        ),
        elevation : 2,
        child: ListTile(
          onTap: () async {
            await Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => StipulationsDetailPage(stipulationId: stipulation.id!),
          )).then((value) => refreshStipulations());
          },
          title: Text('${stipulation.type} ${stipulation.stipulation}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        )
      );
    }
  );
}