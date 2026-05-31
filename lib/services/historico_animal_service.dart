import 'package:bov_manager/models/historico_animal_model.dart';
import 'package:bov_manager/models/historico_tipo.dart';
import 'package:bov_manager/repositories/historico_animal_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'historico_animal_service.g.dart';

@riverpod
HistoricoAnimalService historicoAnimalService(Ref ref) {
  return HistoricoAnimalService(ref.watch(historicoAnimalRepositoryProvider));
}

class HistoricoAnimalService {
  const HistoricoAnimalService(this._repo);

  final HistoricoAnimalRepository _repo;

  Stream<List<HistoricoAnimalModel>> listar(String animalId) {
    return _repo.listar(animalId: animalId);
  }

  Future<void> criarHistorico({
    required String animalId,
    required HistoricoTipo tipo,
    required double? novoPeso,
    String? pastoOrigemId,
    String? pastoDestinoId,
    String? rebanhoOrigemId,
    String? rebanhoDestinoId,
    required WriteBatch batch,
  }) {
    return _repo.criarHistorico(
      animalId: animalId,
      tipo: tipo,
      novoPeso: novoPeso,
      pastoOrigemId: pastoOrigemId,
      pastoDestinoId: pastoDestinoId,
      rebanhoOrigemId: rebanhoOrigemId,
      rebanhoDestinoId: rebanhoDestinoId,
      batch: batch,
    );
  }

  Future<void> apagarTodosHistoricosAnimal({
    required String animalId,
    required WriteBatch batch,
  }) {
    return _repo.apagarTodosHistoricosAnimal(animalId: animalId, batch: batch);
  }

  Future<HistoricoAnimalModel?> buscarUltimaMovimentacao({
    required String animalId,
  }) {
    return _repo.buscarUltimaMovimentacao(animalId: animalId);
  }
}
