import 'package:bov_manager/models/tarefa_model.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

part 'notification_service.g.dart';

@riverpod
NotificationService notificationService(Ref ref) {
  return NotificationService();
}

// =============================================================================
// ADAPTER — isola FlutterLocalNotificationsPlugin (factory constructor,
// não pode ser subclassado) para permitir injeção de dependência nos testes.
// =============================================================================

/// Interface mínima sobre FlutterLocalNotificationsPlugin.
/// Implemente [FakeNotificationPlugin] nos testes; use [RealNotificationPlugin]
/// em produção (criado automaticamente quando nenhum plugin é injetado).
abstract class NotificationPluginAdapter {
  Future<bool?> initialize({
    required InitializationSettings settings,
    DidReceiveNotificationResponseCallback? onDidReceiveNotificationResponse,
    DidReceiveBackgroundNotificationResponseCallback?
    onDidReceiveBackgroundNotificationResponse,
  });

  Future<void> zonedSchedule({
    required int id,
    String? title,
    String? body,
    required tz.TZDateTime scheduledDate,
    required NotificationDetails notificationDetails,
    required AndroidScheduleMode androidScheduleMode,
    String? payload,
    DateTimeComponents? matchDateTimeComponents,
  });

  Future<void> cancel({required int id, String? tag});

  Future<void> cancelAll();

  Future<List<PendingNotificationRequest>> pendingNotificationRequests();

  Future<void> show({
    required int id,
    String? title,
    String? body,
    NotificationDetails? notificationDetails,
    String? payload,
  });

  /// Permite acesso à API Android (canal, permissão, alarmes exatos).
  /// Retorna null em plataformas não-Android e em fakes de teste.
  AndroidFlutterLocalNotificationsPlugin? get androidPlugin;
}

/// Implementação de produção — delega para FlutterLocalNotificationsPlugin.
class RealNotificationPlugin implements NotificationPluginAdapter {
  final _plugin = FlutterLocalNotificationsPlugin();

  @override
  Future<bool?> initialize({
    required InitializationSettings settings,
    DidReceiveNotificationResponseCallback? onDidReceiveNotificationResponse,
    DidReceiveBackgroundNotificationResponseCallback?
    onDidReceiveBackgroundNotificationResponse,
  }) =>
      _plugin.initialize(
        settings: settings,
        onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
        onDidReceiveBackgroundNotificationResponse:
        onDidReceiveBackgroundNotificationResponse,
      );

  @override
  Future<void> zonedSchedule({
    required int id,
    String? title,
    String? body,
    required tz.TZDateTime scheduledDate,
    required NotificationDetails notificationDetails,
    required AndroidScheduleMode androidScheduleMode,
    String? payload,
    DateTimeComponents? matchDateTimeComponents,
  }) =>
      _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: notificationDetails,
        androidScheduleMode: androidScheduleMode,
        payload: payload,
        matchDateTimeComponents: matchDateTimeComponents,
      );

  @override
  Future<void> cancel({required int id, String? tag}) =>
      _plugin.cancel(id: id, tag: tag);

  @override
  Future<void> cancelAll() => _plugin.cancelAll();

  @override
  Future<List<PendingNotificationRequest>> pendingNotificationRequests() =>
      _plugin.pendingNotificationRequests();

  @override
  Future<void> show({
    required int id,
    String? title,
    String? body,
    NotificationDetails? notificationDetails,
    String? payload,
  }) =>
      _plugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: notificationDetails,
        payload: payload,
      );

  @override
  AndroidFlutterLocalNotificationsPlugin? get androidPlugin =>
      _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
}

// =============================================================================
// SERVIÇO
// =============================================================================

class NotificationService {
  NotificationService([NotificationPluginAdapter? plugin])
      : _plugin = plugin ?? RealNotificationPlugin();

  final NotificationPluginAdapter _plugin;

  bool _initialized = false;

  static const _channelId = 'bov_tarefas';
  static const _channelName = 'Tarefas';
  static const _channelDesc = 'Lembretes de tarefas do BovManager';

  // Cada tarefa ocupa 6 slots de ID: base a base+5.
  // ATENÇÃO: ao mudar _totalSlots de 3 para 6, todos os IDs do sistema Android
  // mudam. Execute cancelAll() antes de publicar e reagende em seguida.
  static const _totalSlots = 6;

  // ---------------------------------------------------------------------------
  // Chaves de preferência de slot (SharedPreferences)
  // ---------------------------------------------------------------------------

  // Tarefas sem horário definido (4 slots ativos: 0–3)
  static const kSemHorario24h = 'notif_semhorario_24h'; // slot 0
  static const kSemHorario8h = 'notif_semhorario_8h'; // slot 1
  static const kSemHorario12h = 'notif_semhorario_12h'; // slot 2
  static const kSemHorario16h = 'notif_semhorario_16h'; // slot 3

