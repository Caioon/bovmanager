import 'package:bov_manager/models/historico_animal_model.dart';
import 'package:bov_manager/repositories/historico_animal_repository.dart';
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

  Future<void> adicionar({
    required String animalId,
    required String tipo,
    required double valor,
    String? pastoOrigemId,
    String? pastoDestinoId,
  }) {
    return _repo.adicionar(
      animalId: animalId,
      tipo: tipo,
      valor: valor,
      pastoOrigemId: pastoOrigemId,
      pastoDestinoId: pastoDestinoId,
    );
  }
}
