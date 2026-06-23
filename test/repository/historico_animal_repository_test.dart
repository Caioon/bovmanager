import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:bov_manager/repositories/historico_animal_repository.dart';
import 'package:bov_manager/models/historico_tipo.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late HistoricoAnimalRepositoryImpl repository;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repository = HistoricoAnimalRepositoryImpl(firestore);
  });

  group('HistoricoAnimalRepository', () {
    test('listar() deve retornar históricos do animal', () async {
      await firestore
          .collection('animais')
          .doc('animal123')
          .collection('historico')
          .add({
        'animalId': 'animal123',
        'tipo': 'pesagem',
        'novoPeso': 450,
        'data': DateTime(2026, 1, 10).toIso8601String(),
      });

      final result = await repository.listar(
        animalId: 'animal123',
      ).first;

      expect(result.length, 1);
      expect(result.first.animalId, 'animal123');
      expect(result.first.novoPeso, 450);
    });

    test('criarHistorico() deve adicionar histórico usando batch', () async {
      final batch = firestore.batch();

      await repository.criarHistorico(
        animalId: 'animal123',
        tipo: HistoricoTipo.pesagem,
        novoPeso: 500,
        data: DateTime(2026, 1, 10),
        pastoOrigemId: 'pasto1',
        pastoDestinoId: 'pasto2',
        rebanhoOrigemId: 'rebanho1',
        rebanhoDestinoId: 'rebanho2',
        nomePastoOrigem: 'Pasto A',
        nomePastoDestino: 'Pasto B',
        nomeRebanhoOrigem: 'Rebanho A',
        nomeRebanhoDestino: 'Rebanho B',
        batch: batch,
      );

      await batch.commit();

      final snapshot = await firestore
          .collection('animais')
          .doc('animal123')
          .collection('historico')
          .get();

      expect(snapshot.docs.length, 1);

      final data = snapshot.docs.first.data();

      expect(data['animalId'], 'animal123');
      expect(data['novoPeso'], 500);
      expect(data['pastoOrigemId'], 'pasto1');
      expect(data['pastoDestinoId'], 'pasto2');
      expect(data['rebanhoOrigemId'], 'rebanho1');
      expect(data['rebanhoDestinoId'], 'rebanho2');
      expect(data['nomePastoOrigem'], 'Pasto A');
      expect(data['nomePastoDestino'], 'Pasto B');
      expect(data['data'], DateTime(2026, 1, 10).toIso8601String());
    });

    test('apagarTodosHistoricosAnimal() deve remover todos os históricos usando batch', () async {
      final col = firestore
          .collection('animais')
          .doc('animal123')
          .collection('historico');

      await col.add({
        'animalId': 'animal123',
        'tipo': 'pesagem',
        'data': DateTime.now().toIso8601String(),
      });

      await col.add({
        'animalId': 'animal123',
        'tipo': 'entrada',
        'data': DateTime.now().toIso8601String(),
      });

      final batch = firestore.batch();

      await repository.apagarTodosHistoricosAnimal(
        animalId: 'animal123',
        batch: batch,
      );

      await batch.commit();

      final snapshot = await col.get();

      expect(snapshot.docs, isEmpty);
    });

    test('buscarUltimaMovimentacao() deve retornar movimentação mais recente', () async {
      final col = firestore
          .collection('animais')
          .doc('animal123')
          .collection('historico');

      await col.add({
        'animalId': 'animal123',
        'tipo': 'entrada',
        'data': DateTime(2026, 1, 1).toIso8601String(),
      });

      await col.add({
        'animalId': 'animal123',
        'tipo': 'mudar_pasto_com_rebanho',
        'data': DateTime(2026, 2, 1).toIso8601String(),
      });

      final result = await repository.buscarUltimaMovimentacao(
        animalId: 'animal123',
      );

      expect(result, isNotNull);
      expect(result!.tipo.valor, 'mudar_pasto_com_rebanho');
    });

    test('buscarUltimaMovimentacao() deve retornar null quando não houver movimentação', () async {
      final result = await repository.buscarUltimaMovimentacao(
        animalId: 'animal123',
      );

      expect(result, null);
    });
  });
}
