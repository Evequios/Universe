import 'package:sqflite/sqflite.dart';
import 'package:wwe_universe/database/database.dart';
import 'package:wwe_universe/classes/superstar_relationship.dart';
class SuperstarRelationshipsDatabaseHelper {
 static Future<List<int>> readRelatedIds(int id,String type) async {
  final db=await DatabaseService.instance.database;
  final rows=await db.query(tableSuperstarRelationships,columns:[SuperstarRelationshipFields.relatedSuperstarId],where:'${SuperstarRelationshipFields.superstarId} = ? AND ${SuperstarRelationshipFields.type} = ?',whereArgs:[id,type]);
  return rows.map((e)=>e[SuperstarRelationshipFields.relatedSuperstarId] as int).toList();
 }
 static Future<void> replaceRelations(int id,String type,List<int> ids) async {
  final db=await DatabaseService.instance.database; final values=ids.where((v)=>v!=id).toSet();
  await db.transaction((txn) async {
   await txn.delete(tableSuperstarRelationships,where:'${SuperstarRelationshipFields.superstarId} = ? AND ${SuperstarRelationshipFields.type} = ?',whereArgs:[id,type]);
   for(final related in values){await txn.insert(tableSuperstarRelationships,{SuperstarRelationshipFields.superstarId:id,SuperstarRelationshipFields.relatedSuperstarId:related,SuperstarRelationshipFields.type:type},conflictAlgorithm:ConflictAlgorithm.ignore);}
  });
 }
 static Future<List<int>> readMatchManagers(int matchId,int participantId) async {
  final db=await DatabaseService.instance.database; final rows=await db.query(tableMatchParticipantManagers,columns:[MatchParticipantManagerFields.managerSuperstarId],where:'${MatchParticipantManagerFields.matchId} = ? AND ${MatchParticipantManagerFields.participantSuperstarId} = ?',whereArgs:[matchId,participantId]);
  return rows.map((e)=>e[MatchParticipantManagerFields.managerSuperstarId] as int).toList();
 }
 static Future<bool> hasMatchManagerOverride(int matchId,int participantId) async {
  final db=await DatabaseService.instance.database; final rows=await db.query(tableMatchParticipantManagerOverrides,where:'match_id = ? AND participant_superstar_id = ?',whereArgs:[matchId,participantId],limit:1); return rows.isNotEmpty;
 }
 static Future<void> replaceMatchManagers(int matchId,int participantId,List<int> ids) async {
  final db=await DatabaseService.instance.database;
  await db.transaction((txn) async {
   await txn.insert(tableMatchParticipantManagerOverrides,{'match_id':matchId,'participant_superstar_id':participantId},conflictAlgorithm:ConflictAlgorithm.ignore);
   await txn.delete(tableMatchParticipantManagers,where:'${MatchParticipantManagerFields.matchId} = ? AND ${MatchParticipantManagerFields.participantSuperstarId} = ?',whereArgs:[matchId,participantId]);
   for(final id in ids.toSet()){if(id==participantId) continue; await txn.insert(tableMatchParticipantManagers,{MatchParticipantManagerFields.matchId:matchId,MatchParticipantManagerFields.participantSuperstarId:participantId,MatchParticipantManagerFields.managerSuperstarId:id},conflictAlgorithm:ConflictAlgorithm.ignore);}
  });
 }
}
