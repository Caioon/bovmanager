import 'package:bov_manager/models/tarefa_model.dart';
import 'package:bov_manager/services/notification_service.dart';
import 'package:bov_manager/viewmodels/tarefa_viewmodel.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'notificacao_viewmodel.g.dart';

const _kNotificacoesAtivas = 'notificacoes_ativas';

// =============================================================================
// TOGGLE GERAL (ligado / desligado)
// =============================================================================

@riverpod
class NotificacaoViewModel extends _$NotificacaoViewModel {
  @override
  Future<bool> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kNotificacoesAtivas) ?? true;
  }

  Future<void> alternar() async {
    final ativo = state.asData?.value ?? true;
    final novoValor = !ativo;

    state = const AsyncLoading();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kNotificacoesAtivas, novoValor);

      final service = ref.read(notificationServiceProvider);

      if (!novoValor) {
        // Desligou → cancela tudo
        await service.cancelarTodasNotificacoes();
      } else {
        // Ligou → reagenda todas as tarefas pendentes
        final tarefas = ref.read(tarefasListaProvider).asData?.value ?? [];
        final pendentes = tarefas
            .where((t) => t.status == StatusTarefa.pendente)
            .toList();
        await service.reagendarTodas(pendentes);
      }

      state = AsyncData(novoValor);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

// =============================================================================
// PREFERÊNCIAS POR SLOT
// =============================================================================

/// Gerencia as preferências individuais de cada slot de notificação,
/// persistidas via SharedPreferences.
///
/// O estado é um [Map<String, bool>] indexado pelas constantes estáticas de
/// [NotificationService] (ex: [NotificationService.kSemHorario24h]).
///
/// Alterar um slot **não** cancela nem reagenda notificações existentes —
/// a preferência só tem efeito na próxima chamada a
/// [NotificationService.agendarNotificacaoTarefa]. Para aplicar imediatamente,
/// use [NotificacaoViewModel.alternar] (desliga e religa o toggle geral).
@riverpod
class NotificacaoSlotsViewModel extends _$NotificacaoSlotsViewModel {
  @override
  Future<Map<String, bool>> build() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      for (final chave in NotificationService.todosOsSlots)
        chave: prefs.getBool(chave) ?? true,
    };
  }

  /// Inverte o valor do [slot] especificado e persiste a preferência.
  Future<void> alternarSlot(String slot) async {
    final mapa = Map<String, bool>.from(state.asData?.value ?? {});
    final novoValor = !(mapa[slot] ?? true);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(slot, novoValor);

    mapa[slot] = novoValor;
    state = AsyncData(mapa);
  }
}
