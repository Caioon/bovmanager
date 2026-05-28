//Classe seria usada em caso de uso de Firebase Cloud Functions, pra ter notificações push.
//Atualmente o app tem notificações locais, por isso o modelo não é usado.
class NotificacaoModel {
  final String id;
  final String tarefaId;
  final String usuarioId;
  final String mensagem;
  final bool enviada;
  final DateTime dataEnvio;

  NotificacaoModel({
    required this.id,
    required this.tarefaId,
    required this.usuarioId,
    required this.mensagem,
    required this.enviada,
    required this.dataEnvio,
  });

  factory NotificacaoModel.fromMap(
    Map<String, dynamic> map,
    String docId,
  ) {
    return NotificacaoModel(
      id: docId,
      tarefaId: map['tarefaId'] ?? '',
      usuarioId: map['usuarioId'] ?? '',
      mensagem: map['mensagem'] ?? '',
      enviada: map['enviada'] ?? false,
      dataEnvio: DateTime.parse(map['dataEnvio']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tarefaId': tarefaId,
      'usuarioId': usuarioId,
      'mensagem': mensagem,
      'enviada': enviada,
      'dataEnvio': dataEnvio.toIso8601String(),
    };
  }
}
