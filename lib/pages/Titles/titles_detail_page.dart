import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/superstars.dart';
import 'package:wwe_universe/classes/titles.dart';
import 'package:wwe_universe/database/superstars_database_helper.dart';
import 'package:wwe_universe/database/titles_database_helper.dart';
import 'package:wwe_universe/pages/Superstars/superstars_detail_page.dart';
import 'package:wwe_universe/pages/Titles/add_edit_titles_page.dart';

class TitlesDetailPage extends StatefulWidget {
  final int titleId;

  const TitlesDetailPage({
    super.key,
    required this.titleId,
    
  });

  @override
  TitlesDetailPageState createState() => TitlesDetailPageState();
}

class TitlesDetailPageState extends State<TitlesDetailPage> {
  Titles title = const Titles(name: '', tag: 0, brand: null, holder1: null, holder2: null);
  Superstars h1 = const Superstars(name: 'nom', brand: null, orientation: 'orientation', division: null); 
  Superstars h2 = const Superstars(name: 'nom', brand: null, orientation: 'orientation', division: null);
  bool isLoading = false;
  

  @override
  void initState() {
    super.initState();

    refreshTitle();
  }

  Future<void> refreshTitle() async {
    setState(() => isLoading = true);

    title = await TitlesDatabaseHelper.readTitle(widget.titleId);

    if (title.holder1 != null) {
      h1 = await SuperstarsDatabaseHelper.readSuperstar(title.holder1!.id!);
    } else {
      h1 = const Superstars(
        name: 'nom',
        brand: null,
        orientation: 'orientation',
        division: null,
      );
    }

    if (title.holder2 != null) {
      h2 = await SuperstarsDatabaseHelper.readSuperstar(title.holder2!.id!);
    } else {
      h2 = const Superstars(
        name: 'nom',
        brand: null,
        orientation: 'orientation',
        division: null,
      );
    }

    if (!mounted) return;
    setState(() => isLoading = false);
  }
  
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Title details'),
      actions: [
        editButton(),
        deleteButton(),
      ],
    ),
    body: isLoading
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Title identity card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B1B1B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF383838),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CHAMPIONSHIP',
                      style: TextStyle(
                        color: Color(0xFFD71920),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      title.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Color(0xFF383838)),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      Icons.branding_watermark_outlined,
                      'Brand',
                      title.brand?.name ?? 'None',
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      Icons.emoji_events_outlined,
                      'Title type',
                      title.tag == 1 ? 'Tag Team' : 'Singles',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Current champion(s)
              const Text(
                'CURRENT CHAMPION',
                style: TextStyle(
                  color: Color(0xFFD71920),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              if (title.holder1 != null)
                _buildChampionCard(h1.name)
              else
                _buildEmptyChampionCard(),
              if (title.tag == 1) ...[
                const SizedBox(height: 10),
                if (title.holder2 != null)
                  _buildChampionCard(h2.name)
                else
                  _buildEmptyChampionCard(),
              ],
            ],
          ),
  );

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFD71920), size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFFAAAAAA),
              fontSize: 15,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChampionCard(String name) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF222222),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF383838)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF351719),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.person,
              color: Color(0xFFD71920),
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Icon(
            Icons.emoji_events,
            color: Color(0xFFD71920),
            size: 22,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChampionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1B1B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF383838)),
      ),
      child: const Row(
        children: [
          Icon(Icons.person_outline, color: Color(0xFF888888)),
          SizedBox(width: 12),
          Text(
            'No champion assigned',
            style: TextStyle(color: Color(0xFFAAAAAA)),
          ),
        ],
      ),
    );
  }

  Widget editButton() => IconButton(
    icon: const Icon(Icons.edit_outlined),
    tooltip: 'Edit title',
    onPressed: () async {
      final updated = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (context) => AddEditTitlesPage(title: title),
        ),
      );

      if (updated == true && mounted) {
        await refreshTitle();
      }
    },
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
        await TitlesDatabaseHelper.deleteTitle(widget.titleId);
        if(context.mounted){
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        }
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Confirmation"),
      content: const Text("Are you sure you want to delete this title ?"),
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