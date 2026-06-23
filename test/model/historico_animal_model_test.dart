import 'package:flutter_test/flutter_test.dart';
import 'package:bov_manager/models/historico_animal_model.dart';
import 'package:bov_manager/models/historico_tipo.dart';

void main() {
  group('HistoricoAnimalModel', () {
    final data = DateTime(2026, 1, 10, 12, 30);

    final historico = HistoricoAnimalModel(
      id: 'hist123',
      animalId: 'animal123',
      tipo: HistoricoTipo.pesagem,
      novoPeso: 450.5,
      pastoOrigemId: 'pastoOrigem123',
      pastoDestinoId: 'pastoDestino123',
      rebanhoOrigemId: 'rebanhoOrigem123',
      rebanhoDestinoId: 'rebanhoDestino123',
      data: data,
      nomePastoOrigem: 'Pasto A',
      nomePastoDestino: 'Pasto B',
      nomeRebanhoOrigem: 'Rebanho A',
      nomeRebanhoDestino: 'Rebanho B',
    );

    test('toMap() deve converter todos os campos corretamente', () {
      final map = historico.toMap();

      expect(map['animalId'], 'animal123');
      expect(map['tipo'], historico.tipo.valor);
      expect(map['novoPeso'], 450.5);
      expect(map['pastoOrigemId'], 'pastoOrigem123');
      expect(map['pastoDestinoId'], 'pastoDestino123');
      expect(map['rebanhoOrigemId'], 'rebanhoOrigem123');
      expect(map['rebanhoDestinoId'], 'rebanhoDestino123');
      expect(map['data'], data.toIso8601String());
      expect(map['nomePastoOrigem'], 'Pasto A');
      expect(map['nomePastoDestino'], 'Pasto B');
      expect(map['nomeRebanhoOrigem'], 'Rebanho A');
      expect(map['nomeRebanhoDestino'], 'Rebanho B');
    });

    test('HistoricoAnimalModel.fromMap() deve criar objeto corretamente', () {
      final map = {
        'animalId': 'animal123',
        'tipo': historico.tipo.valor,
        'novoPeso': 450.5,
        'pastoOrigemId': 'pastoOrigem123',
        'pastoDestinoId': 'pastoDestino123',
        'rebanhoOrigemId': 'rebanhoOrigem123',
        'rebanhoDestinoId': 'rebanhoDestino123',
        'data': data.toIso8601String(),
        'nomePastoOrigem': 'Pasto A',
        'nomePastoDestino': 'Pasto B',
        'nomeRebanhoOrigem': 'Rebanho A',
        'nomeRebanhoDestino': 'Rebanho B',
      };

      final result = HistoricoAnimalModel.fromMap(map, 'hist123');

      expect(result.id, 'hist123');
      expect(result.animalId, 'animal123');
      expect(result.tipo, historico.tipo);
      expect(result.novoPeso, 450.5);
      expect(result.pastoOrigemId, 'pastoOrigem123');
      expect(result.pastoDestinoId, 'pastoDestino123');
      expect(result.rebanhoOrigemId, 'rebanhoOrigem123');
      expect(result.rebanhoDestinoId, 'rebanhoDestino123');
      expect(result.data, data);
      expect(result.nomePastoOrigem, 'Pasto A');
      expect(result.nomePastoDestino, 'Pasto B');
      expect(result.nomeRebanhoOrigem, 'Rebanho A');
      expect(result.nomeRebanhoDestino, 'Rebanho B');
    });

    test('Round-trip toMap() → fromMap() deve manter todos os valores', () {
      final map = historico.toMap();

      final result = HistoricoAnimalModel.fromMap(map, historico.id);

      expect(result.id, historico.id);
      expect(result.animalId, historico.animalId);
      expect(result.tipo, historico.tipo);
      expect(result.novoPeso, historico.novoPeso);
      expect(result.pastoOrigemId, historico.pastoOrigemId);
      expect(result.pastoDestinoId, historico.pastoDestinoId);
      expect(result.rebanhoOrigemId, historico.rebanhoOrigemId);
      expect(result.rebanhoDestinoId, historico.rebanhoDestinoId);
      expect(result.data, historico.data);
      expect(result.nomePastoOrigem, historico.nomePastoOrigem);
      expect(result.nomePastoDestino, historico.nomePastoDestino);
      expect(result.nomeRebanhoOrigem, historico.nomeRebanhoOrigem);
      expect(result.nomeRebanhoDestino, historico.nomeRebanhoDestino);
    });

    test(
      'fromMap() com campos opcionais ausentes deve manter valores null',
      () {
        final map = {
          'animalId': 'animal123',
          'tipo': historico.tipo.valor,
          'data': data.toIso8601String(),
        };

        final result = HistoricoAnimalModel.fromMap(map, 'hist123');

        expect(result.id, 'hist123');
        expect(result.animalId, 'animal123');
        expect(result.tipo, historico.tipo);
        expect(result.novoPeso, null);
        expect(result.pastoOrigemId, null);
        expect(result.pastoDestinoId, null);
        expect(result.rebanhoOrigemId, null);
        expect(result.rebanhoDestinoId, null);
        expect(result.data, data);
        expect(result.nomePastoOrigem, null);
        expect(result.nomePastoDestino, null);
        expect(result.nomeRebanhoOrigem, null);
        expect(result.nomeRebanhoDestino, null);
      },
    );
  });
}
