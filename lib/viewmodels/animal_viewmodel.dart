import 'package:bov_manager/models/animal_model.dart';
import 'package:bov_manager/models/historico_tipo.dart';
import 'package:bov_manager/repositories/usuario_repository.dart';
import 'package:bov_manager/services/animal_service.dart';
import 'package:bov_manager/viewmodels/propriedade_viewmodel.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'animal_viewmodel.g.dart';

// =============================================================================
// LISTA DE ANIMAIS DA PROPRIEDADE SELECIONADA
// =============================================================================

@riverpod
Stream<List<AnimalModel>> animaisLista(Ref ref) {
  final propriedadeId = ref.watch(propriedadeSelecionadaProvider).value!.id;

  return ref.read(animalServiceProvider).listar(propriedadeId);
}

@riverpod
Stream<List<AnimalModel>> animaisListaPropEmVis(Ref ref) {
  final propriedadeId = ref.watch(propriedadeEmVisualizacaoProvider)!.id;

  return ref.read(animalServiceProvider).listar(propriedadeId);
}
// =============================================================================
// ANIMAL EM VISUALIZAÇÃO (detalhes + histórico)
// =============================================================================

@Riverpod(keepAlive: true)
class AnimalEmVisualizacao extends _$AnimalEmVisualizacao {
  @override
  AnimalModel? build() => null;

  void abrir(AnimalModel animal) => state = animal;
  void fechar() => state = null;
}

// =============================================================================
// VIEWMODEL — CRUD
// =============================================================================

@riverpod
class AnimaisViewModel extends _$AnimaisViewModel {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  // ignore: unused_element
  String get _uid => ref.read(usuarioAtualProvider).requireValue!.id;

  String get _propriedadeId =>
      ref.read(propriedadeSelecionadaProvider).requireValue!.id;

  AnimalService get _service => ref.read(animalServiceProvider);

  // =========================
  // CRIAR
  // =========================

  Future<void> criar({
    required String nome,
    required String brinco,
    required String raca,
    required double pesoAtual,
    required DateTime dataNascimento,
    required String? rebanhoId,
    String? pastoDestinoId, // ← opcional: pasto inicial do animal
  }) async {
    state = const AsyncLoading();
    try {
      await _service.criar(
        nome: nome,
        brinco: brinco,
        raca: raca,
        novoPeso: pesoAtual,
        dataNascimento: dataNascimento,
        rebanhoId: rebanhoId,
        propriedadeId: _propriedadeId, // ← usa o getter
        pastoDestinoId: pastoDestinoId,
        //TODO: implementar foto
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  // =========================
  // EDITAR
  // =========================

  Future<void> editar({
    required String animalId,
    required String nome,
    required String brinco,
    required String raca,
    required double pesoAtual,
  }) async {
    state = const AsyncLoading();
    try {
      await _service.editar(
        animalId: animalId,
        nome: nome,
        brinco: brinco,
        raca: raca,
        pesoAtual: pesoAtual,
      );

      // Atualização local otimista do animal em visualização
      final emVisualizacao = ref.read(animalEmVisualizacaoProvider);
      if (emVisualizacao?.id == animalId) {
        ref
            .read(animalEmVisualizacaoProvider.notifier)
            .abrir(
              AnimalModel(
                id: emVisualizacao!.id,
                nome: nome,
                brinco: brinco,
                raca: raca,
                pesoAtual: pesoAtual,
                dataNascimento: emVisualizacao.dataNascimento,
                fotoUrl: emVisualizacao.fotoUrl,
              ),
            );
      }

      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  // =========================
  // APAGAR
  // =========================

  Future<void> apagar({required String animalId}) async {
    state = const AsyncLoading();
    try {
      await _service.apagar(animalId: animalId);

      final emVisualizacao = ref.read(animalEmVisualizacaoProvider);
      if (emVisualizacao?.id == animalId) {
        ref.read(animalEmVisualizacaoProvider.notifier).fechar();
      }

      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  // =========================
  // REGISTRAR PESAGEM
  // =========================

  Future<void> registrarHistoricoPesagem({
    required double novoPeso,
    required DateTime data,
    required HistoricoTipo tipo,
  }) async {
    final animal = ref.read(animalEmVisualizacaoProvider);
    if (animal == null) return;

    state = const AsyncLoading();

    try {
      await _service.registrarHistorico(
        animalId: animal.id,
        novoPeso: novoPeso,
        data: data,
        tipo: tipo,
        pastoOrigemId: null,
        pastoDestinoId: null,
        rebanhoOrigemId: null,
        rebanhoDestinoId: null,
      );

      // Atualização otimista local
      ref
          .read(animalEmVisualizacaoProvider.notifier)
          .abrir(
            AnimalModel(
              id: animal.id,
              nome: animal.nome,
              brinco: animal.brinco,
              raca: animal.raca,
              pesoAtual: novoPeso,
              dataNascimento: animal.dataNascimento,
              fotoUrl: animal.fotoUrl,
            ),
          );

      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> registrarHistoricoMovimento({
    required DateTime data,
    required HistoricoTipo tipo,
    String? pastoOrigemId,
    String? pastoDestinoId,
    String? rebanhoOrigemId,
    String? rebanhoDestinoId,
  }) async {
    final animal = ref.read(animalEmVisualizacaoProvider);
    if (animal == null) return;

    state = const AsyncLoading();

    try {
      await _service.registrarHistorico(
        animalId: animal.id,
        novoPeso: null,
        data: data,
        tipo: tipo,
        pastoOrigemId: pastoOrigemId,
        pastoDestinoId: pastoDestinoId,
        rebanhoOrigemId: rebanhoOrigemId,
        rebanhoDestinoId: rebanhoDestinoId,
      );

      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
