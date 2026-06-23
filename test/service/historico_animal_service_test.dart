import 'package:bov_manager/repositories/historico_animal_repository.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bov_manager/models/historico_animal_model.dart';
import 'package:bov_manager/models/historico_tipo.dart';
import 'package:bov_manager/services/historico_animal_service.dart';

class MockHistoricoAnimalRepository extends HistoricoAnimalRepository {
  final List<HistoricoAnimalModel> historicos = [];

  bool criou = false;
  bool apagou = false;

  @override
  Future<void> criarHistorico({
    required String animalId,
    required HistoricoTipo tipo,
    required double? novoPeso,
    required DateTime data,
    String? pastoOrigemId,
    String? pastoDestinoId,
    String? rebanhoOrigemId,
    String? rebanhoDestinoId,
    String? nomePastoOrigem,
    String? nomePastoDestino,
    String? nomeRebanhoOrigem,
    String? nomeRebanhoDestino,
    required WriteBatch batch,
  }) async {
    criou = true;
  }

  @override
  Stream<List<HistoricoAnimalModel>> listar({required String animalId}) {
    return Stream.value(
      historicos.where((h) => h.animalId == animalId).toList(),
    );
  }

  @override
  Future<void> apagarTodosHistoricosAnimal({
    required String animalId,
    required WriteBatch batch,
  }) async {
    apagou = true;
  }

  @override
  Future<HistoricoAnimalModel?> buscarUltimaMovimentacao({
    required String animalId,
  }) async {
    final lista = historicos.where((h) => h.animalId == animalId).toList();

    if (lista.isEmpty) return null;

    return lista.last;
  }
}

void main() {
  group('HistoricoAnimalService', () {
    late MockHistoricoAnimalRepository repo;
    late HistoricoAnimalService service;

    final historico = HistoricoAnimalModel(
      id: 'historico123',
      animalId: 'animal123',
      tipo: HistoricoTipo.entrada,
      novoPeso: 400,
      data: DateTime(2026),
      pastoDestinoId: 'pasto123',
    );

    setUp(() {
      repo = MockHistoricoAnimalRepository();
      service = HistoricoAnimalService(repo as dynamic);
    });

    test('listar() deve retornar históricos do animal', () async {
      repo.historicos.add(historico);

      final result = await service.listar('animal123').first;

      expect(result.length, 1);
      expect(result.first.id, 'historico123');
      expect(result.first.animalId, 'animal123');
    });

    test('criarHistorico() deve chamar criação no repositório', () async {
      final firestore = FakeFirebaseFirestore();
      final batch = firestore.batch();

      await service.criarHistorico(
        animalId: 'animal123',
        tipo: HistoricoTipo.entrada,
        novoPeso: 400,
        data: DateTime(2026),
        batch: batch,
      );

      expect(repo.criou, true);
    });

    test(
      'apagarTodosHistoricosAnimal() deve chamar remoção no repositório',
      () async {
        final firestore = FakeFirebaseFirestore();
        final batch = firestore.batch();

        await service.apagarTodosHistoricosAnimal(
          animalId: 'animal123',
          batch: batch,
        );

        expect(repo.apagou, true);
      },
    );

    test('buscarUltimaMovimentacao() deve retornar último histórico', () async {
      repo.historicos.add(historico);

      final result = await service.buscarUltimaMovimentacao(
        animalId: 'animal123',
      );

      expect(result, isNotNull);
      expect(result!.id, 'historico123');
      expect(result.animalId, 'animal123');
    });

    test(
      'buscarUltimaMovimentacao() sem histórico deve retornar null',
      () async {
        final result = await service.buscarUltimaMovimentacao(
          animalId: 'animal123',
        );

        expect(result, null);
      },
    );
  });
}
