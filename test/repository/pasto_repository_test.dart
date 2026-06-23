import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:bov_manager/repositories/pasto_repository.dart';
import 'package:bov_manager/models/pasto_model.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late MockFirebaseAuth auth;
  late PastoRepository repository;

  setUp(() {
    firestore = FakeFirebaseFirestore();

    auth = MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(uid: 'user123', email: 'teste@email.com'),
    );

    repository = PastoRepository(firestore: firestore, auth: auth);
  });

  group('PastoRepository', () {
    final pasto = PastoModel(
      id: 'pasto123',
      nome: 'Pasto A',
      propriedadeId: 'prop123',
      area: 10.5,
      descricao: 'Pasto de teste',
      limiteAnimais: 50,
    );

    test('listarStream() deve retornar pastos em tempo real', () async {
      await firestore
          .collection('propriedades')
          .doc('prop123')
          .collection('pastos')
          .doc('pasto123')
          .set(pasto.toMap());

      final result = await repository.listarStream('prop123').first;

      expect(result.length, 1);
      expect(result.first.id, 'pasto123');
      expect(result.first.nome, 'Pasto A');
      expect(result.first.propriedadeId, 'prop123');
    });

    test('listar() deve retornar lista de pastos', () async {
      final col = firestore
          .collection('propriedades')
          .doc('prop123')
          .collection('pastos');

      await col.add({
        'nome': 'Pasto B',
        'propriedadeId': 'prop123',
        'area': 20,
        'descricao': 'Segundo pasto',
        'limiteAnimais': 30,
      });

      await col.add({
        'nome': 'Pasto A',
        'propriedadeId': 'prop123',
        'area': 10,
        'descricao': 'Primeiro pasto',
        'limiteAnimais': 20,
      });

      final result = await repository.listar('prop123');

      expect(result.length, 2);
      expect(result.first.nome, 'Pasto A');
    });

    test('criar() deve adicionar um novo pasto', () async {
      await repository.criar(pasto);

      final snapshot = await firestore
          .collection('propriedades')
          .doc('prop123')
          .collection('pastos')
          .get();

      expect(snapshot.docs.length, 1);

      final data = snapshot.docs.first.data();

      expect(data['nome'], 'Pasto A');
      expect(data['propriedadeId'], 'prop123');
      expect(data['area'], 10.5);
      expect(data['limiteAnimais'], 50);
    });

    test('apagar() deve remover o pasto', () async {
      await firestore
          .collection('propriedades')
          .doc('prop123')
          .collection('pastos')
          .doc('pasto123')
          .set(pasto.toMap());

      await repository.apagar(propriedadeId: 'prop123', pastoId: 'pasto123');

      final doc = await firestore
          .collection('propriedades')
          .doc('prop123')
          .collection('pastos')
          .doc('pasto123')
          .get();

      expect(doc.exists, false);
    });

    test('apagarEmBatch() deve remover pasto usando batch', () async {
      await firestore
          .collection('propriedades')
          .doc('prop123')
          .collection('pastos')
          .doc('pasto123')
          .set(pasto.toMap());

      final batch = firestore.batch();

      repository.apagarEmBatch(
        propriedadeId: 'prop123',
        pastoId: 'pasto123',
        batch: batch,
      );

      await batch.commit();

      final doc = await firestore
          .collection('propriedades')
          .doc('prop123')
          .collection('pastos')
          .doc('pasto123')
          .get();

      expect(doc.exists, false);
    });

    test('editar() deve atualizar o pasto', () async {
      await firestore
          .collection('propriedades')
          .doc('prop123')
          .collection('pastos')
          .doc('pasto123')
          .set(pasto.toMap());

      final atualizado = PastoModel(
        id: 'pasto123',
        nome: 'Pasto Atualizado',
        propriedadeId: 'prop123',
        area: 15,
        descricao: 'Nova descrição',
        limiteAnimais: 80,
      );

      await repository.editar(atualizado);

      final doc = await firestore
          .collection('propriedades')
          .doc('prop123')
          .collection('pastos')
          .doc('pasto123')
          .get();

      expect(doc.data()?['nome'], 'Pasto Atualizado');
      expect(doc.data()?['area'], 15);
      expect(doc.data()?['limiteAnimais'], 80);
    });
  });
}
