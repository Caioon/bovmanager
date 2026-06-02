import 'package:bov_manager/models/animal_model.dart';
import 'package:bov_manager/models/historico_tipo.dart';
import 'package:bov_manager/repositories/animal_repository.dart';
import 'package:bov_manager/services/historico_animal_service.dart';
import 'package:bov_manager/services/rebanho_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'animal_service.g.dart';

@riverpod
AnimalService animalService(Ref ref) {
  return AnimalService(
    ref.watch(animalRepositoryProvider),
    ref.read(historicoAnimalServiceProvider),
    ref.read(rebanhoServiceProvider), 
    FirebaseFirestore.instance,
  );
}

class AnimalService {
  const AnimalService(
    this._repo,
    this._historicoService,
    this._rebanhoService,
    this._firestore,
  );

  final AnimalRepository _repo;
  final HistoricoAnimalService _historicoService;
  final RebanhoService _rebanhoService;
  final FirebaseFirestore _firestore;

  Stream<List<AnimalModel>> listar(String propriedadeId) {
    return _repo.listarPorPropriedade(propriedadeId: propriedadeId);
  }

  // ---------------------------------------------------------------------------
  // Contar animais em um pasto específico
  // Conta:
  //   1. Animais sem rebanho cuja última movimentação tem pastoDestinoId == pastoId
  //   2. Animais vinculados a rebanhos cujo pastoId == pastoId
  // ---------------------------------------------------------------------------
  Future<int> contarAnimaisPorPasto({
    required String propriedadeId,
    required String pastoId,
  }) async {
    // Busca todos os animais e rebanhos em paralelo
    final animais = await _repo.listarPorPropriedade(propriedadeId: propriedadeId).first;
    final rebanhos = await _rebanhoService.listar(propriedadeId);

    // IDs dos rebanhos que estão neste pasto
    final rebanhoIdsNoPasto = rebanhos
        .where((r) => r.pastoId == pastoId)
        .map((r) => r.id)
        .toSet();

    // Para cada animal, busca sua última movimentação em paralelo
    final futures = animais.map((animal) async {
      final ultima = await _historicoService.buscarUltimaMovimentacao(
        animalId: animal.id,
      );
      if (ultima == null) return false;

      // Animal com rebanho: conta se o rebanho está neste pasto
      if (ultima.rebanhoDestinoId != null) {
        return rebanhoIdsNoPasto.contains(ultima.rebanhoDestinoId);
      }

      // Animal sem rebanho: conta se o último destino é este pasto
      return ultima.pastoDestinoId == pastoId;
    });

    final resultadosAnimais = await Future.wait(futures);
    return resultadosAnimais.where((pertence) => pertence).length;
  }

  Future<void> criar({
    required String nome,
    required String brinco,
    required String raca,
    required double novoPeso,
    required DateTime dataNascimento,
    required String? rebanhoId,
    required String propriedadeId,
    String? pastoDestinoId,
    String? fotoUrl,
  }) async {
    final batch = _firestore.batch();
    final animalId = await _repo.criarAnimal(
      nome: nome,
      brinco: brinco,
      raca: raca,
      pesoAtual: novoPeso,
      dataNascimento: dataNascimento,
      propriedadeId: propriedadeId,
      pastoDestinoId: pastoDestinoId,
      batch: batch,
      fotoUrl: fotoUrl,
    );

    await _historicoService.criarHistorico(
      animalId: animalId,
      tipo: HistoricoTipo.entrada,
      novoPeso: novoPeso,
      pastoOrigemId: null,
      pastoDestinoId: pastoDestinoId,
      rebanhoOrigemId: null,
      rebanhoDestinoId: rebanhoId,
      batch: batch,
    );

    await batch.commit();
  }

  Future<void> editar({
    required String animalId,
    required String nome,
    required String brinco,
    required String raca,
    required double pesoAtual,
    String? fotoUrl,
  }) {
    return _repo.editarAnimal(
      animalId: animalId,
      nome: nome,
      brinco: brinco,
      raca: raca,
      fotoUrl: fotoUrl,
    );
  }

  Future<void> apagar({required String animalId}) async {
    final batch = _firestore.batch();

    await _historicoService.apagarTodosHistoricosAnimal(
      animalId: animalId,
      batch: batch,
    );

    await _repo.apagarAnimal(animalId: animalId, batch: batch);

    await batch.commit();
  }

  Future<void> registrarHistorico({
    required String animalId,
    required double? novoPeso,
    required DateTime data,
    required HistoricoTipo tipo,
    String? pastoOrigemId,
    String? pastoDestinoId,
    String? rebanhoOrigemId,
    String? rebanhoDestinoId,
  }) async {
    final batch = _firestore.batch();

    if (tipo == HistoricoTipo.pesagem) {
      await _repo.registrarPesagem(
        batch: batch,
        animalId: animalId,
        novoPeso: novoPeso!,
        data: data,
      );
    }

    await _historicoService.criarHistorico(
      animalId: animalId,
      tipo: tipo,
      novoPeso: novoPeso,
      pastoOrigemId: pastoOrigemId,
      pastoDestinoId: pastoDestinoId,
      rebanhoOrigemId: rebanhoOrigemId,
      rebanhoDestinoId: rebanhoDestinoId,
      batch: batch,
    );
    await batch.commit();
  }
}
