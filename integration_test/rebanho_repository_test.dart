import 'package:bov_manager/models/rebanho_model.dart';
import 'package:bov_manager/repositories/rebanho_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'firebase_test_setup.dart';

void main() {
  late RebanhoRepository repository;

  const propriedadeId = 'prop-test';
  const pastoId = 'pasto-a';

  RebanhoModel _makeRebanho({String pasto = pastoId}) => RebanhoModel(
    id: '',
    nome: 'Rebanho Teste',
    pastoId: pasto,
    propriedadeId: propriedadeId,
    dataCadastro: DateTime(2024, 1, 1),
  );

  setUpAll(() async {
    await setupFirebaseEmulator();
    repository = RebanhoRepository(firestore: FirebaseFirestore.instance);
  });

  setUp(() async {
    await clearFirestoreEmulator();
  });

  // ---------------------------------------------------------------------------
  // criar
  // ---------------------------------------------------------------------------
  group('criar', () {
    test('persiste o rebanho no Firestore', () async {
      await repository.criar(_makeRebanho());

      final snap = await FirebaseFirestore.instance
          .collection('propriedades')
          .doc(propriedadeId)
          .collection('rebanhos')
          .get();

      expect(snap.docs, hasLength(1));

      final data = snap.docs.first.data();
      expect(data['nome'], 'Rebanho Teste');
      expect(data['pastoId'], pastoId);
      expect(data['propriedadeId'], propriedadeId);
      expect(data['dataCadastro'], '2024-01-01T00:00:00.000');
    });
  });

  // ---------------------------------------------------------------------------
  // moverEmBatch
  // ---------------------------------------------------------------------------
  group('moverEmBatch', () {
    test('atualiza pastoId dentro de um batch externo', () async {
      await repository.criar(_makeRebanho());

      final snap = await FirebaseFirestore.instance
          .collection('propriedades')
          .doc(propriedadeId)
          .collection('rebanhos')
          .get();

      final rebanhoId = snap.docs.first.id;
      const novoPastoId = 'pasto-b';

      final batch = FirebaseFirestore.instance.batch();
      repository.moverEmBatch(
        propriedadeId: propriedadeId,
        rebanhoId: rebanhoId,
        novoPastoId: novoPastoId,
        batch: batch,
      );
      await batch.commit();

      final doc = await FirebaseFirestore.instance
          .collection('propriedades')
          .doc(propriedadeId)
          .collection('rebanhos')
          .doc(rebanhoId)
          .get();

      expect(doc.data()?['pastoId'], novoPastoId);
    });

    test('não altera outros campos ao mover', () async {
      await repository.criar(_makeRebanho());

      final snap = await FirebaseFirestore.instance
          .collection('propriedades')
          .doc(propriedadeId)
          .collection('rebanhos')
          .get();

      final rebanhoId = snap.docs.first.id;

      final batch = FirebaseFirestore.instance.batch();
      repository.moverEmBatch(
        propriedadeId: propriedadeId,
        rebanhoId: rebanhoId,
        novoPastoId: 'pasto-c',
        batch: batch,
      );
      await batch.commit();

      final doc = await FirebaseFirestore.instance
          .collection('propriedades')
          .doc(propriedadeId)
          .collection('rebanhos')
          .doc(rebanhoId)
          .get();

      final data = doc.data()!;
      expect(data['nome'], 'Rebanho Teste');
      expect(data['propriedadeId'], propriedadeId);
    });
  });

  // ---------------------------------------------------------------------------
  // apagar
  // ---------------------------------------------------------------------------
  group('apagar', () {
    test('remove o documento do Firestore', () async {
      await repository.criar(_makeRebanho());

      final snap = await FirebaseFirestore.instance
          .collection('propriedades')
          .doc(propriedadeId)
          .collection('rebanhos')
          .get();

      final rebanhoId = snap.docs.first.id;

      await repository.apagar(
        propriedadeId: propriedadeId,
        rebanhoId: rebanhoId,
      );

      final doc = await FirebaseFirestore.instance
          .collection('propriedades')
          .doc(propriedadeId)
          .collection('rebanhos')
          .doc(rebanhoId)
          .get();

      expect(doc.exists, isFalse);
    });

    test('apaga apenas o rebanho alvo quando existem múltiplos', () async {
      await repository.criar(_makeRebanho());
      await repository.criar(_makeRebanho(pasto: 'pasto-x'));

      final snap = await FirebaseFirestore.instance
          .collection('propriedades')
          .doc(propriedadeId)
          .collection('rebanhos')
          .get();

      expect(snap.docs, hasLength(2));
      final alvo = snap.docs.first.id;

      await repository.apagar(propriedadeId: propriedadeId, rebanhoId: alvo);

      final restantes = await FirebaseFirestore.instance
          .collection('propriedades')
          .doc(propriedadeId)
          .collection('rebanhos')
          .get();

      expect(restantes.docs, hasLength(1));
      expect(restantes.docs.first.id, isNot(alvo));
    });
  });
}
