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
  final int? horaExecucaoMinutos; // minutos desde meia-noite, null = sem horário

  TarefaModel({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.dataExecucao,
    required this.status,
    required this.propriedadeId,
    required this.usuarioId,
    this.horaExecucaoMinutos,
  });

  /// Retorna o DateTime exato da execução quando horaExecucaoMinutos está definido.
  DateTime? get dataHoraExecucao {
    if (horaExecucaoMinutos == null) return null;
    return DateTime(
      dataExecucao.year,
      dataExecucao.month,
      dataExecucao.day,
      horaExecucaoMinutos! ~/ 60,
      horaExecucaoMinutos! % 60,
    );
  }

  TarefaModel copyWith({
    String? id,
    String? titulo,
    String? descricao,
    DateTime? dataExecucao,
    StatusTarefa? status,
    String? propriedadeId,
    String? usuarioId,
    int? horaExecucaoMinutos,
    bool clearHora = false, // true para setar horaExecucaoMinutos como null
  }) {
    return TarefaModel(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      dataExecucao: dataExecucao ?? this.dataExecucao,
      status: status ?? this.status,
      propriedadeId: propriedadeId ?? this.propriedadeId,
      usuarioId: usuarioId ?? this.usuarioId,
      horaExecucaoMinutos:
          clearHora ? null : (horaExecucaoMinutos ?? this.horaExecucaoMinutos),
    );
  }

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
      horaExecucaoMinutos: map['horaExecucaoMinutos'] as int?,
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
      'horaExecucaoMinutos': horaExecucaoMinutos,
    };
  }
}
