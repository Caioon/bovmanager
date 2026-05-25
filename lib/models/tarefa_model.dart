enum StatusTarefa {
  pendente,
  concluida,
}

class TarefaModel {
  final String id;
  final String titulo;
  final String descricao;
  final DateTime dataExecucao;
  final StatusTarefa status;
  final String propriedadeId;
  final String usuarioId;

  TarefaModel({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.dataExecucao,
    required this.status,
    required this.propriedadeId,
    required this.usuarioId,
  });

  factory TarefaModel.fromMap(
    Map<String, dynamic> map,
    String docId,
  ) {
    return TarefaModel(
      id: docId,
      titulo: map['titulo'] ?? '',
      descricao: map['descricao'] ?? '',
      dataExecucao: DateTime.parse(map['dataExecucao']),
      status: StatusTarefa.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => StatusTarefa.pendente,
      ),
      propriedadeId: map['propriedadeId'] ?? '',
      usuarioId: map['usuarioId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'descricao': descricao,
      'dataExecucao': dataExecucao.toIso8601String(),
      'status': status.name,
      'propriedadeId': propriedadeId,
      'usuarioId': usuarioId,
    };
  }
}
