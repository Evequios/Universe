import 'package:flutter/material.dart';

const List<String> listTypes = <String>['1v1', '2v2', 'Triple Threat', 'Fatal 4-Way', '5-Way', '6-Way', '3-Way Tag', '3v3', '8-Way', '4v4', '4-Way Tag', 'Handicap 1v2', 'Handicap 1v3', 'Handicap 2v3', '10 Man', '20 Man', '30 Man'];
const List<String> listStipulations = <String>['Normal', 'Falls Count Anywhere', 'Extreme Rules', 'Ladder', 'Table', 'TLC', 'Hell In A Cell', 'Steel Cage', 'Iron Man', 'Last Man Standing', 'No Holds Barred', 'Submission', 'Backstage Brawl', 'Tonardo Tag', 'Mixed Gender Tag', 'Battle Royal', 'Elimination Chamber', 'Royal Rumble', '2 out of 3 Falls', 'Over The Top Rope', 'K.O', 'First Blood', 'WarGames'];

class StipulationsFormWidget extends StatelessWidget {
  final String? type;
  final String? stipulation;
  final ValueChanged<String?> onChangedType;
  final ValueChanged<String?> onChangedStipulation;


  const StipulationsFormWidget({
    super.key,
    this.type = '',
    this.stipulation,
    required this.onChangedType,
    required this.onChangedStipulation,
  });

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildType(),
          const SizedBox(height: 8),
          buildStipulation(),
        ],
      ),
    ),
  );

  Widget buildType() => 
    ButtonTheme( 
      alignedDropdown: true, 
      child: DropdownButtonFormField(
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: 'Type',
        labelStyle: TextStyle(color: Colors.black87.withOpacity(0.5)),
      ),
        value: type != '' && type != null ? type : null,
        onChanged: onChangedType,
        items: listTypes.map((type){
        return DropdownMenuItem(
          value: type != '' ? type : listTypes[0],
          child: Text(type));
      }).toList(),
      ));

  Widget buildStipulation() => 
    ButtonTheme( 
      alignedDropdown: true, 
      child: DropdownButtonFormField(
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: 'Stipulation',
        labelStyle: TextStyle(color: Colors.black87.withOpacity(0.5)),
      ),
        value: stipulation != '' && stipulation != null ? stipulation : null,
        onChanged: onChangedStipulation,
        items: listStipulations.map((stipulation){
        return DropdownMenuItem(
          value: stipulation != '' ? stipulation : listStipulations[0],
          child: Text(stipulation));
      }).toList(),
      ));
}