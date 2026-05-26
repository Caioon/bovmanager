import 'package:bov_manager/models/rebanho_model.dart';
import 'package:bov_manager/repositories/rebanho_repository.dart';
import 'package:bov_manager/services/rebanho_service.dart';
import 'package:bov_manager/viewmodels/propriedade_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'rebanho_viewmodel.g.dart';

// =============================================================================
// REBANHO EM VISUALIZAÇÃO
// =============================================================================

@riverpod
class RebanhoEmVisualizacao extends _$RebanhoEmVisualizacao {
  @override
  RebanhoModel? build() => null;

  void abrir(RebanhoModel rebanho) => state = rebanho;

  void fechar() => state = null;
}

// =============================================================================
// LISTA DE REBANHOS — propriedade em visualização
// =============================================================================

@riverpod
Stream<List<RebanhoModel>> rebanhoLista(Ref ref) {
  final propriedadeId =
      ref.watch(propriedadeEmVisualizacaoProvider)?.id ?? '';

  if (propriedadeId.isEmpty) {
    return const Stream.empty();
  }

  return ref.watch(rebanhoRepositoryProvider).listarStream(propriedadeId);
}

// =============================================================================
// LISTA DE REBANHOS — propriedade selecionada (dashboard)
// =============================================================================

@riverpod
Stream<List<RebanhoModel>> rebanhosSelecionados(Ref ref) {
  final propriedadeId =
      ref.watch(propriedadeSelecionadaProvider).value?.id;

  if (propriedadeId == null) {
    return const Stream.empty();
  }

  return ref.watch(rebanhoRepositoryProvider).listarStream(propriedadeId);
}

// =============================================================================
// VIEWMODEL — CRUD
// =============================================================================

@riverpod
class RebanhoViewModel extends _$RebanhoViewModel {
  @override
  Future<void> build() async {}

  RebanhoService get _service => ref.read(rebanhoServiceProvider);

  String get _propriedadeId =>
      ref.read(propriedadeEmVisualizacaoProvider)?.id ?? '';

  Future<void> criar({
    required String nome,
    required String pastoId,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(
      () => _service.criar(
        nome: nome,
        pastoId: pastoId,
        propriedadeId: _propriedadeId,
      ),
    );
  }

  Future<void> mover({
    required String rebanhoId,
    required String novoPastoId,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(
      () => _service.mover(
        rebanhoId: rebanhoId,
        propriedadeId: _propriedadeId,
        novoPastoId: novoPastoId,
      ),
    );
  }

  Future<void> apagar({
    required String rebanhoId,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(
      () => _service.apagar(
        rebanhoId: rebanhoId,
        propriedadeId: _propriedadeId,
      ),
    );
  }
}
