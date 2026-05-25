class PropriedadeModel {
  final String id;
  final String nome;
  final String proprietarioId;
  final DateTime dataCadastro;

  PropriedadeModel({
    required this.id,
    required this.nome,
    required this.proprietarioId,
    required this.dataCadastro,
  });

  factory PropriedadeModel.fromMap(
    Map<String, dynamic> map,
    String docId,
  ) {
    return PropriedadeModel(
      id: docId,
      nome: map['nome'] ?? '',
      proprietarioId: map['proprietarioId'] ?? '',
      dataCadastro: DateTime.parse(map['dataCadastro']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'proprietarioId': proprietarioId,
      'dataCadastro': dataCadastro.toIso8601String(),
    };
  }
}
