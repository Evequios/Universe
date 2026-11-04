const String tableSuperstarRelationships = 'superstar_relationships';
const String tableMatchParticipantManagers = 'match_participant_managers';
class SuperstarRelationshipFields {
 static const String superstarId='superstar_id';
 static const String relatedSuperstarId='related_superstar_id';
 static const String type='relationship_type';
}
class MatchParticipantManagerFields {
 static const String id='_id';
 static const String matchId='match_id';
 static const String participantSuperstarId='participant_superstar_id';
 static const String managerSuperstarId='manager_superstar_id';
}

const String tableMatchParticipantManagerOverrides = 'match_participant_manager_overrides';
