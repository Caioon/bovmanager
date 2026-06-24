import 'package:bov_manager/models/poligono_model.dart';
import 'package:bov_manager/repositories/poligono_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'firebase_test_setup.dart';

void main() {
  late PoligonoRepository repository;
  late FirebaseFirestore firestore;

  setUpAll(() async {
    await setupFirebaseEmulator();
    firestore = FirebaseFirestore.instance;
    repository = PoligonoRepository(firestore);
  });

  setUp(() async {
    await clearFirestoreEmulator();
  });

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  CollectionReference<Map<String, dynamic>> _poligonosCol(
    String propriedadeId,
  ) => firestore
      .collection('propriedades')
      .doc(propriedadeId)
      .collection('poligonos');

  final _pontosA = [
    const LatLngPoint(lat: -20.0, lng: -50.0),
    const LatLngPoint(lat: -20.1, lng: -50.1),
    const LatLngPoint(lat: -20.2, lng: -50.0),
  ];

  final _pontosB = [
    const LatLngPoint(lat: -21.0, lng: -51.0),
    const LatLngPoint(lat: -21.1, lng: -51.1),
  ];

  PoligonoModel _novoPoligono({
    String id = '',
    String propriedadeId = 'prop-1',
    String pastoId = 'pasto-1',
    List<LatLngPoint>? pontos,
  }) {
    return PoligonoModel(
      id: id,
      propriedadeId: propriedadeId,
      pastoId: pastoId,
      pontos: pontos ?? _pontosA,
    );
  }

  // ---------------------------------------------------------------------------
  // salvar
  // ---------------------------------------------------------------------------

  group('salvar', () {
    test('cria um novo documento quando não existe polígono para o pasto', () async {
      await repository.salvar(_novoPoligono());

      final snap = await _poligonosCol('prop-1').get();
      expect(snap.docs, hasLength(1));

      final data = snap.docs.first.data();
      expect(data['pastoId'], 'pasto-1');
      expect(data['propriedadeId'], 'prop-1');
      expect((data['pontos'] as List).length, _pontosA.length);
    });

    test('substitui os pontos quando já existe polígono para o pasto', () async {
      await repository.salvar(_novoPoligono(pontos: _pontosA));
      await repository.salvar(_novoPoligono(pontos: _pontosB));

      final snap = await _poligonosCol('prop-1').get();
      // Deve continuar com apenas 1 documento — não cria duplicata
      expect(snap.docs, hasLength(1));
      expect((snap.docs.first.data()['pontos'] as List).length, _pontosB.length);
    });

    test('cria documentos distintos para pastos diferentes', () async {
      await repository.salvar(_novoPoligono(pastoId: 'pasto-1'));
      await repository.salvar(_novoPoligono(pastoId: 'pasto-2'));

      final snap = await _poligonosCol('prop-1').get();
      expect(snap.docs, hasLength(2));
    });

    test('persiste corretamente as coordenadas dos pontos', () async {
      await repository.salvar(_novoPoligono(pontos: _pontosA));

      final snap = await _poligonosCol('prop-1').get();
      final pontos = snap.docs.first.data()['pontos'] as List;

      expect(pontos[0]['lat'], -20.0);
      expect(pontos[0]['lng'], -50.0);
    });
  });

  // ---------------------------------------------------------------------------
  // apagar
  // ---------------------------------------------------------------------------

  group('apagar', () {
    test('remove o documento do polígono', () async {
      await repository.salvar(_novoPoligono());

      await repository.apagar(propriedadeId: 'prop-1', pastoId: 'pasto-1');

      final snap = await _poligonosCol('prop-1').get();
      expect(snap.docs, isEmpty);
    });

    test('não falha quando não existe polígono para o pasto', () async {
      await expectLater(
        repository.apagar(propriedadeId: 'prop-1', pastoId: 'pasto-inexistente'),
        completes,
      );
    });

    test('não afeta polígonos de outros pastos', () async {
      await repository.salvar(_novoPoligono(pastoId: 'pasto-1'));
      await repository.salvar(_novoPoligono(pastoId: 'pasto-2'));

      await repository.apagar(propriedadeId: 'prop-1', pastoId: 'pasto-1');

      final snap = await _poligonosCol('prop-1').get();
      expect(snap.docs, hasLength(1));
      expect(snap.docs.first.data()['pastoId'], 'pasto-2');
    });
  });

  // ---------------------------------------------------------------------------
  // apagarEmBatch
  // ---------------------------------------------------------------------------

  group('apagarEmBatch', () {
    test('remove o documento ao commitar o batch', () async {
      await repository.salvar(_novoPoligono());

      final batch = firestore.batch();
      await repository.apagarEmBatch(
        propriedadeId: 'prop-1',
        pastoId: 'pasto-1',
        batch: batch,
      );
      await batch.commit();

      final snap = await _poligonosCol('prop-1').get();
      expect(snap.docs, isEmpty);
    });

    test('não falha quando não existe polígono para o pasto', () async {
      final batch = firestore.batch();
      await expectLater(
        repository.apagarEmBatch(
          propriedadeId: 'prop-1',
          pastoId: 'pasto-inexistente',
          batch: batch,
        ),
        completes,
      );
      await batch.commit();
    });
  });
}
