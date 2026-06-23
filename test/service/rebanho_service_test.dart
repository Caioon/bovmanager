import 'package:bov_manager/models/animal_model.dart';
import 'package:bov_manager/models/historico_animal_model.dart';
import 'package:bov_manager/models/historico_tipo.dart';
import 'package:bov_manager/repositories/animal_repository.dart';
import 'package:bov_manager/repositories/rebanho_repository.dart';
import 'package:bov_manager/services/historico_animal_service.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bov_manager/models/rebanho_model.dart';
import 'package:bov_manager/services/rebanho_service.dart';

import 'historico_animal_service_test.dart';

class MockRebanhoRepository extends RebanhoRepository {
  MockRebanhoRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  }) : super(firestore: firestore, auth: auth);

  final List<RebanhoModel> rebanhos = [];

  bool criou = false;
  bool moveu = false;
  bool apagou = false;

  @override
  Future<List<RebanhoModel>> listar(String propriedadeId) async {
    return rebanhos.where((r) => r.propriedadeId == propriedadeId).toList();
  }

  @override
  Future<void> criar(RebanhoModel rebanho) async {
    criou = true;
  }

  @override
  void moverEmBatch({
    required String propriedadeId,
    required String rebanhoId,
    required String novoPastoId,
    required WriteBatch batch,
  }) {
    moveu = true;
  }

  @override
  Future<void> apagar({
    required String propriedadeId,
    required String rebanhoId,
  }) async {
    apagou = true;
  }
}

class MockAnimalRepository extends AnimalRepository {
  MockAnimalRepository(this.firestore);

  final FirebaseFirestore firestore;

  final List<AnimalModel> animais = [];
  final List<HistoricoAnimalModel> historicos = [];

  bool criou = false;
  bool editou = false;
  bool apagou = false;
  bool pesou = false;

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
    pesou = true;
  }

  @override
  Stream<List<HistoricoAnimalModel>> listarHistorico({
    required String animalId,
  }) {
    return Stream.value(
      historicos.where((h) => h.animalId == animalId).toList(),
    );
  }
}

class MockHistoricoService extends HistoricoAnimalService {
  MockHistoricoService() : super(MockHistoricoAnimalRepository());

  bool criouHistorico = false;

  Future<HistoricoAnimalModel?> Function({required String animalId})?
  buscarUltimaMovimentacaoMock;

  @override
  Future<HistoricoAnimalModel?> buscarUltimaMovimentacao({
    required String animalId,
  }) async {
    if (buscarUltimaMovimentacaoMock != null) {
      return buscarUltimaMovimentacaoMock!(animalId: animalId);
    }

    return null;
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
  }) async {
    criouHistorico = true;
  }
}

void main() {
  group('RebanhoService', () {
    late MockRebanhoRepository repository;
    late MockAnimalRepository animalRepository;
    late MockHistoricoService historicoService;
    late RebanhoService service;
    late FakeFirebaseFirestore firestore;

    final rebanho = RebanhoModel(
      id: 'rebanho123',
      nome: 'Rebanho A',
      pastoId: 'pasto123',
      propriedadeId: 'prop123',
      dataCadastro: DateTime(2026),
    );

    setUp(() {
      firestore = FakeFirebaseFirestore();

      repository = MockRebanhoRepository(
        firestore: firestore,
        auth: MockFirebaseAuth(),
      );

      animalRepository = MockAnimalRepository(firestore);

      historicoService = MockHistoricoService();

      service = RebanhoService(
        repository: repository as dynamic,
        animalRepository: animalRepository as dynamic,
        historicoService: historicoService as dynamic,
        firestore: firestore,
      );
    });
    test('listar() deve retornar rebanhos da propriedade', () async {
      repository.rebanhos.add(rebanho);
      final result = await service.listar('prop123');
      expect(result.length, 1);
      expect(result.first.id, 'rebanho123');
      expect(result.first.nome, 'Rebanho A');
    });

    test('criar() deve criar rebanho corretamente', () async {
      await service.criar(
        nome: 'Novo Rebanho',
        pastoId: 'pasto123',
        propriedadeId: 'prop123',
      );
      expect(repository.criou, true);
    });

    test('criar() deve impedir nome vazio', () {
      expect(
        () => service.criar(
          nome: '',
          pastoId: 'pasto123',
          propriedadeId: 'prop123',
        ),

        throwsException,
      );
    });

    test('criar() deve impedir pasto vazio', () {
      expect(
        () => service.criar(
          nome: 'Rebanho',
          pastoId: '',
          propriedadeId: 'prop123',
        ),
        throwsException,
      );
    });

    test('mover() deve atualizar rebanho em batch', () async {
      await service.mover(
        rebanhoId: 'rebanho123',
        propriedadeId: 'prop123',
        antigoPastoId: 'pastoAntigo',
        novoPastoId: 'pastoNovo',
        data: DateTime(2026),
      );
      expect(repository.moveu, true);
    });

    test('mover() deve impedir pasto destino vazio', () {
      expect(
        () => service.mover(
          rebanhoId: 'rebanho123',
          propriedadeId: 'prop123',
          antigoPastoId: 'pastoAntigo',
          novoPastoId: '',
          data: DateTime(2026),
        ),
        throwsException,
      );
    });

    test('podeApagarRebanho() sem animais deve retornar null', () async {
      final result = await service.podeApagarRebanho(
        rebanhoId: 'rebanho123',
        propriedadeId: 'prop123',
      );
      expect(result, null);
    });

    test(
      'podeApagarRebanho() deve retornar bloqueio quando possuir animais',
      () async {
        animalRepository.animais.add(
          AnimalModel(
            id: 'animal123',
            nome: 'Boi Teste',
            brinco: '001',
            raca: 'Nelore',
            pesoAtual: 400,
            dataNascimento: DateTime(2020),
            propriedadeId: 'prop123',
          ),
        );
        historicoService.buscarUltimaMovimentacaoMock =
            ({required String animalId}) async {
              return HistoricoAnimalModel(
                id: 'hist123',
                animalId: 'animal123',
                tipo: HistoricoTipo.mudarRebanho,
                data: DateTime(2026),
                rebanhoDestinoId: 'rebanho123',
                novoPeso: null,
              );
            };

        final result = await service.podeApagarRebanho(
          rebanhoId: 'rebanho123',
          propriedadeId: 'prop123',
        );
        expect(result, isNotNull);
      },
    );

    test('apagarRebanho() deve chamar remoção no repositório', () async {
      await service.apagarRebanho(
        rebanhoId: 'rebanho123',
        propriedadeId: 'prop123',
      );
      expect(repository.apagou, true);
    });
  });
}
