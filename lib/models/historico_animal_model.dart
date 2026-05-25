class HistoricoAnimalModel {
  final String id;
  final String animalId;
  final String tipo;
  final double valor;
  final String? pastoOrigemId;
  final String? pastoDestinoId;
  final DateTime data;

  HistoricoAnimalModel({
    required this.id,
    required this.animalId,
    required this.tipo,
    required this.valor,
    this.pastoOrigemId,
    this.pastoDestinoId,
    required this.data,
  });

  factory HistoricoAnimalModel.fromMap(
    Map<String, dynamic> map,
    String docId,
  ) {
    return HistoricoAnimalModel(
      id: docId,
      animalId: map['animalId'] ?? '',
      tipo: map['tipo'] ?? '',
      valor: (map['valor'] ?? 0).toDouble(),
      pastoOrigemId: map['pastoOrigemId'],
      pastoDestinoId: map['pastoDestinoId'],
      data: DateTime.parse(map['data']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'animalId': animalId,
      'tipo': tipo,
      'valor': valor,
      'pastoOrigemId': pastoOrigemId,
      'pastoDestinoId': pastoDestinoId,
      'data': data.toIso8601String(),
    };
  }
}