  // Tarefas com horário definido (6 slots ativos: 0–5)
  static const kComHorario24h = 'notif_comhorario_24h'; // slot 0
  static const kComHorario12h = 'notif_comhorario_12h'; // slot 1
  static const kComHorario6h = 'notif_comhorario_6h'; // slot 2
  static const kComHorario1h = 'notif_comhorario_1h'; // slot 3
  static const kComHorario15min = 'notif_comhorario_15min'; // slot 4
  static const kComHorarioImediata = 'notif_comhorario_imediata'; // slot 5

  /// Todas as chaves de slot, na ordem usada pela UI de preferências.
  static const todosOsSlots = [
    kSemHorario24h,
    kSemHorario8h,
    kSemHorario12h,
    kSemHorario16h,
    kComHorario24h,
    kComHorario12h,
    kComHorario6h,
    kComHorario1h,
    kComHorario15min,
    kComHorarioImediata,
  ];

  // ===========================================================================
  // INICIALIZAÇÃO
  // ===========================================================================

  Future<void> init() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings: initSettings);

    // Cria o canal de notificação explicitamente no Android.
    // Sem isso, notificações agendadas via zonedSchedule não aparecem
    // mesmo com permissões concedidas.
    await _plugin.androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDesc,
        importance: Importance.high,
      ),
    );

    // Solicita permissão explícita no Android 13+
    await _plugin.androidPlugin?.requestNotificationsPermission();

    _initialized = true;
  }

  // ===========================================================================
  // AGENDAR
  // ===========================================================================

  /// Agenda até 6 notificações para a tarefa, respeitando preferências de slot.
  ///
  /// Sem horário → 4 slots (0–3): 24h antes (8h do dia anterior), 8h, 12h e
  ///               16h do dia da tarefa. Slots 4 e 5 ficam vazios.
  /// Com horário → 6 slots (0–5): 24h, 12h, 6h, 1h e 15min antes, e no
  ///               momento exato da execução.
  ///
  /// Slots no passado e slots com preferência desativada são ignorados.
  /// A verificação do toggle geral (notificacoes_ativas) fica a cargo do
  /// TarefaService — aqui só se verifica a preferência individual do slot.
  Future<void> agendarNotificacaoTarefa(TarefaModel tarefa) async {
    await init();

    final agendamentos = _calcularAgendamentos(tarefa);
    final baseId = calcularBaseId(tarefa.id);
    final prefs = await SharedPreferences.getInstance();

    for (var i = 0; i < agendamentos.length; i++) {
      final agendamento = agendamentos[i];
      if (agendamento.horario.isBefore(DateTime.now())) continue;
      if (!(prefs.getBool(agendamento.prefKey) ?? true)) continue;

      await _agendar(
        id: baseId + i,
        titulo: agendamento.titulo,
        corpo: tarefa.titulo,
        horario: agendamento.horario,
      );
    }
  }

  // ===========================================================================
  // CANCELAR
  // ===========================================================================

  /// Cancela os 6 slots da tarefa, independente de quais estavam agendados.
  Future<void> cancelarNotificacaoTarefa(String tarefaId) async {
    await init();
    final baseId = calcularBaseId(tarefaId);
    for (var i = 0; i < _totalSlots; i++) {
      await _plugin.cancel(id: baseId + i);
    }
  }

  Future<void> cancelarTodasNotificacoes() async {
    await init();
    await _plugin.cancelAll();
  }

  // ===========================================================================
  // REAGENDAR TODAS (usado ao religar as notificações)
  // ===========================================================================

  Future<void> reagendarTodas(List<TarefaModel> tarefasPendentes) async {
    await cancelarTodasNotificacoes();
    for (final tarefa in tarefasPendentes) {
      if (tarefa.status == StatusTarefa.pendente) {
        await agendarNotificacaoTarefa(tarefa);
      }
    }
  }

  // ===========================================================================
  // SINCRONIZAÇÃO DE NOTIFICAÇÕES (usado pelo AppShell ao abrir o app / logar)
  // ===========================================================================

  /// Retorna o conjunto de IDs de notificações atualmente pendentes no
  /// AlarmManager. Usado pelo AppShell para verificar quais tarefas já têm
  /// notificações agendadas antes de reagendar.
  Future<Set<int>> buscarIdsPendentes() async {
    await init();
    final requests = await _plugin.pendingNotificationRequests();
    return requests.map((r) => r.id).toSet();
  }

  /// Calcula o ID base para os 6 slots de uma tarefa.
  ///
  /// Exposto como público para que o AppShell possa verificar, sem duplicar
  /// a lógica, se algum slot de uma tarefa já está no AlarmManager.
  ///
  /// Fórmula: (tarefaId.hashCode.abs() % 100000) * _totalSlots
  /// Range: 0 – 599994 (com _totalSlots = 6)
  int calcularBaseId(String tarefaId) =>
      (tarefaId.hashCode.abs() % 100000) * _totalSlots;

  // ===========================================================================
  // HELPERS PRIVADOS
  // ===========================================================================

  Future<void> _agendar({
    required int id,
    required String titulo,
    required String corpo,
    required DateTime horario,
  }) async {
    // androidPlugin?.canScheduleExactNotifications() é null em fakes e em
    // plataformas não-Android → ?? false garante o modo inexato nesses casos.
    final canExact =
        await _plugin.androidPlugin?.canScheduleExactNotifications() ?? false;

    await _plugin.zonedSchedule(
      id: id,
      title: titulo,
      body: corpo,
      scheduledDate: tz.TZDateTime.from(horario, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      androidScheduleMode: canExact
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  List<_Agendamento> _calcularAgendamentos(TarefaModel tarefa) {
    final dataHora = tarefa.dataHoraExecucao;

    if (dataHora == null) {
      // Sem horário → 4 lembretes fixos (slots 0–3); slots 4 e 5 não são usados.
      final dia = tarefa.dataExecucao;
      final diaPrevio = dia.subtract(const Duration(days: 1));
      return [
        _Agendamento(
          horario: DateTime(
            diaPrevio.year,
            diaPrevio.month,
            diaPrevio.day,
            8,
            0,
          ),
          titulo: 'Amanhã',
          prefKey: kSemHorario24h,
        ),
        _Agendamento(
          horario: DateTime(dia.year, dia.month, dia.day, 8, 0),
          titulo: 'Tarefa para hoje',
          prefKey: kSemHorario8h,
        ),
        _Agendamento(
          horario: DateTime(dia.year, dia.month, dia.day, 12, 0),
          titulo: 'Tarefa para hoje',
          prefKey: kSemHorario12h,
        ),
        _Agendamento(
          horario: DateTime(dia.year, dia.month, dia.day, 16, 0),
          titulo: 'Tarefa para hoje',
          prefKey: kSemHorario16h,
        ),
      ];
    } else {
      // Com horário → 6 lembretes relativos à hora de execução (slots 0–5).
      // O lembrete de 24h pode cair no dia anterior — isso é intencional.
      return [
        _Agendamento(
          horario: dataHora.subtract(const Duration(hours: 24)),
          titulo: 'Tarefa para amanhã',
          prefKey: kComHorario24h,
        ),
        _Agendamento(
          horario: dataHora.subtract(const Duration(hours: 12)),
          titulo: 'Tarefa em 12 horas',
          prefKey: kComHorario12h,
        ),
        _Agendamento(
          horario: dataHora.subtract(const Duration(hours: 6)),
          titulo: 'Tarefa em 6 horas',
          prefKey: kComHorario6h,
        ),
        _Agendamento(
          horario: dataHora.subtract(const Duration(hours: 1)),
          titulo: 'Tarefa em 1 hora',
          prefKey: kComHorario1h,
        ),
        _Agendamento(
          horario: dataHora.subtract(const Duration(minutes: 15)),
          titulo: 'Tarefa em 15 minutos',
          prefKey: kComHorario15min,
        ),
        _Agendamento(
          horario: dataHora,
          titulo: 'Tarefa para agora',
          prefKey: kComHorarioImediata,
        ),
      ];
    }
  }

  // ===========================================================================
  // MÉTODOS DE TESTE
  // ===========================================================================

  /// Dispara uma notificação de teste em 5 segundos.
  /// Usa o mesmo caminho de código das notificações reais.
  Future<void> dispararNotificacaoTeste() async {
    await init();
    await _agendar(
      id: 999999,
      titulo: 'Notificação de teste agendada',
      corpo: 'As notificações do BovManager estão funcionando!',
      horario: DateTime.now().add(const Duration(seconds: 5)),
    );
  }

  Future<void> mostrarNotificacaoAgora() async {
    await init();
    await _plugin.show(
      id: 123456,
      title: 'Notificação de teste imediato',
      body: 'As notificações do BovManager estão funcionando!',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }
}

class _Agendamento {
  const _Agendamento({
    required this.horario,
    required this.titulo,
    required this.prefKey,
  });

  final DateTime horario;
  final String titulo;

  /// Chave SharedPreferences que controla se este slot está habilitado.
  final String prefKey;
}
