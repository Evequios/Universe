const String tableMatchTypeFormats = 'match_type_formats';
class MatchTypeFormatsFields {
  static const matchTypeId = 'matchTypeId', matchFormatId = 'matchFormatId';
}
class MatchTypeFormats {
  final int matchTypeId;
  final int matchFormatId;
  const MatchTypeFormats({required this.matchTypeId, required this.matchFormatId});
  Map<String, Object?> toJson() => {MatchTypeFormatsFields.matchTypeId:matchTypeId, MatchTypeFormatsFields.matchFormatId:matchFormatId};
}
