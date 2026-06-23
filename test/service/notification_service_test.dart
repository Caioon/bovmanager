import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bov_manager/models/tarefa_model.dart';
import 'package:bov_manager/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Fake que implementa [NotificationPluginAdapter] diretamente.
/// Não subclassifica FlutterLocalNotificationsPlugin (factory constructor),
/// e não depende de canais de plataforma — todos os métodos são no-op.
class FakeNotificationPlugin implements NotificationPluginAdapter {
  @override
  Future<bool?> initialize({
    required InitializationSettings settings,
    DidReceiveNotificationResponseCallback? onDidReceiveNotificationResponse,
    DidReceiveBackgroundNotificationResponseCallback?
    onDidReceiveBackgroundNotificationResponse,
  }) async => true;

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
  }) async {}

  @override
  Future<void> cancel({required int id, String? tag}) async {}

  @override
  Future<void> cancelAll() async {}

  @override
  Future<List<PendingNotificationRequest>>
  pendingNotificationRequests() async => [];

  @override
  Future<void> show({
    required int id,
    String? title,
    String? body,
    NotificationDetails? notificationDetails,
    String? payload,
  }) async {}

  /// Retorna null — NotificationService trata isso com ?. em todos os usos.
  @override
  AndroidFlutterLocalNotificationsPlugin? get androidPlugin => null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Sao_Paulo'));
  });

  group('NotificationService', () {
    late NotificationService service;

    setUp(() async {
      SharedPreferences.setMockInitialValues({
        'notificacoes_ativas': true,
        NotificationService.kSemHorario24h: true,
        NotificationService.kSemHorario8h: true,
        NotificationService.kSemHorario12h: true,
        NotificationService.kSemHorario16h: true,
        NotificationService.kComHorario24h: true,
        NotificationService.kComHorario12h: true,
        NotificationService.kComHorario6h: true,
        NotificationService.kComHorario1h: true,
        NotificationService.kComHorario15min: true,
        NotificationService.kComHorarioImediata: true,
      });

      service = NotificationService(FakeNotificationPlugin());
    });

    test('calcularBaseId() deve gerar ID base consistente', () {
      final id1 = service.calcularBaseId('tarefa123');
      final id2 = service.calcularBaseId('tarefa123');

      expect(id1, id2);
      expect(id1 % 6, 0);
    });

    test(
      'calcularBaseId() deve gerar IDs diferentes para tarefas diferentes',
      () {
        final id1 = service.calcularBaseId('tarefa123');
        final id2 = service.calcularBaseId('tarefa456');

        expect(id1, isNot(id2));
      },
    );

    test('todosOsSlots deve conter todas as preferências de notificação', () {
      expect(NotificationService.todosOsSlots.length, 10);

      expect(
        NotificationService.todosOsSlots,
        contains(NotificationService.kSemHorario24h),
      );

      expect(
        NotificationService.todosOsSlots,
        contains(NotificationService.kComHorarioImediata),
      );
    });

    test('cancelarTodasNotificacoes() deve executar sem erro', () async {
      await expectLater(service.cancelarTodasNotificacoes(), completes);
    });

    test('cancelarNotificacaoTarefa() deve executar sem erro', () async {
      await expectLater(
        service.cancelarNotificacaoTarefa('tarefa123'),
        completes,
      );
    });

    test('reagendarTodas() deve executar com lista vazia', () async {
      await expectLater(service.reagendarTodas([]), completes);
    });

    test('buscarIdsPendentes() deve retornar conjunto de IDs', () async {
      final result = await service.buscarIdsPendentes();

      expect(result, isA<Set<int>>());
    });

    test(
      'agendarNotificacaoTarefa() deve aceitar tarefa sem horário',
      () async {
        final tarefa = TarefaModel(
          id: 'tarefa123',
          titulo: 'Vacinar animais',
          descricao: 'Aplicar vacina',
          dataExecucao: DateTime.now().add(const Duration(days: 2)),
          status: StatusTarefa.pendente,
          propriedadeId: 'propriedade123',
          usuarioId: 'usuario123',
          horaExecucaoMinutos: null,
        );

        await expectLater(service.agendarNotificacaoTarefa(tarefa), completes);
      },
    );

    test(
      'agendarNotificacaoTarefa() deve aceitar tarefa com horário',
      () async {
        final tarefa = TarefaModel(
          id: 'tarefa123',
          titulo: 'Pesagem',
          descricao: 'Realizar pesagem',
          dataExecucao: DateTime.now().add(const Duration(days: 2)),
          status: StatusTarefa.pendente,
          propriedadeId: 'propriedade123',
          usuarioId: 'usuario123',
          horaExecucaoMinutos: 8 * 60,
        );

        await expectLater(service.agendarNotificacaoTarefa(tarefa), completes);
      },
    );

    test('dispararNotificacaoTeste() deve executar sem erro', () async {
      await expectLater(service.dispararNotificacaoTeste(), completes);
    });

    test('mostrarNotificacaoAgora() deve executar sem erro', () async {
      await expectLater(service.mostrarNotificacaoAgora(), completes);
    });
  });
}
