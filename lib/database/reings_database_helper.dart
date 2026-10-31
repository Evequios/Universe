import 'package:wwe_universe/classes/reigns.dart';
import 'package:wwe_universe/database/superstars_database_helper.dart';

class ReignsDatabaseHelper {
  static Future<Reigns> _fromMap(Map<String, dynamic> json) async {
    final holder1 = await SuperstarsDatabaseHelper.readSuperstar(json[ReignsFields.holder1]);
    final holder2 = json[ReignsFields.holder2] != null ? await SuperstarsDatabaseHelper.readSuperstar(json[ReignsFields.holder2]) : null;
    return Reigns(
      id: json[ReignsFields.id] as int?,
      holder1: holder1,
      holder2: holder2,
      titleId: json[ReignsFields.titleId] as int,
      yearDebut: json[ReignsFields.yearDebut] as int,
      weekDebut: json[ReignsFields.weekDebut] as int,
      yearEnd: json[ReignsFields.yearEnd] as int?,
      weekEnd: json[ReignsFields.weekEnd] as int?
    );
  }
}