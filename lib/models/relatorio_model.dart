class RelatorioModel {
  final String id;
  final String propriedadeId;
  final String usuarioId;
  final DateTime dataGeracao;
  final String tipo;
  final String urlArquivo;

  RelatorioModel({
    required this.id,
    required this.propriedadeId,
    required this.usuarioId,
    required this.dataGeracao,
    required this.tipo,
    required this.urlArquivo,
  });

  factory RelatorioModel.fromMap(
    Map<String, dynamic> map,
    String docId,
  ) {
    return RelatorioModel(
      id: docId,
      propriedadeId: map['propriedadeId'] ?? '',
      usuarioId: map['usuarioId'] ?? '',
      dataGeracao: DateTime.parse(map['dataGeracao']),
      tipo: map['tipo'] ?? '',
      urlArquivo: map['urlArquivo'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'propriedadeId': propriedadeId,
      'usuarioId': usuarioId,
      'dataGeracao': dataGeracao.toIso8601String(),
      'tipo': tipo,
      'urlArquivo': urlArquivo,
    };
  }
}
