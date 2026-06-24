import 'package:bov_manager/repositories/acesso_compartilhado_repository.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late FakeFirebaseFirestore firestore;
  late AcessoCompartilhadoRepository repository;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repository = AcessoCompartilhadoRepository(firestore: firestore);
  });

  group('AcessoCompartilhadoRepository.criar', () {
    test('insere documento com os campos corretos', () async {
      await repository.criar(
        propriedadeId: 'prop-1',
        usuarioId: 'user-1',
        papel: 'gerente',
      );

      final snapshot = await firestore
          .collection('acessos_compartilhados')
          .where('usuarioId', isEqualTo: 'user-1')
          .where('propriedadeId', isEqualTo: 'prop-1')
          .get();

      expect(snapshot.docs.length, 1);

      final data = snapshot.docs.first.data();
      expect(data['propriedadeId'], 'prop-1');
      expect(data['usuarioId'], 'user-1');
      expect(data['papel'], 'gerente');
      expect(data['dataConvite'], isNotNull);
    });

    test(
      'não cria duplicata para mesma combinação usuarioId + propriedadeId',
      () async {
        await repository.criar(
          propriedadeId: 'prop-1',
          usuarioId: 'user-1',
          papel: 'gerente',
        );
        await repository.criar(
          propriedadeId: 'prop-1',
          usuarioId: 'user-1',
          papel:
              'admin', // papel diferente — não deve sobrescrever nem duplicar
        );

        final snapshot = await firestore
            .collection('acessos_compartilhados')
            .where('usuarioId', isEqualTo: 'user-1')
            .where('propriedadeId', isEqualTo: 'prop-1')
            .get();

        expect(snapshot.docs.length, 1);
        expect(snapshot.docs.first.data()['papel'], 'gerente');
      },
    );

    test('permite o mesmo usuário acessar propriedades distintas', () async {
      await repository.criar(
        propriedadeId: 'prop-1',
        usuarioId: 'user-1',
        papel: 'gerente',
      );
      await repository.criar(
        propriedadeId: 'prop-2',
        usuarioId: 'user-1',
        papel: 'visualizador',
      );

      final snapshot = await firestore
          .collection('acessos_compartilhados')
          .where('usuarioId', isEqualTo: 'user-1')
          .get();

      expect(snapshot.docs.length, 2);
    });

    test('permite usuários distintos acessarem a mesma propriedade', () async {
      await repository.criar(
        propriedadeId: 'prop-1',
        usuarioId: 'user-1',
        papel: 'admin',
      );
      await repository.criar(
        propriedadeId: 'prop-1',
        usuarioId: 'user-2',
        papel: 'visualizador',
      );

      final snapshot = await firestore
          .collection('acessos_compartilhados')
          .where('propriedadeId', isEqualTo: 'prop-1')
          .get();

      expect(snapshot.docs.length, 2);
    });
  });
}
