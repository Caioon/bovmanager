import 'package:bov_manager/models/rebanho_model.dart';
import 'package:bov_manager/models/historico_tipo.dart';
import 'package:bov_manager/repositories/animal_repository.dart';
import 'package:bov_manager/repositories/rebanho_repository.dart';
import 'package:bov_manager/services/historico_animal_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// =============================================================================
// PROVIDER
// =============================================================================

final rebanhoServiceProvider = Provider<RebanhoService>((ref) {
  return RebanhoService(
    repository: ref.watch(rebanhoRepositoryProvider),
    animalRepository: ref.watch(animalRepositoryProvider),
    historicoService: ref.watch(historicoAnimalServiceProvider),
    firestore: FirebaseFirestore.instance,
  );
});

// =============================================================================
// SERVICE
// =============================================================================

class RebanhoService {
  RebanhoService({
    required this.repository,
    required this.animalRepository,
    required this.historicoService,
    required this.firestore,
  });

  final RebanhoRepository repository;
  final AnimalRepository animalRepository;
  final HistoricoAnimalService historicoService;
  final FirebaseFirestore firestore;

  // ---------------------------------------------------------------------------
  // Listar
  // ---------------------------------------------------------------------------
  Future<List<RebanhoModel>> listar(String propriedadeId) {
    return repository.listar(propriedadeId);
  }

  // ---------------------------------------------------------------------------
  // Criar
  // ---------------------------------------------------------------------------
  Future<void> criar({
    required String nome,
    required String pastoId,
    required String propriedadeId,
  }) {
    if (nome.trim().isEmpty) {
      throw Exception('O nome do rebanho é obrigatório.');
    }
    if (pastoId.isEmpty) {
      throw Exception('Selecione um pasto para o rebanho.');
    }

    final model = RebanhoModel(
      id: '',
      nome: nome.trim(),
      pastoId: pastoId,
      propriedadeId: propriedadeId,
      dataCadastro: DateTime.now(),
    );

    return repository.criar(model);
  }

  // ---------------------------------------------------------------------------
  // Mover — atualiza o pastoId do rebanho e cria histórico para cada animal
  // ---------------------------------------------------------------------------
  Future<void> mover({
    required String rebanhoId,
    required String propriedadeId,
    required String antigoPastoId,
    required String novoPastoId,
  }) async {
    if (novoPastoId.isEmpty) {
      throw Exception('Selecione o pasto de destino.');
    }

    final animais = await animalRepository
        .listarPorPropriedade(propriedadeId: propriedadeId)
        .first;

    final futures = animais.map((animal) async {
      final ultima = await historicoService.buscarUltimaMovimentacao(
        animalId: animal.id,
      );
      if (ultima?.rebanhoDestinoId == rebanhoId) return animal;
      return null;
    });

    final resultados = await Future.wait(futures);
    final animaisDoRebanho = resultados.whereType<dynamic>()
        .where((a) => a != null)
        .toList();

    final batch = firestore.batch();

    repository.moverEmBatch(
      propriedadeId: propriedadeId,
      rebanhoId: rebanhoId,
      novoPastoId: novoPastoId,
      batch: batch,
    );

    for (final animal in animaisDoRebanho) {
      await historicoService.criarHistorico(
        animalId: animal.id,
        tipo: HistoricoTipo.mudarPastoComRebanho,
        novoPeso: null,
        pastoOrigemId: antigoPastoId,
        pastoDestinoId: novoPastoId,
        rebanhoOrigemId: rebanhoId,
        rebanhoDestinoId: rebanhoId,
        batch: batch,
      );
    }

    await batch.commit();
  }

  // ---------------------------------------------------------------------------
  // Apagar
  // ---------------------------------------------------------------------------
  Future<void> apagar({
    required String rebanhoId,
    required String propriedadeId,
  }) {
    return repository.apagar(
      propriedadeId: propriedadeId,
      rebanhoId: rebanhoId,
    );
  }
}
