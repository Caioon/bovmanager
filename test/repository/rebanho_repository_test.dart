import 'package:bov_manager/models/rebanho_model.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:bov_manager/repositories/rebanho_repository.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late MockFirebaseAuth auth;
  late RebanhoRepository repository;

  setUp(() {
    firestore = FakeFirebaseFirestore();

    auth = MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(uid: 'user123', email: 'teste@email.com'),
    );

    repository = RebanhoRepository(firestore: firestore, auth: auth);
  });

  group('RebanhoRepository', () {
    final rebanho = RebanhoModel(
      id: 'rebanho123',
      nome: 'Rebanho A',
      propriedadeId: 'prop123',
      pastoId: 'pasto123',
      dataCadastro: DateTime(2026, 1, 10),
    );

    test('listarStream() deve retornar rebanhos em tempo real', () async {
      await firestore
          .collection('propriedades')
          .doc('prop123')
          .collection('rebanhos')
          .doc('rebanho123')
          .set(rebanho.toMap());

      final result = await repository.listarStream('prop123').first;

      expect(result.length, 1);
      expect(result.first.id, 'rebanho123');
      expect(result.first.nome, 'Rebanho A');
      expect(result.first.pastoId, 'pasto123');
    });

    test('listar() deve retornar lista de rebanhos', () async {
      await firestore
          .collection('propriedades')
          .doc('prop123')
          .collection('rebanhos')
          .add(rebanho.toMap());

      final result = await repository.listar('prop123');

      expect(result.length, 1);
      expect(result.first.propriedadeId, 'prop123');
      expect(result.first.nome, 'Rebanho A');
    });

    test('criar() deve adicionar novo rebanho', () async {
      await repository.criar(rebanho);

      final snapshot = await firestore
          .collection('propriedades')
          .doc('prop123')
          .collection('rebanhos')
          .get();

      expect(snapshot.docs.length, 1);

      final data = snapshot.docs.first.data();

      expect(data['nome'], 'Rebanho A');
      expect(data['propriedadeId'], 'prop123');
      expect(data['pastoId'], 'pasto123');
      expect(data['dataCadastro'], isNotNull);
    });

    test(
      'moverEmBatch() deve atualizar pasto do rebanho usando batch',
      () async {
        await firestore
            .collection('propriedades')
            .doc('prop123')
            .collection('rebanhos')
            .doc('rebanho123')
            .set(rebanho.toMap());

        final batch = firestore.batch();

        repository.moverEmBatch(
          propriedadeId: 'prop123',
          rebanhoId: 'rebanho123',
          novoPastoId: 'pastoNovo',
          batch: batch,
        );

        await batch.commit();

        final doc = await firestore
            .collection('propriedades')
            .doc('prop123')
            .collection('rebanhos')
            .doc('rebanho123')
            .get();

        expect(doc.data()?['pastoId'], 'pastoNovo');
      },
    );

    test('apagar() deve remover rebanho', () async {
      await firestore
          .collection('propriedades')
          .doc('prop123')
          .collection('rebanhos')
          .doc('rebanho123')
          .set(rebanho.toMap());

      await repository.apagar(
        propriedadeId: 'prop123',
        rebanhoId: 'rebanho123',
      );

      final doc = await firestore
          .collection('propriedades')
          .doc('prop123')
          .collection('rebanhos')
          .doc('rebanho123')
          .get();

      expect(doc.exists, false);
    });
  });
}
