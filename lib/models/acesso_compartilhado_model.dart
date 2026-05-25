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
