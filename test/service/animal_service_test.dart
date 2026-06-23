import 'package:bov_manager/models/animal_model.dart';
import 'package:bov_manager/models/historico_animal_model.dart';
import 'package:bov_manager/models/historico_tipo.dart';
import 'package:bov_manager/models/rebanho_model.dart';
import 'package:bov_manager/repositories/animal_repository.dart';
import 'package:bov_manager/repositories/historico_animal_repository.dart';
import 'package:bov_manager/repositories/rebanho_repository.dart';
import 'package:bov_manager/services/animal_service.dart';
import 'package:bov_manager/services/historico_animal_service.dart';
import 'package:bov_manager/services/rebanho_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';

class MockAnimalRepository extends AnimalRepository {
  final List<AnimalModel> animais = [];

  bool criou = false;
  bool editou = false;
  bool apagou = false;
  bool registrouPesagem = false;

  @override
  Stream<List<AnimalModel>> listarPorPropriedade({
    required String propriedadeId,
  }) {
    return Stream.value(
      animais.where((a) => a.propriedadeId == propriedadeId).toList(),
    );
  }

  @override
  Future<String> criarAnimal({
    required String nome,
    required String brinco,
    required String raca,
    required double pesoAtual,
    required DateTime dataNascimento,
    required String propriedadeId,
    String? pastoDestinoId,
    String? fotoUrl,
    required WriteBatch batch,
  }) async {
    criou = true;
    return 'animal123';
  }

  @override
  Future<void> editarAnimal({
    required String animalId,
    required String nome,
    required String brinco,
    required String raca,
    String? fotoUrl,
  }) async {
    editou = true;
  }

  @override
  Future<void> apagarAnimal({
    required String animalId,
    required WriteBatch batch,
  }) async {
    apagou = true;
  }

  @override
  Future<void> registrarPesagem({
    required String animalId,
    required double novoPeso,
    required DateTime data,
    required WriteBatch batch,
  }) async {
    registrouPesagem = true;
  }

  @override
  Stream<List<HistoricoAnimalModel>> listarHistorico({
    required String animalId,
  }) {
    return Stream.value([]);
  }
}

class MockHistoricoAnimalService extends HistoricoAnimalService {
  MockHistoricoAnimalService() : super(MockHistoricoAnimalRepository());

  bool criouHistorico = false;
  bool apagouHistoricos = false;

  @override
  Future<void> criarHistorico({
    required String animalId,
    required HistoricoTipo tipo,
    required double? novoPeso,
    required DateTime data,
    String? pastoOrigemId,
    String? pastoDestinoId,
    String? rebanhoOrigemId,
    String? rebanhoDestinoId,
    String? nomePastoOrigem,
    String? nomePastoDestino,
    String? nomeRebanhoOrigem,
    String? nomeRebanhoDestino,
    required WriteBatch batch,
  }) async {
    criouHistorico = true;
  }

  @override
  Future<void> apagarTodosHistoricosAnimal({
    required String animalId,
    required WriteBatch batch,
  }) async {
    apagouHistoricos = true;
  }

  @override
  Future<HistoricoAnimalModel?> buscarUltimaMovimentacao({
    required String animalId,
  }) async {
    return null;
  }
}

class MockHistoricoAnimalRepository extends HistoricoAnimalRepository {
  @override
  Stream<List<HistoricoAnimalModel>> listar({required String animalId}) {
    return Stream.value([]);
  }

  @override
  Future<void> criarHistorico({
    required String animalId,
    required HistoricoTipo tipo,
    required double? novoPeso,
    required DateTime data,
    String? pastoOrigemId,
    String? pastoDestinoId,
    String? rebanhoOrigemId,
    String? rebanhoDestinoId,
    String? nomePastoOrigem,
    String? nomePastoDestino,
    String? nomeRebanhoOrigem,
    String? nomeRebanhoDestino,
    required WriteBatch batch,
  }) async {}

  @override
  Future<void> apagarTodosHistoricosAnimal({
    required String animalId,
    required WriteBatch batch,
  }) async {}

  @override
  Future<HistoricoAnimalModel?> buscarUltimaMovimentacao({
    required String animalId,
  }) async {
    return null;
  }
}

class MockRebanhoRepository extends RebanhoRepository {
  MockRebanhoRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  }) : super(firestore: firestore, auth: auth);

  @override
  Future<List<RebanhoModel>> listar(String propriedadeId) async {
    return [];
  }
}

class MockRebanhoService extends RebanhoService {
  MockRebanhoService()
    : super(
        repository: MockRebanhoRepository(
          firestore: FakeFirebaseFirestore(),
          auth: MockFirebaseAuth(),
        ),
        animalRepository: MockAnimalRepository(),
        historicoService: MockHistoricoAnimalService(),
        firestore: FakeFirebaseFirestore(),
      );

  @override
  Future<List<RebanhoModel>> listar(String propriedadeId) async {
    return [];
  }
}

void main() {
  group('AnimalService', () {
    late MockAnimalRepository repo;
    late MockHistoricoAnimalService historicoService;
    late MockRebanhoService rebanhoService;
    late AnimalService service;

    setUp(() {
      final firestore = FakeFirebaseFirestore();

      repo = MockAnimalRepository();
      historicoService = MockHistoricoAnimalService();
      rebanhoService = MockRebanhoService();

      service = AnimalService(
        repo,
        historicoService,
        rebanhoService,
        firestore,
      );
    });

    test('listar() deve retornar stream de animais', () async {
      repo.animais.add(
        AnimalModel(
          id: 'animal123',
          nome: 'Boi',
          brinco: '001',
          raca: 'Nelore',
          pesoAtual: 400,
          dataNascimento: DateTime(2020),
          propriedadeId: 'propriedade123',
          fotoUrl: null,
        ),
      );

      final result = await service.listar('propriedade123').first;

      expect(result.length, 1);
      expect(result.first.id, 'animal123');
    });

    test('criar() deve criar animal', () async {
      await service.criar(
        nome: 'Boi',
        brinco: '001',
        raca: 'Nelore',
        novoPeso: 400,
        dataNascimento: DateTime(2020),
        rebanhoId: null,
        propriedadeId: 'propriedade123',
      );
      expect(repo.criou, true);
      expect(historicoService.criouHistorico, true);
    });

    test('editar() deve editar animal', () async {
      await service.editar(
        animalId: 'animal123',
        nome: 'Novo',
        brinco: '002',
        raca: 'Nelore',
        pesoAtual: 420,
      );
      expect(repo.editou, true);
    });
    test('apagar() deve apagar animal', () async {
      await service.apagar(animalId: 'animal123');
      expect(repo.apagou, true);
      expect(historicoService.apagouHistoricos, true);
    });

    test('registrarHistorico deve criar histórico', () async {
      await service.registrarHistorico(
        animalId: 'animal123',
        novoPeso: 450,
        data: DateTime(2026),
        tipo: HistoricoTipo.pesagem,
      );

      expect(historicoService.criouHistorico, true);
    });

    test('contarAnimaisPorPasto retorna zero', () async {
      final result = await service.contarAnimaisPorPasto(
        propriedadeId: 'prop123',
        pastoId: 'pasto123',
      );
      expect(result, 0);
    });
  });
}
