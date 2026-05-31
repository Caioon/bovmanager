import 'package:bov_manager/models/historico_tipo.dart';

class HistoricoAnimalModel {
  final String id;
  final String animalId;
  final HistoricoTipo tipo;
  final double? novoPeso;
  final String? pastoOrigemId;
  final String? pastoDestinoId;
  final String? rebanhoOrigemId;
  final String? rebanhoDestinoId;
  final DateTime data;

  HistoricoAnimalModel({
    required this.id,
    required this.animalId,
    required this.tipo,
    this.novoPeso,
    this.pastoOrigemId,
    this.pastoDestinoId,
    this.rebanhoOrigemId,
    this.rebanhoDestinoId,
    required this.data,
  });

  factory HistoricoAnimalModel.fromMap(Map<String, dynamic> map, String docId) {
    return HistoricoAnimalModel(
      id: docId,
      animalId: map['animalId'] ?? '',
      tipo: HistoricoTipo.fromValor(map['tipo'] ?? ''),
      novoPeso: map['novoPeso']?.toDouble(),
      pastoOrigemId: map['pastoOrigemId'],
      pastoDestinoId: map['pastoDestinoId'],
      rebanhoOrigemId: map['rebanhoOrigemId'],
      rebanhoDestinoId: map['rebanhoDestinoId'],
      data: DateTime.parse(map['data']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'animalId': animalId,
      'tipo': tipo.valor,
      'novoPeso': novoPeso,
      'pastoOrigemId': pastoOrigemId,
      'pastoDestinoId': pastoDestinoId,
      'rebanhoOrigemId': rebanhoOrigemId,
      'rebanhoDestinoId': rebanhoDestinoId,
      'data': data.toIso8601String(),
    };
  }
}
