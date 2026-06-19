import 'package:bov_manager/models/tarefa_model.dart';
import 'package:bov_manager/repositories/usuario_repository.dart';
import 'package:bov_manager/services/tarefa_service.dart';
import 'package:bov_manager/viewmodels/propriedade_viewmodel.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tarefa_viewmodel.g.dart';

// =============================================================================
// STREAM DE TAREFAS DA PROPRIEDADE SELECIONADA
// =============================================================================

@riverpod
Stream<List<TarefaModel>> tarefasLista(Ref ref) {
  final propriedadeId = ref.watch(propriedadeSelecionadaProvider).value?.id;
  if (propriedadeId == null) return const Stream.empty();
  return ref.read(tarefaServiceProvider).listar(propriedadeId);
}

// =============================================================================
// VIEWMODEL — CRUD
// =============================================================================

@riverpod
class TarefasViewModel extends _$TarefasViewModel {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  String get _propriedadeId =>
      ref.read(propriedadeSelecionadaProvider).requireValue!.id;

  String get _usuarioId => ref.read(usuarioAtualProvider).requireValue!.id;

  TarefaService get _service => ref.read(tarefaServiceProvider);

  Future<void> criar({
    required String titulo,
    required String descricao,
    required DateTime dataExecucao,
    int? horaExecucaoMinutos,
  }) async {
    state = const AsyncLoading();
    try {
      await _service.criar(
        titulo: titulo,
        descricao: descricao,
        dataExecucao: dataExecucao,
        propriedadeId: _propriedadeId,
        usuarioId: _usuarioId,
        horaExecucaoMinutos: horaExecucaoMinutos,
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> editar({
    required String tarefaId,
    required String titulo,
    required String descricao,
    required DateTime dataExecucao,
    int? horaExecucaoMinutos,
    bool clearHora = false,
  }) async {
    state = const AsyncLoading();
    try {
      await _service.editar(
        propriedadeId: _propriedadeId,
        tarefaId: tarefaId,
        titulo: titulo,
        descricao: descricao,
        dataExecucao: dataExecucao,
        horaExecucaoMinutos: horaExecucaoMinutos,
        clearHora: clearHora,
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> concluir({required String tarefaId}) async {
    state = const AsyncLoading();
    try {
      await _service.concluir(
        propriedadeId: _propriedadeId,
        tarefaId: tarefaId,
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// Reabre a tarefa e reagenda suas notificações.
  /// Recebe o [TarefaModel] completo (já disponível na UI) para evitar
  /// uma leitura extra no Firestore.
  Future<void> reabrir({required TarefaModel tarefa}) async {
    state = const AsyncLoading();
    try {
      await _service.reabrir(
        propriedadeId: _propriedadeId,
        tarefa: tarefa,
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> adiar({
    required String tarefaId,
    required DateTime novaData,
    required String titulo,
    int? horaExecucaoMinutos,
    bool clearHora = false,
  }) async {
    state = const AsyncLoading();
    try {
      await _service.adiar(
        propriedadeId: _propriedadeId,
        tarefaId: tarefaId,
        novaData: novaData,
        titulo: titulo,
        horaExecucaoMinutos: horaExecucaoMinutos,
        clearHora: clearHora,
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> apagar({required String tarefaId}) async {
    state = const AsyncLoading();
    try {
      await _service.apagar(
        propriedadeId: _propriedadeId,
        tarefaId: tarefaId,
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
