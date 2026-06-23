import 'package:bov_manager/repositories/acesso_compartilhado_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bov_manager/models/acesso_compartilhado_model.dart';
import 'package:bov_manager/services/acesso_compartilhado_service.dart';

class MockAcessoCompartilhadoRepository extends AcessoCompartilhadoRepository {
  MockAcessoCompartilhadoRepository(FirebaseFirestore firestore)
    : super(firestore: firestore);

  final List<AcessoCompartilhadoModel> acessos = [];

  String? usuarioIdEncontrado;

  bool criado = false;
  String? propriedadeCriada;
  String? usuarioCriado;
  String? papelCriado;

  @override
  Future<List<AcessoCompartilhadoModel>> listarPorUsuario(
    String usuarioId,
  ) async {
    return acessos.where((a) => a.usuarioId == usuarioId).toList();
  }

  @override
  Future<String?> buscarUsuarioIdPorEmail(String email) async {
    return usuarioIdEncontrado;
  }

  @override
  Future<void> criar({
    required String propriedadeId,
    required String usuarioId,
    required String papel,
  }) async {
    criado = true;
    propriedadeCriada = propriedadeId;
    usuarioCriado = usuarioId;
    papelCriado = papel;
  }
}

class FakeAcessoCompartilhadoService extends AcessoCompartilhadoService {
  final MockAcessoCompartilhadoRepository mockRepo;

  FakeAcessoCompartilhadoService(this.mockRepo) : super(mockRepo as dynamic);
}

void main() {
  group('AcessoCompartilhadoService', () {
    late MockAcessoCompartilhadoRepository mockRepo;
    late AcessoCompartilhadoService service;

    final acesso = AcessoCompartilhadoModel(
      id: 'acesso123',
      propriedadeId: 'propriedade123',
      usuarioId: 'usuario123',
      papel: 'funcionario',
      dataConvite: DateTime(2026, 1, 10),
    );

    setUp(() {
      mockRepo = MockAcessoCompartilhadoRepository(FakeFirebaseFirestore());
      service = FakeAcessoCompartilhadoService(mockRepo);
    });

    test('listarPorUsuario() deve retornar acessos do usuário', () async {
      mockRepo.acessos.add(acesso);

      final result = await service.listarPorUsuario('usuario123');

      expect(result.length, 1);
      expect(result.first.id, 'acesso123');
      expect(result.first.usuarioId, 'usuario123');
    });

    test(
      'convidarPorEmail() deve criar acesso quando usuário existe',
      () async {
        mockRepo.usuarioIdEncontrado = 'usuario123';

        await service.convidarPorEmail(
          propriedadeId: 'propriedade123',
          email: 'usuario@email.com',
          papel: 'funcionario',
        );

        expect(mockRepo.criado, true);
        expect(mockRepo.propriedadeCriada, 'propriedade123');
        expect(mockRepo.usuarioCriado, 'usuario123');
        expect(mockRepo.papelCriado, 'funcionario');
      },
    );

    test(
      'convidarPorEmail() deve lançar exceção quando usuário não existe',
      () async {
        mockRepo.usuarioIdEncontrado = null;

        expect(
          () => service.convidarPorEmail(
            propriedadeId: 'propriedade123',
            email: 'inexistente@email.com',
            papel: 'funcionario',
          ),
          throwsException,
        );
      },
    );

    test(
      'listarPropriedadeIdsCompartilhadas() deve retornar IDs das propriedades',
      () async {
        mockRepo.acessos.addAll([
          acesso,
          AcessoCompartilhadoModel(
            id: 'acesso456',
            propriedadeId: 'propriedade456',
            usuarioId: 'usuario123',
            papel: 'admin',
            dataConvite: DateTime(2026, 1, 11),
          ),
        ]);

        final result = await service.listarPropriedadeIdsCompartilhadas(
          'usuario123',
        );

        expect(result.length, 2);
        expect(result, contains('propriedade123'));
        expect(result, contains('propriedade456'));
      },
    );

    test(
      'listarPropriedadeIdsCompartilhadas() deve retornar lista vazia',
      () async {
        final result = await service.listarPropriedadeIdsCompartilhadas(
          'usuario123',
        );

        expect(result, isEmpty);
      },
    );
  });
}
