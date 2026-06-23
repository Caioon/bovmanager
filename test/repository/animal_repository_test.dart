import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:bov_manager/repositories/animal_repository.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late AnimalRepositoryImpl repository;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repository = AnimalRepositoryImpl(firestore);
  });

  group('AnimalRepository', () {
    test('listarPorPropriedade() deve retornar animais da propriedade', () async {
      await firestore.collection('animais').add({
        'nome': 'Boi 1',
        'brinco': '001',
        'raca': 'Nelore',
        'pesoAtual': 450.0,
        'dataNascimento': DateTime(2020, 1, 1).toIso8601String(),
        'propriedadeId': 'prop1',
        'fotoUrl': null,
      });

      await firestore.collection('animais').add({
        'nome': 'Boi 2',
        'brinco': '002',
        'raca': 'Angus',
        'pesoAtual': 500.0,
        'dataNascimento': DateTime(2021, 1, 1).toIso8601String(),
        'propriedadeId': 'prop2',
        'fotoUrl': null,
      });

      final result = await repository
          .listarPorPropriedade(propriedadeId: 'prop1')
          .first;

      expect(result.length, 1);
      expect(result.first.nome, 'Boi 1');
      expect(result.first.propriedadeId, 'prop1');
    });

    test('criarAnimal() deve adicionar animal no batch', () async {
      final batch = firestore.batch();

      final id = await repository.criarAnimal(
        nome: 'Boi Teste',
        brinco: '123',
        raca: 'Nelore',
        pesoAtual: 400,
        dataNascimento: DateTime(2020, 1, 1),
        propriedadeId: 'prop123',
        pastoDestinoId: 'pasto123',
        fotoUrl: 'foto.png',
        batch: batch,
      );

      await batch.commit();

      final doc = await firestore.collection('animais').doc(id).get();

      expect(doc.exists, true);
      expect(doc.data()?['nome'], 'Boi Teste');
      expect(doc.data()?['brinco'], '123');
      expect(doc.data()?['raca'], 'Nelore');
      expect(doc.data()?['pesoAtual'], 400);
      expect(doc.data()?['propriedadeId'], 'prop123');
    });

    test('editarAnimal() deve atualizar os dados do animal', () async {
      await firestore.collection('animais').doc('animal123').set({
        'nome': 'Antigo',
        'brinco': '001',
        'raca': 'Nelore',
        'fotoUrl': null,
      });

      await repository.editarAnimal(
        animalId: 'animal123',
        nome: 'Novo Nome',
        brinco: '002',
        raca: 'Angus',
        fotoUrl: 'nova.png',
      );

      final doc =
          await firestore.collection('animais').doc('animal123').get();

      expect(doc.data()?['nome'], 'Novo Nome');
      expect(doc.data()?['brinco'], '002');
      expect(doc.data()?['raca'], 'Angus');
      expect(doc.data()?['fotoUrl'], 'nova.png');
    });

    test('apagarAnimal() deve remover animal usando batch', () async {
      await firestore.collection('animais').doc('animal123').set({
        'nome': 'Boi',
      });

      final batch = firestore.batch();

      await repository.apagarAnimal(
        animalId: 'animal123',
        batch: batch,
      );

      await batch.commit();

      final doc =
          await firestore.collection('animais').doc('animal123').get();

      expect(doc.exists, false);
    });

    test('registrarPesagem() deve atualizar peso do animal usando batch', () async {
      await firestore.collection('animais').doc('animal123').set({
        'pesoAtual': 300,
      });

      final batch = firestore.batch();

      await repository.registrarPesagem(
        animalId: 'animal123',
        novoPeso: 450,
        data: DateTime.now(),
        batch: batch,
      );

      await batch.commit();

      final doc =
          await firestore.collection('animais').doc('animal123').get();

      expect(doc.data()?['pesoAtual'], 450);
    });

    test('listarHistorico() deve retornar histórico do animal', () async {
      await firestore
          .collection('animais')
          .doc('animal123')
          .collection('historico')
          .add({
        'animalId': 'animal123',
        'tipo': 'pesagem',
        'novoPeso': 450,
        'data': DateTime(2026, 1, 1).toIso8601String(),
      });

      final result = await repository
          .listarHistorico(animalId: 'animal123')
          .first;

      expect(result.length, 1);
      expect(result.first.animalId, 'animal123');
      expect(result.first.novoPeso, 450);
    });
  });
}
