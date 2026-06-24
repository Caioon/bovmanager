import 'package:bov_manager/models/pasto_model.dart';
import 'package:bov_manager/repositories/pasto_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'firebase_test_setup.dart';

void main() {
  late PastoRepository repository;
  late FirebaseFirestore firestore;

  setUpAll(() async {
    await setupFirebaseEmulator();
    firestore = FirebaseFirestore.instance;
    repository = PastoRepository(firestore: firestore);
  });

  setUp(() async {
    await clearFirestoreEmulator();
  });

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  CollectionReference<Map<String, dynamic>> _pastosCol(String propriedadeId) =>
      firestore.collection('propriedades').doc(propriedadeId).collection('pastos');

  Future<void> _criarPropriedadeDoc(String propriedadeId) async {
    await firestore
        .collection('propriedades')
        .doc(propriedadeId)
        .set({'nome': 'Fazenda Test'});
  }

  PastoModel _novoPasto({
    String id = '',
    String nome = 'Pasto A',
    String propriedadeId = 'prop-1',
    double area = 10.0,
    String descricao = 'Descrição test',
    int? limiteAnimais,
  }) {
    return PastoModel(
      id: id,
      nome: nome,
      propriedadeId: propriedadeId,
      area: area,
      descricao: descricao,
      limiteAnimais: limiteAnimais,
    );
  }

  /// Cria um pasto e retorna o id gerado pelo Firestore.
  Future<String> _criarEObterPastoId(PastoModel pasto) async {
    await repository.criar(pasto);
    final snap = await _pastosCol(pasto.propriedadeId).get();
    return snap.docs.first.id;
  }

  // ---------------------------------------------------------------------------
  // criar
  // ---------------------------------------------------------------------------

  group('criar', () {
    test('persiste o documento com os campos corretos', () async {
      await _criarPropriedadeDoc('prop-1');

      await repository.criar(
        _novoPasto(nome: 'Pasto A', area: 15.5, descricao: 'Beira do rio'),
      );

      final snap = await _pastosCol('prop-1').get();
      expect(snap.docs, hasLength(1));

      final data = snap.docs.first.data();
      expect(data['nome'], 'Pasto A');
      expect(data['area'], 15.5);
      expect(data['descricao'], 'Beira do rio');
      expect(data['propriedadeId'], 'prop-1');
    });

    test('persiste limiteAnimais quando informado', () async {
      await _criarPropriedadeDoc('prop-1');

      await repository.criar(_novoPasto(limiteAnimais: 20));

      final snap = await _pastosCol('prop-1').get();
      expect(snap.docs.first.data()['limiteAnimais'], 20);
    });

    test('omite limiteAnimais quando nulo', () async {
      await _criarPropriedadeDoc('prop-1');

      await repository.criar(_novoPasto(limiteAnimais: null));

      final snap = await _pastosCol('prop-1').get();
      expect(snap.docs.first.data().containsKey('limiteAnimais'), isFalse);
    });

    test('cria documentos independentes por chamada', () async {
      await _criarPropriedadeDoc('prop-1');

      await repository.criar(_novoPasto(nome: 'Pasto A'));
      await repository.criar(_novoPasto(nome: 'Pasto B'));

      final snap = await _pastosCol('prop-1').get();
      expect(snap.docs, hasLength(2));
    });
  });

  // ---------------------------------------------------------------------------
  // editar
  // ---------------------------------------------------------------------------

  group('editar', () {
    test('atualiza todos os campos editáveis', () async {
      await _criarPropriedadeDoc('prop-1');
      final id = await _criarEObterPastoId(_novoPasto());

      await repository.editar(
        _novoPasto(
          id: id,
          nome: 'Pasto Editado',
          area: 99.9,
          descricao: 'Nova descrição',
          limiteAnimais: 50,
        ),
      );

      final doc = await _pastosCol('prop-1').doc(id).get();
      expect(doc.data()!['nome'], 'Pasto Editado');
      expect(doc.data()!['area'], 99.9);
      expect(doc.data()!['descricao'], 'Nova descrição');
      expect(doc.data()!['limiteAnimais'], 50);
    });
  });

  // ---------------------------------------------------------------------------
  // apagar
  // ---------------------------------------------------------------------------

  group('apagar', () {
    test('remove o documento do Firestore', () async {
      await _criarPropriedadeDoc('prop-1');
      final id = await _criarEObterPastoId(_novoPasto());

      await repository.apagar(propriedadeId: 'prop-1', pastoId: id);

      final doc = await _pastosCol('prop-1').doc(id).get();
      expect(doc.exists, isFalse);
    });

    test('não afeta outros pastos da mesma propriedade', () async {
      await _criarPropriedadeDoc('prop-1');
      await repository.criar(_novoPasto(nome: 'Pasto A'));
      await repository.criar(_novoPasto(nome: 'Pasto B'));

      final snap = await _pastosCol('prop-1').get();
      final idParaApagar = snap.docs.first.id;

      await repository.apagar(propriedadeId: 'prop-1', pastoId: idParaApagar);

      final snapPos = await _pastosCol('prop-1').get();
      expect(snapPos.docs, hasLength(1));
    });
  });

  // ---------------------------------------------------------------------------
  // apagarEmBatch
  // ---------------------------------------------------------------------------

  group('apagarEmBatch', () {
    test('remove o documento ao commitar o batch', () async {
      await _criarPropriedadeDoc('prop-1');
      final id = await _criarEObterPastoId(_novoPasto());

      final batch = firestore.batch();
      repository.apagarEmBatch(
        propriedadeId: 'prop-1',
        pastoId: id,
        batch: batch,
      );
      await batch.commit();

      final doc = await _pastosCol('prop-1').doc(id).get();
      expect(doc.exists, isFalse);
    });

    test('não apaga antes do commit', () async {
      await _criarPropriedadeDoc('prop-1');
      final id = await _criarEObterPastoId(_novoPasto());

      final batch = firestore.batch();
      repository.apagarEmBatch(
        propriedadeId: 'prop-1',
        pastoId: id,
        batch: batch,
      );

      // Antes do commit o documento ainda existe
      final docAntes = await _pastosCol('prop-1').doc(id).get();
      expect(docAntes.exists, isTrue);

      await batch.commit();
    });
  });
}
