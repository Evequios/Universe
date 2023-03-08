class IRLTitles{
  final String? id;
  final String nom;
  final String tag;
  final String show;
  final String holder1;
  final String holder2;

  const IRLTitles({
    this.id,
    required this.nom,
    required this.tag,
    required this.show,
    required this.holder1,
    required this.holder2,
  });

  static IRLTitles fromJson(Map<String, dynamic> json) => IRLTitles(
        id: json['id'],
        nom: json['nom'],
        tag: json['tag'],
        show: json['show'],
        holder1: json['holder1'],
        holder2: json['holder2']
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nom': nom,
        'tag': tag,
        'show' : show,
        'holder1': holder1,
        'holder2': holder2
      };
}
