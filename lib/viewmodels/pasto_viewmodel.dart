import 'package:bov_manager/models/pasto_model.dart';
import 'package:bov_manager/repositories/pasto_repository.dart';
import 'package:bov_manager/services/pasto_service.dart';
import 'package:bov_manager/viewmodels/propriedade_viewmodel.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pasto_viewmodel.g.dart';

// =============================================================================
// LISTA DE PASTOS DA PROPRIEDADE EM VISUALIZAÇÃO
// =============================================================================

@riverpod
Stream<List<PastoModel>> pastosLista(Ref ref) {
  final propriedadeId =
      ref.watch(propriedadeEmVisualizacaoProvider)?.id ?? '';

  if (propriedadeId.isEmpty) {
    return const Stream.empty();
  }

  return ref.watch(pastoRepositoryProvider).listarStream(propriedadeId);
}

// =============================================================================
// PASTO EM VISUALIZAÇÃO
// =============================================================================

@Riverpod(keepAlive: true)
class PastoEmVisualizacao extends _$PastoEmVisualizacao {
  @override
  PastoModel? build() => null;

  void abrir(PastoModel pasto) => state = pasto;
  void fechar() => state = null;
}


// =============================================================================
// PASTO DA PROPRIEDADE SELECIONADA (DASHBOARD)
// =============================================================================
@riverpod
Stream<List<PastoModel>> pastosSelecionados(Ref ref) {
  final propriedadeId =
      ref.watch(propriedadeSelecionadaProvider).value?.id;

  if (propriedadeId == null) {
    return const Stream.empty();
  }

  return ref.watch(pastoRepositoryProvider).listarStream(propriedadeId);
}

// =============================================================================
// VIEWMODEL — CRUD
// =============================================================================

@riverpod
class PastosViewModel extends _$PastosViewModel {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  String get _propriedadeId =>
      ref.read(propriedadeEmVisualizacaoProvider)!.id;

  PastoService get _service => ref.read(pastoServiceProvider);

  // =========================
  // CRIAR
  // =========================

  Future<void> criar({
    required String nome,
    required double area,
    required String descricao,
  }) async {
    state = const AsyncLoading();
    try {
      await _service.criar(
        nome: nome,
        propriedadeId: _propriedadeId,
        area: area,
        descricao: descricao,
      );
      ref.invalidate(pastosListaProvider);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  // =========================
  // EDITAR
  // =========================

  Future<void> editar({
    required String pastoId,
    required String nome,
    required double area,
    required String descricao,
  }) async {
    state = const AsyncLoading();
    try {
      await _service.editar(
        id: pastoId,
        nome: nome,
        propriedadeId: _propriedadeId,
        area: area,
        descricao: descricao,
      );
      ref.invalidate(pastosListaProvider);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  // =========================
  // APAGAR
  // =========================

  Future<void> apagar({required String pastoId}) async {
    state = const AsyncLoading();
    try {
      await _service.apagar(
        propriedadeId: _propriedadeId,
        pastoId: pastoId,
      );
      ref.invalidate(pastosListaProvider);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
