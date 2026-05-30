import 'package:bov_manager/models/poligono_model.dart';
import 'package:bov_manager/services/poligono_service.dart';
import 'package:bov_manager/viewmodels/propriedade_viewmodel.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'poligono_viewmodel.g.dart';

// =============================================================================
// LISTA DE POLÍGONOS DA PROPRIEDADE EM VISUALIZAÇÃO
// =============================================================================

@riverpod
Stream<List<PoligonoModel>> poligonosLista(Ref ref) {
  final propriedadeId = ref.watch(propriedadeSelecionadaProvider).value?.id;
  if (propriedadeId == null) return const Stream.empty();
  return ref.read(poligonoServiceProvider).listarStream(propriedadeId);
}

// =============================================================================
// VIEWMODEL — SALVAR E APAGAR
// =============================================================================

@riverpod
class PoligonoViewModel extends _$PoligonoViewModel {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  String get _propriedadeId =>
      ref.read(propriedadeSelecionadaProvider).value?.id ?? '';

  PoligonoService get _service => ref.read(poligonoServiceProvider);

  // =========================
  // SALVAR POLÍGONO DO PASTO
  // =========================

  Future<bool> salvar({
    required String pastoId,
    required List<LatLngPoint> pontos,
  }) async {
    state = const AsyncLoading();
    try {
      await _service.salvar(
        propriedadeId: _propriedadeId,
        pastoId: pastoId,
        pontos: pontos,
      );
      if (!ref.mounted) return true;
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      if (!ref.mounted) return false;
      state = AsyncError(e, st);
      return false;
    }
  }

  // =========================
  // APAGAR POLÍGONO DO PASTO
  // =========================

  Future<void> apagar({required String pastoId}) async {
    state = const AsyncLoading();
    try {
      await _service.apagar(propriedadeId: _propriedadeId, pastoId: pastoId);
      ref.invalidate(poligonosListaProvider);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
