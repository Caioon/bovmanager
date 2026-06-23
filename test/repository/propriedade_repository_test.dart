import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:bov_manager/repositories/propriedade_repository.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late PropriedadeRepositoryImpl repository;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repository = PropriedadeRepositoryImpl(firestore);
  });

  group('PropriedadeRepository', () {
    test('listarPropriedades() deve retornar propriedades do proprietário', () async {
      await firestore.collection('propriedades').add({
        'nome': 'Fazenda A',
        'proprietarioId': 'user123',
        'dataCadastro': DateTime(2026, 1, 10).toIso8601String(),
      });

      await firestore.collection('propriedades').add({
        'nome': 'Fazenda B',
        'proprietarioId': 'user456',
        'dataCadastro': DateTime(2026, 1, 11).toIso8601String(),
      });

      final result = await repository
          .listarPropriedades(proprietarioId: 'user123')
          .first;

      expect(result.length, 1);
      expect(result.first.nome, 'Fazenda A');
      expect(result.first.proprietarioId, 'user123');
    });

    test('criarPropriedade() deve criar uma propriedade', () async {
      await repository.criarPropriedade(
        nome: 'Fazenda Teste',
        proprietarioId: 'user123',
      );

      final snapshot = await firestore.collection('propriedades').get();

      expect(snapshot.docs.length, 1);

      final data = snapshot.docs.first.data();

      expect(data['nome'], 'Fazenda Teste');
      expect(data['proprietarioId'], 'user123');
      expect(data['dataCadastro'], isNotNull);
    });

    test('editarPropriedade() deve atualizar nome da propriedade', () async {
      await firestore.collection('propriedades').doc('prop123').set({
        'nome': 'Nome Antigo',
        'proprietarioId': 'user123',
        'dataCadastro': DateTime.now().toIso8601String(),
      });

      await repository.editarPropriedade(
        propriedadeId: 'prop123',
        nome: 'Nome Novo',
      );

      final doc = await firestore
          .collection('propriedades')
          .doc('prop123')
          .get();

      expect(doc.data()?['nome'], 'Nome Novo');
    });

    test('apagarPropriedade() deve remover propriedade', () async {
      await firestore.collection('propriedades').doc('prop123').set({
        'nome': 'Fazenda',
      });

      await repository.apagarPropriedade(
        propriedadeId: 'prop123',
      );

      final doc = await firestore
          .collection('propriedades')
          .doc('prop123')
          .get();

      expect(doc.exists, false);
    });

    test('buscarPorId() deve retornar propriedade encontrada', () async {
      await firestore.collection('propriedades').doc('prop123').set({
        'nome': 'Fazenda Teste',
        'proprietarioId': 'user123',
        'dataCadastro': DateTime(2026, 1, 10).toIso8601String(),
      });

      final result = await repository.buscarPorId(
        propriedadeId: 'prop123',
      );

      expect(result, isNotNull);
      expect(result!.id, 'prop123');
      expect(result.nome, 'Fazenda Teste');
      expect(result.proprietarioId, 'user123');
    });

    test('buscarPorId() deve retornar null quando não encontrar', () async {
      final result = await repository.buscarPorId(
        propriedadeId: 'inexistente',
      );

      expect(result, null);
    });

    test('salvarCentro() deve atualizar coordenadas da propriedade', () async {
      await firestore.collection('propriedades').doc('prop123').set({
        'nome': 'Fazenda',
      });

      await repository.salvarCentro(
        propriedadeId: 'prop123',
        lat: -20.123,
        lng: -54.456,
      );

      final doc = await firestore
          .collection('propriedades')
          .doc('prop123')
          .get();

      expect(doc.data()?['centroLat'], -20.123);
      expect(doc.data()?['centroLng'], -54.456);
    });
  });
}
