import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:bov_manager/repositories/acesso_compartilhado_repository.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late AcessoCompartilhadoRepository repository;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repository = AcessoCompartilhadoRepository(firestore: firestore);
  });

  group('AcessoCompartilhadoRepository', () {
    test('listarPorUsuario() deve retornar acessos do usuário', () async {
      await firestore.collection('acessos_compartilhados').add({
        'propriedadeId': 'prop1',
        'usuarioId': 'user1',
        'papel': 'funcionario',
        'dataConvite': DateTime(2026, 1, 10).toIso8601String(),
      });

      await firestore.collection('acessos_compartilhados').add({
        'propriedadeId': 'prop2',
        'usuarioId': 'user2',
        'papel': 'admin',
        'dataConvite': DateTime(2026, 1, 11).toIso8601String(),
      });

      final result = await repository.listarPorUsuario('user1');

      expect(result.length, 1);
      expect(result.first.usuarioId, 'user1');
      expect(result.first.propriedadeId, 'prop1');
      expect(result.first.papel, 'funcionario');
    });

    test(
      'listarPorUsuario() deve retornar lista vazia quando não encontrar',
      () async {
        final result = await repository.listarPorUsuario('usuarioInexistente');

        expect(result, isEmpty);
      },
    );

    test(
      'buscarUsuarioIdPorEmail() deve retornar id do usuário encontrado',
      () async {
        await firestore.collection('usuarios').doc('user123').set({
          'email': 'teste@email.com',
        });

        final result = await repository.buscarUsuarioIdPorEmail(
          'TESTE@EMAIL.COM',
        );

        expect(result, 'user123');
      },
    );

    test(
      'buscarUsuarioIdPorEmail() deve retornar null quando não encontrar',
      () async {
        final result = await repository.buscarUsuarioIdPorEmail(
          'naoexiste@email.com',
        );

        expect(result, null);
      },
    );

    test('criar() deve criar acesso quando não existe duplicata', () async {
      await repository.criar(
        propriedadeId: 'prop123',
        usuarioId: 'user123',
        papel: 'funcionario',
      );

      final snapshot = await firestore
          .collection('acessos_compartilhados')
          .get();

      expect(snapshot.docs.length, 1);

      final data = snapshot.docs.first.data();

      expect(data['propriedadeId'], 'prop123');
      expect(data['usuarioId'], 'user123');
      expect(data['papel'], 'funcionario');
      expect(data['dataConvite'], isNotNull);
    });

    test('criar() não deve criar acesso duplicado', () async {
      await firestore.collection('acessos_compartilhados').add({
        'propriedadeId': 'prop123',
        'usuarioId': 'user123',
        'papel': 'funcionario',
        'dataConvite': DateTime(2026, 1, 10).toIso8601String(),
      });

      await repository.criar(
        propriedadeId: 'prop123',
        usuarioId: 'user123',
        papel: 'admin',
      );

      final snapshot = await firestore
          .collection('acessos_compartilhados')
          .get();

      expect(snapshot.docs.length, 1);

      expect(snapshot.docs.first.data()['papel'], 'funcionario');
    });
  });
}
