class RebanhoModel {
  final String id;
  final String nome;
  final String pastoId;
  final String propriedadeId;
  final DateTime dataCadastro;

  RebanhoModel({
    required this.id,
    required this.nome,
    required this.pastoId,
    required this.propriedadeId,
    required this.dataCadastro,
  });

  factory RebanhoModel.fromMap(
    Map<String, dynamic> map,
    String docId,
  ) {
    return RebanhoModel(
      id: docId,
      nome: map['nome'] ?? '',
      pastoId: map['pastoId'] ?? '',
      propriedadeId: map['propriedadeId'] ?? '',
      dataCadastro: DateTime.parse(map['dataCadastro']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'pastoId': pastoId,
      'propriedadeId': propriedadeId,
      'dataCadastro': dataCadastro.toIso8601String(),
    };
  }
}
