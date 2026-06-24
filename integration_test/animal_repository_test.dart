import 'package:bov_manager/repositories/animal_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'firebase_test_setup.dart';

void main() {
  late AnimalRepository repository;
  late FirebaseFirestore firestore;

  setUpAll(() async {
    await setupFirebaseEmulator();
    firestore = FirebaseFirestore.instance;
    repository = AnimalRepositoryImpl(firestore);
  });

  setUp(() async {
    await clearFirestoreEmulator();
  });

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Future<String> _criarAnimal({
    String nome = 'Mimosa',
    String brinco = 'A001',
    String raca = 'Nelore',
    double peso = 350.0,
    DateTime? dataNascimento,
    String propriedadeId = 'prop-1',
  }) async {
    final batch = firestore.batch();
    final id = await repository.criarAnimal(
      nome: nome,
      brinco: brinco,
      raca: raca,
      pesoAtual: peso,
      dataNascimento: dataNascimento ?? DateTime(2021, 1, 1),
      propriedadeId: propriedadeId,
      batch: batch,
    );
    await batch.commit();
    return id;
  }

  // ---------------------------------------------------------------------------
  // criarAnimal
  // ---------------------------------------------------------------------------

  group('criarAnimal', () {
    test('persiste o documento com os campos corretos', () async {
      final id = await _criarAnimal(
        nome: 'Mimosa',
        brinco: 'A001',
        raca: 'Nelore',
        peso: 350.0,
        propriedadeId: 'prop-1',
      );

      final doc = await firestore.collection('animais').doc(id).get();

      expect(doc.exists, isTrue);
      expect(doc.data()!['nome'], 'Mimosa');
      expect(doc.data()!['brinco'], 'A001');
      expect(doc.data()!['raca'], 'Nelore');
      expect(doc.data()!['pesoAtual'], 350.0);
      expect(doc.data()!['propriedadeId'], 'prop-1');
    });

    test('retorna um id único por chamada', () async {
      final id1 = await _criarAnimal(brinco: 'A001');
      final id2 = await _criarAnimal(brinco: 'A002');

      expect(id1, isNotEmpty);
      expect(id2, isNotEmpty);
      expect(id1, isNot(equals(id2)));
    });

    test('persiste fotoUrl quando informada', () async {
      final batch = firestore.batch();
      final id = await repository.criarAnimal(
        nome: 'Mimosa',
        brinco: 'A001',
        raca: 'Nelore',
        pesoAtual: 300.0,
        dataNascimento: DateTime(2021, 1, 1),
        propriedadeId: 'prop-1',
        fotoUrl: 'https://example.com/foto.jpg',
        batch: batch,
      );
      await batch.commit();

      final doc = await firestore.collection('animais').doc(id).get();
      expect(doc.data()!['fotoUrl'], 'https://example.com/foto.jpg');
    });
  });

  // ---------------------------------------------------------------------------
  // editarAnimal
  // ---------------------------------------------------------------------------

  group('editarAnimal', () {
    test('atualiza nome, brinco, raca e fotoUrl', () async {
      final id = await _criarAnimal();

      await repository.editarAnimal(
        animalId: id,
        nome: 'Boneca',
        brinco: 'B999',
        raca: 'Angus',
        fotoUrl: 'https://example.com/nova.jpg',
      );

      final doc = await firestore.collection('animais').doc(id).get();
      expect(doc.data()!['nome'], 'Boneca');
      expect(doc.data()!['brinco'], 'B999');
      expect(doc.data()!['raca'], 'Angus');
      expect(doc.data()!['fotoUrl'], 'https://example.com/nova.jpg');
    });

    test('não altera campos fora do escopo da edição', () async {
      final id = await _criarAnimal(peso: 400.0, propriedadeId: 'prop-x');

      await repository.editarAnimal(
        animalId: id,
        nome: 'Boneca',
        brinco: 'B999',
        raca: 'Angus',
      );

      final doc = await firestore.collection('animais').doc(id).get();
      expect(doc.data()!['pesoAtual'], 400.0);
      expect(doc.data()!['propriedadeId'], 'prop-x');
    });
  });

  // ---------------------------------------------------------------------------
  // apagarAnimal
  // ---------------------------------------------------------------------------

  group('apagarAnimal', () {
    test('remove o documento do Firestore', () async {
      final id = await _criarAnimal();

      final batch = firestore.batch();
      await repository.apagarAnimal(animalId: id, batch: batch);
      await batch.commit();

      final doc = await firestore.collection('animais').doc(id).get();
      expect(doc.exists, isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // registrarPesagem
  // ---------------------------------------------------------------------------

  group('registrarPesagem', () {
    test('atualiza pesoAtual no documento do animal', () async {
      final id = await _criarAnimal(peso: 300.0);

      final batch = firestore.batch();
      await repository.registrarPesagem(
        animalId: id,
        novoPeso: 420.5,
        data: DateTime(2024, 6, 1),
        batch: batch,
      );
      await batch.commit();

      final doc = await firestore.collection('animais').doc(id).get();
      expect(doc.data()!['pesoAtual'], 420.5);
    });

    test('não altera outros campos ao registrar pesagem', () async {
      final id = await _criarAnimal(nome: 'Mimosa', raca: 'Nelore');

      final batch = firestore.batch();
      await repository.registrarPesagem(
        animalId: id,
        novoPeso: 500.0,
        data: DateTime(2024, 6, 1),
        batch: batch,
      );
      await batch.commit();

      final doc = await firestore.collection('animais').doc(id).get();
      expect(doc.data()!['nome'], 'Mimosa');
      expect(doc.data()!['raca'], 'Nelore');
    });
  });
}
