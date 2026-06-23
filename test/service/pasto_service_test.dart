import 'package:bov_manager/models/poligono_model.dart';
import 'package:bov_manager/models/rebanho_model.dart';
import 'package:bov_manager/repositories/pasto_repository.dart';
import 'package:bov_manager/repositories/poligono_repository.dart';
import 'package:bov_manager/repositories/rebanho_repository.dart';
import 'package:bov_manager/services/animal_service.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bov_manager/models/pasto_model.dart';
import 'package:bov_manager/services/pasto_service.dart';

import 'animal_service_test.dart';

class MockPastoRepository extends PastoRepository {
  MockPastoRepository(FirebaseFirestore firestore, FirebaseAuth auth)
    : super(firestore: firestore, auth: auth);
  final List<PastoModel> pastos = [];

  bool criou = false;
  bool editou = false;
  bool apagou = false;

  @override
  Stream<List<PastoModel>> listarStream(String propriedadeId) {
    return Stream.value(
      pastos.where((p) => p.propriedadeId == propriedadeId).toList(),
    );
  }

  @override
  Future<List<PastoModel>> listar(String propriedadeId) async {
    return pastos.where((p) => p.propriedadeId == propriedadeId).toList();
  }

  @override
  Future<void> criar(PastoModel pasto) async {
    criou = true;
    pastos.add(pasto);
  }

  @override
  Future<void> editar(PastoModel pasto) async {
    editou = true;
  }

  @override
  void apagarEmBatch({
    required String propriedadeId,
    required String pastoId,
    required WriteBatch batch,
  }) {
    apagou = true;
  }
}

class MockPoligonoRepository extends PoligonoRepository {
  MockPoligonoRepository(super.firestore);
  bool possui = false;
  bool apagou = false;

  @override
  Future<PoligonoModel?> buscarPorPasto({
    required String propriedadeId,
    required String pastoId,
  }) async {
    return possui
        ? PoligonoModel(
            id: 'poligono123',
            propriedadeId: propriedadeId,
            pastoId: pastoId,
            pontos: [],
          )
        : null;
  }

  @override
  Future<void> apagarEmBatch({
    required String propriedadeId,
    required String pastoId,
    required WriteBatch batch,
  }) async {
    apagou = true;
  }
}

class MockRebanhoRepository extends RebanhoRepository {
  MockRebanhoRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  }) : super(firestore: firestore, auth: auth);

  final List<RebanhoModel> rebanhos = [];

  @override
  Future<List<RebanhoModel>> listar(String propriedadeId) async {
    return rebanhos.where((r) => r.propriedadeId == propriedadeId).toList();
  }
}

class MockAnimalService extends AnimalService {
  MockAnimalService()
    : super(
        MockAnimalRepository(),
        MockHistoricoAnimalService(),
        MockRebanhoService(),
        FakeFirebaseFirestore(),
      );

  int quantidadeAnimais = 0;

  @override
  Future<int> contarAnimaisPorPasto({
    required String propriedadeId,
    required String pastoId,
  }) async {
    return quantidadeAnimais;
  }
}

void main() {
  group('PastoService', () {
    late MockPastoRepository pastoRepository;
    late MockPoligonoRepository poligonoRepository;
    late MockRebanhoRepository rebanhoRepository;
    late MockAnimalService animalService;
    late PastoService service;

    setUp(() {
      final firestore = FakeFirebaseFirestore();
      final auth = MockFirebaseAuth();

      pastoRepository = MockPastoRepository(firestore, auth);

      poligonoRepository = MockPoligonoRepository(firestore);

      rebanhoRepository = MockRebanhoRepository(
        firestore: firestore,
        auth: auth,
      );

      animalService = MockAnimalService();

      service = PastoService(
        pastoRepository as dynamic,
        poligonoRepository as dynamic,
        rebanhoRepository as dynamic,
        animalService as dynamic,
        firestore,
      );
    });

    test('listarStream() deve retornar pastos da propriedade', () async {
      pastoRepository.pastos.add(
        PastoModel(
          id: 'pasto123',
          nome: 'Pasto A',
          propriedadeId: 'prop123',
          area: 10,
          descricao: 'Descrição',
          limiteAnimais: 20,
        ),
      );

      final result = await service.listarStream('prop123').first;

      expect(result.length, 1);
      expect(result.first.id, 'pasto123');
    });

    test('listarStream() deve lançar erro com propriedade vazia', () {
      expect(() => service.listarStream(''), throwsException);
    });

    test('listar() deve retornar pastos da propriedade', () async {
      pastoRepository.pastos.add(
        PastoModel(
          id: 'pasto123',
          nome: 'Pasto A',
          propriedadeId: 'prop123',
          area: 10,
          descricao: 'Descrição',
          limiteAnimais: 20,
        ),
      );

      final result = await service.listar('prop123');

      expect(result.length, 1);
    });

    test('criar() deve criar pasto corretamente', () async {
      await service.criar(
        nome: 'Pasto Novo',
        propriedadeId: 'prop123',
        area: 20,
        descricao: 'Descrição',
        limiteAnimais: 30,
      );

      expect(pastoRepository.criou, true);
    });

    test('criar() deve impedir nome vazio', () {
      expect(
        () => service.criar(
          nome: '',
          propriedadeId: 'prop123',
          area: 20,
          descricao: '',
        ),
        throwsException,
      );
    });

    test('criar() deve impedir área negativa', () {
      expect(
        () => service.criar(
          nome: 'Pasto',
          propriedadeId: 'prop123',
          area: -1,
          descricao: '',
        ),
        throwsException,
      );
    });

    test('verificarBloqueioExclusao() deve bloquear por rebanho', () async {
      rebanhoRepository.rebanhos.add(
        RebanhoModel(
          id: 'rebanho123',
          nome: 'Rebanho teste',
          pastoId: 'pasto123',
          propriedadeId: 'prop123',
          dataCadastro: DateTime(2026),
        ),
      );

      final result = await service.verificarBloqueioExclusao(
        propriedadeId: 'prop123',
        pastoId: 'pasto123',
      );

      expect(result, isNotNull);
    });

    test('verificarBloqueioExclusao() deve bloquear por animal', () async {
      animalService.quantidadeAnimais = 2;

      final result = await service.verificarBloqueioExclusao(
        propriedadeId: 'prop123',
        pastoId: 'pasto123',
      );

      expect(result, isNotNull);
    });

    test(
      'verificarBloqueioExclusao() sem bloqueios deve retornar null',
      () async {
        final result = await service.verificarBloqueioExclusao(
          propriedadeId: 'prop123',
          pastoId: 'pasto123',
        );

        expect(result, null);
      },
    );

    test('possuiPoligono() deve retornar true quando existir', () async {
      poligonoRepository.possui = true;

      final result = await service.possuiPoligono(
        propriedadeId: 'prop123',
        pastoId: 'pasto123',
      );

      expect(result, true);
    });

    test('apagar() deve apagar pasto e polígono em batch', () async {
      await service.apagar(propriedadeId: 'prop123', pastoId: 'pasto123');

      expect(pastoRepository.apagou, true);
      expect(poligonoRepository.apagou, true);
    });

    test('apagar() deve impedir IDs vazios', () {
      expect(
        () => service.apagar(propriedadeId: '', pastoId: ''),
        throwsException,
      );
    });

    test('editar() deve editar pasto corretamente', () async {
      await service.editar(
        id: 'pasto123',
        nome: 'Pasto Editado',
        propriedadeId: 'prop123',
        area: 15,
        descricao: 'Nova descrição',
      );

      expect(pastoRepository.editou, true);
    });
  });
}
