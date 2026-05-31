import 'package:bov_manager/models/historico_animal_model.dart';
import 'package:bov_manager/services/historico_animal_service.dart';
import 'package:bov_manager/viewmodels/animal_viewmodel.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'historico_animal_viewmodel.g.dart';

// =============================================================================
// LISTA DE HISTÓRICO DO ANIMAL EM VISUALIZAÇÃO
// =============================================================================

@riverpod
Stream<List<HistoricoAnimalModel>> historicoAnimalLista(Ref ref) {
  final animalId = ref.watch(animalEmVisualizacaoProvider)?.id;
  if (animalId == null) return const Stream.empty();
  return ref.read(historicoAnimalServiceProvider).listar(animalId);
}

// =============================================================================
// VIEWMODEL — CRUD
// =============================================================================

@riverpod
class HistoricoAnimalViewModel extends _$HistoricoAnimalViewModel {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  HistoricoAnimalService get _service =>
      ref.read(historicoAnimalServiceProvider);
}
