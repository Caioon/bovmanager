import 'package:bov_manager/models/tarefa_model.dart';
import 'package:bov_manager/repositories/tarefa_repository.dart';
import 'package:bov_manager/services/notification_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'tarefa_service.g.dart';

@riverpod
TarefaService tarefaService(Ref ref) {
  return TarefaService(
    ref.watch(tarefaRepositoryProvider),
    ref.watch(notificationServiceProvider),
  );
}

class TarefaService {
  TarefaService(this._repository, this._notifications);

  final TarefaRepository _repository;
  final NotificationService _notifications;

  Stream<List<TarefaModel>> listar(String propriedadeId) {
    if (propriedadeId.isEmpty) throw Exception('ID da propriedade inválido.');
    return _repository.listar(propriedadeId);
  }

  Future<void> criar({
    required String titulo,
    required String descricao,
    required DateTime dataExecucao,
    required String propriedadeId,
    required String usuarioId,
    int? horaExecucaoMinutos,
  }) async {
    if (titulo.trim().isEmpty) {
      throw Exception('O título da tarefa não pode ser vazio.');
    }
    if (propriedadeId.isEmpty) throw Exception('ID da propriedade inválido.');
    if (usuarioId.isEmpty) throw Exception('ID do usuário inválido.');

    final tarefa = TarefaModel(
      id: '',
      titulo: titulo.trim(),
      descricao: descricao.trim(),
      dataExecucao: dataExecucao,
      status: StatusTarefa.pendente,
      propriedadeId: propriedadeId,
      usuarioId: usuarioId,
      horaExecucaoMinutos: horaExecucaoMinutos,
    );

    final tarefaId = await _repository.criar(tarefa);

    if (await _notificacoesAtivas()) {
      await _notifications.agendarNotificacaoTarefa(
        tarefa.copyWith(id: tarefaId),
      );
    }
  }

  Future<void> editar({
    required String propriedadeId,
    required String tarefaId,
    required String titulo,
    required String descricao,
    required DateTime dataExecucao,
    int? horaExecucaoMinutos,
    bool clearHora = false,
  }) async {
    if (titulo.trim().isEmpty) {
      throw Exception('O título da tarefa não pode ser vazio.');
    }
    if (propriedadeId.isEmpty || tarefaId.isEmpty) {
      throw Exception('IDs inválidos.');
    }

    await _repository.atualizar(
      propriedadeId: propriedadeId,
      tarefaId: tarefaId,
      titulo: titulo.trim(),
      descricao: descricao.trim(),
      dataExecucao: dataExecucao,
      horaExecucaoMinutos: horaExecucaoMinutos,
      clearHora: clearHora,
    );

    if (await _notificacoesAtivas()) {
      await _notifications.cancelarNotificacaoTarefa(tarefaId);
      await _notifications.agendarNotificacaoTarefa(
        TarefaModel(
          id: tarefaId,
          titulo: titulo.trim(),
          descricao: descricao.trim(),
          dataExecucao: dataExecucao,
          status: StatusTarefa.pendente,
          propriedadeId: propriedadeId,
          usuarioId: '',
          horaExecucaoMinutos: clearHora ? null : horaExecucaoMinutos,
        ),
      );
    }
  }

  Future<void> concluir({
    required String propriedadeId,
    required String tarefaId,
  }) async {
    if (propriedadeId.isEmpty || tarefaId.isEmpty) {
      throw Exception('IDs inválidos.');
    }
    await _repository.atualizarStatus(
      propriedadeId: propriedadeId,
      tarefaId: tarefaId,
      status: StatusTarefa.concluida,
    );
    await _notifications.cancelarNotificacaoTarefa(tarefaId);
  }

  /// Reabre a tarefa e reagenda suas notificações.
  /// Recebe o [TarefaModel] completo para permitir o reagendamento sem
  /// uma leitura extra no Firestore.
  Future<void> reabrir({
    required String propriedadeId,
    required TarefaModel tarefa,
  }) async {
    if (propriedadeId.isEmpty || tarefa.id.isEmpty) {
      throw Exception('IDs inválidos.');
    }
    await _repository.atualizarStatus(
      propriedadeId: propriedadeId,
      tarefaId: tarefa.id,
      status: StatusTarefa.pendente,
    );
    if (await _notificacoesAtivas()) {
      await _notifications.agendarNotificacaoTarefa(tarefa);
    }
  }

  Future<void> adiar({
    required String propriedadeId,
    required String tarefaId,
    required DateTime novaData,
    required String titulo,
    int? horaExecucaoMinutos,
  }) async {
    if (propriedadeId.isEmpty || tarefaId.isEmpty) {
      throw Exception('IDs inválidos.');
    }
    await _repository.atualizarData(
      propriedadeId: propriedadeId,
      tarefaId: tarefaId,
      novaData: novaData,
    );

    if (await _notificacoesAtivas()) {
      await _notifications.cancelarNotificacaoTarefa(tarefaId);
      await _notifications.agendarNotificacaoTarefa(
        TarefaModel(
          id: tarefaId,
          titulo: titulo,
          descricao: '',
          dataExecucao: novaData,
          status: StatusTarefa.pendente,
          propriedadeId: propriedadeId,
          usuarioId: '',
          horaExecucaoMinutos: horaExecucaoMinutos,
        ),
      );
    }
  }

  Future<void> apagar({
    required String propriedadeId,
    required String tarefaId,
  }) async {
    if (propriedadeId.isEmpty || tarefaId.isEmpty) {
      throw Exception('IDs inválidos.');
    }
    await _repository.apagar(
      propriedadeId: propriedadeId,
      tarefaId: tarefaId,
    );
    await _notifications.cancelarNotificacaoTarefa(tarefaId);
  }

  Future<bool> _notificacoesAtivas() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notificacoes_ativas') ?? true;
  }
}
