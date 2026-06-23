import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:bov_manager/repositories/poligono_repository.dart';
import 'package:bov_manager/models/poligono_model.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late PoligonoRepository repository;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repository = PoligonoRepository(firestore);
  });

  group('PoligonoRepository', () {
    final poligono = PoligonoModel(
      id: 'poligono123',
      propriedadeId: 'prop123',
      pastoId: 'pasto123',
      pontos: [
        const LatLngPoint(lat: -20.1, lng: -54.1),
        const LatLngPoint(lat: -20.2, lng: -54.2),
      ],
    );

    test('listarStream() deve retornar polígonos em tempo real', () async {
      await firestore
          .collection('propriedades')
          .doc('prop123')
          .collection('poligonos')
          .doc('poligono123')
          .set(poligono.toMap());

      final result = await repository
          .listarStream('prop123')
          .first;

      expect(result.length, 1);
      expect(result.first.id, 'poligono123');
      expect(result.first.pastoId, 'pasto123');
      expect(result.first.pontos.length, 2);
    });

    test('listar() deve retornar todos os polígonos da propriedade', () async {
      await firestore
          .collection('propriedades')
          .doc('prop123')
          .collection('poligonos')
          .add(poligono.toMap());

      final result = await repository.listar('prop123');

      expect(result.length, 1);
      expect(result.first.propriedadeId, 'prop123');
      expect(result.first.pastoId, 'pasto123');
    });

    test('buscarPorPasto() deve retornar polígono do pasto', () async {
      await firestore
          .collection('propriedades')
          .doc('prop123')
          .collection('poligonos')
          .add(poligono.toMap());

      final result = await repository.buscarPorPasto(
        propriedadeId: 'prop123',
        pastoId: 'pasto123',
      );

      expect(result, isNotNull);
      expect(result!.pastoId, 'pasto123');
      expect(result.propriedadeId, 'prop123');
    });

    test('buscarPorPasto() deve retornar null quando não existir', () async {
      final result = await repository.buscarPorPasto(
        propriedadeId: 'prop123',
        pastoId: 'pastoInexistente',
      );

      expect(result, null);
    });

    test('salvar() deve criar novo polígono quando não existir', () async {
      await repository.salvar(poligono);

      final snapshot = await firestore
          .collection('propriedades')
          .doc('prop123')
          .collection('poligonos')
          .get();

      expect(snapshot.docs.length, 1);

      final data = snapshot.docs.first.data();

      expect(data['propriedadeId'], 'prop123');
      expect(data['pastoId'], 'pasto123');
      expect(data['pontos'].length, 2);
    });

    test('salvar() deve atualizar polígono existente', () async {
      await firestore
          .collection('propriedades')
          .doc('prop123')
          .collection('poligonos')
          .doc('poligonoExistente')
          .set(poligono.toMap());

      final atualizado = PoligonoModel(
        id: '',
        propriedadeId: 'prop123',
        pastoId: 'pasto123',
        pontos: [
          const LatLngPoint(lat: -21.1, lng: -55.1),
        ],
      );

      await repository.salvar(atualizado);

      final snapshot = await firestore
          .collection('propriedades')
          .doc('prop123')
          .collection('poligonos')
          .get();

      expect(snapshot.docs.length, 1);
      expect(
        snapshot.docs.first.data()['pontos'].length,
        1,
      );
    });

    test('apagar() deve remover polígono do pasto', () async {
      await firestore
          .collection('propriedades')
          .doc('prop123')
          .collection('poligonos')
          .doc('poligono123')
          .set(poligono.toMap());

      await repository.apagar(
        propriedadeId: 'prop123',
        pastoId: 'pasto123',
      );

      final snapshot = await firestore
          .collection('propriedades')
          .doc('prop123')
          .collection('poligonos')
          .get();

      expect(snapshot.docs, isEmpty);
    });

    test('apagar() não deve remover nada se não existir polígono', () async {
      await repository.apagar(
        propriedadeId: 'prop123',
        pastoId: 'pastoInexistente',
      );

      final snapshot = await firestore
          .collection('propriedades')
          .doc('prop123')
          .collection('poligonos')
          .get();

      expect(snapshot.docs, isEmpty);
    });

    test('apagarEmBatch() deve remover polígono usando batch', () async {
      await firestore
          .collection('propriedades')
          .doc('prop123')
          .collection('poligonos')
          .doc('poligono123')
          .set(poligono.toMap());

      final batch = firestore.batch();

      await repository.apagarEmBatch(
        propriedadeId: 'prop123',
        pastoId: 'pasto123',
        batch: batch,
      );

      await batch.commit();

      final snapshot = await firestore
          .collection('propriedades')
          .doc('prop123')
          .collection('poligonos')
          .get();

      expect(snapshot.docs, isEmpty);
    });
  });
}
