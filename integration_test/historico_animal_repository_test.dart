import 'package:bov_manager/models/historico_tipo.dart';
import 'package:bov_manager/repositories/historico_animal_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'firebase_test_setup.dart';

void main() {
  late HistoricoAnimalRepository repository;
  late FirebaseFirestore firestore;

  setUpAll(() async {
    await setupFirebaseEmulator();
    firestore = FirebaseFirestore.instance;
    repository = HistoricoAnimalRepositoryImpl(firestore);
  });

  setUp(() async {
    await clearFirestoreEmulator();
  });

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  CollectionReference<Map<String, dynamic>> _historicoCol(String animalId) =>
      firestore.collection('animais').doc(animalId).collection('historico');

  /// Garante que o documento pai existe antes de criar históricos (subcoleção).
  Future<void> _criarAnimalDoc(String animalId) async {
    await firestore.collection('animais').doc(animalId).set({'nome': 'Test'});
  }

  Future<void> _criarHistorico({
    required String animalId,
    HistoricoTipo tipo = HistoricoTipo.entrada,
    DateTime? data,
  }) async {
    final batch = firestore.batch();
    await repository.criarHistorico(
      animalId: animalId,
      tipo: tipo,
      novoPeso: null,
      data: data ?? DateTime(2024, 1, 1),
      batch: batch,
    );
    await batch.commit();
  }

  // ---------------------------------------------------------------------------
  // criarHistorico
  // ---------------------------------------------------------------------------

  group('criarHistorico', () {
    test('persiste o documento na subcoleção historico do animal', () async {
      await _criarAnimalDoc('animal-1');

      await _criarHistorico(animalId: 'animal-1', tipo: HistoricoTipo.entrada);

      final snap = await _historicoCol('animal-1').get();
      expect(snap.docs, hasLength(1));
      expect(snap.docs.first.data()['tipo'], HistoricoTipo.entrada.valor);
      expect(snap.docs.first.data()['animalId'], 'animal-1');
    });

    test('persiste campos opcionais quando informados', () async {
      await _criarAnimalDoc('animal-1');

      final batch = firestore.batch();
      await repository.criarHistorico(
        animalId: 'animal-1',
        tipo: HistoricoTipo.mudarRebanho,
        novoPeso: 420.5,
        data: DateTime(2024, 6, 1),
        pastoOrigemId: 'pasto-origem',
        pastoDestinoId: 'pasto-destino',
        rebanhoOrigemId: 'rebanho-origem',
        rebanhoDestinoId: 'rebanho-destino',
        nomePastoOrigem: 'Pasto A',
        nomePastoDestino: 'Pasto B',
        nomeRebanhoOrigem: 'Rebanho X',
        nomeRebanhoDestino: 'Rebanho Y',
        batch: batch,
      );
      await batch.commit();

      final doc = (await _historicoCol('animal-1').get()).docs.first.data();
      expect(doc['novoPeso'], 420.5);
      expect(doc['pastoOrigemId'], 'pasto-origem');
      expect(doc['pastoDestinoId'], 'pasto-destino');
      expect(doc['rebanhoOrigemId'], 'rebanho-origem');
      expect(doc['rebanhoDestinoId'], 'rebanho-destino');
      expect(doc['nomePastoOrigem'], 'Pasto A');
      expect(doc['nomePastoDestino'], 'Pasto B');
      expect(doc['nomeRebanhoOrigem'], 'Rebanho X');
      expect(doc['nomeRebanhoDestino'], 'Rebanho Y');
    });

    test('cria documentos independentes para cada chamada', () async {
      await _criarAnimalDoc('animal-1');

      await _criarHistorico(animalId: 'animal-1', tipo: HistoricoTipo.entrada);
      await _criarHistorico(animalId: 'animal-1', tipo: HistoricoTipo.pesagem);

      final snap = await _historicoCol('animal-1').get();
      expect(snap.docs, hasLength(2));
    });
  });

  // ---------------------------------------------------------------------------
  // apagarTodosHistoricosAnimal
  // ---------------------------------------------------------------------------

  group('apagarTodosHistoricosAnimal', () {
    test('remove todos os documentos da subcoleção', () async {
      await _criarAnimalDoc('animal-1');
      await _criarHistorico(animalId: 'animal-1', tipo: HistoricoTipo.entrada);
      await _criarHistorico(animalId: 'animal-1', tipo: HistoricoTipo.pesagem);

      final batch = firestore.batch();
      await repository.apagarTodosHistoricosAnimal(
        animalId: 'animal-1',
        batch: batch,
      );
      await batch.commit();

      final snap = await _historicoCol('animal-1').get();
      expect(snap.docs, isEmpty);
    });

    test('não afeta históricos de outro animal', () async {
      await _criarAnimalDoc('animal-1');
      await _criarAnimalDoc('animal-2');
      await _criarHistorico(animalId: 'animal-1');
      await _criarHistorico(animalId: 'animal-2');

      final batch = firestore.batch();
      await repository.apagarTodosHistoricosAnimal(
        animalId: 'animal-1',
        batch: batch,
      );
      await batch.commit();

      final snap = await _historicoCol('animal-2').get();
      expect(snap.docs, hasLength(1));
    });

    test('não falha quando a subcoleção já está vazia', () async {
      await _criarAnimalDoc('animal-1');

      final batch = firestore.batch();
      await expectLater(
        repository.apagarTodosHistoricosAnimal(
          animalId: 'animal-1',
          batch: batch,
        ),
        completes,
      );
      await batch.commit();
    });
  });

  // ---------------------------------------------------------------------------
  // buscarUltimaMovimentacao
  // ---------------------------------------------------------------------------

  group('buscarUltimaMovimentacao', () {
    test('retorna null quando não há movimentações', () async {
      await _criarAnimalDoc('animal-1');

      // Apenas pesagem — não é movimentação
      await _criarHistorico(animalId: 'animal-1', tipo: HistoricoTipo.pesagem);

      final resultado = await repository.buscarUltimaMovimentacao(
        animalId: 'animal-1',
      );
      expect(resultado, isNull);
    });

    test('retorna a movimentação mais recente ignorando pesagens', () async {
      await _criarAnimalDoc('animal-1');

      await _criarHistorico(
        animalId: 'animal-1',
        tipo: HistoricoTipo.entrarRebanho,
        data: DateTime(2024, 1, 1),
      );
      await _criarHistorico(
        animalId: 'animal-1',
        tipo: HistoricoTipo.mudarRebanho,
        data: DateTime(2024, 6, 1),
      );
      await _criarHistorico(
        animalId: 'animal-1',
        tipo: HistoricoTipo.pesagem,
        data: DateTime(2024, 9, 1),
      );

      final resultado = await repository.buscarUltimaMovimentacao(
        animalId: 'animal-1',
      );

      expect(resultado, isNotNull);
      expect(resultado!.tipo, HistoricoTipo.mudarRebanho);
    });

    test('reconhece todos os tipos de movimentação válidos', () async {
      final tiposMovimentacao = [
        HistoricoTipo.entrada,
        HistoricoTipo.entrarRebanho,
        HistoricoTipo.mudarRebanho,
        HistoricoTipo.sairRebanhoMudarPasto,
        HistoricoTipo.sairRebanhoManterPasto,
        HistoricoTipo.mudarPastoComRebanho,
      ];

      for (final tipo in tiposMovimentacao) {
        await clearFirestoreEmulator();
        await _criarAnimalDoc('animal-1');
        await _criarHistorico(animalId: 'animal-1', tipo: tipo);

        final resultado = await repository.buscarUltimaMovimentacao(
          animalId: 'animal-1',
        );
        expect(resultado, isNotNull, reason: 'Tipo ${tipo.valor} não retornado');
        expect(resultado!.tipo, tipo);
      }
    });
  });
}
