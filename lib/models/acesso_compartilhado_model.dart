//admin (pode editar e compartilhar)
//gerente (pode editar mas nao compartilhar)
//visualizador (pode visualizar)

//food for thought: e se o cara quiser fazer uma alteração e fizer cagada? como eu poderia desfazer? teria de ter um sistema de commits, nao?
//sei la, algum tipo de persistencia igual no postgres
class AcessoCompartilhadoModel {
  final String id;
  final String propriedadeId;
  final String usuarioId;
  final String papel;
  final DateTime dataConvite;

  AcessoCompartilhadoModel({
    required this.id,
    required this.propriedadeId,
    required this.usuarioId,
    required this.papel,
    required this.dataConvite,
  });

  factory AcessoCompartilhadoModel.fromMap(
    Map<String, dynamic> map,
    String docId,
  ) {
    return AcessoCompartilhadoModel(
      id: docId,
      propriedadeId: map['propriedadeId'] ?? '',
      usuarioId: map['usuarioId'] ?? '',
      papel: map['papel'] ?? '',
      dataConvite: DateTime.parse(map['dataConvite']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'propriedadeId': propriedadeId,
      'usuarioId': usuarioId,
      'papel': papel,
      'dataConvite': dataConvite.toIso8601String(),
    };
  }
}
