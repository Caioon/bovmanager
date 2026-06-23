import 'package:bov_manager/models/usuario_model.dart';
import 'package:bov_manager/repositories/usuario_repository.dart';
import 'package:bov_manager/services/notification_service.dart';
import 'package:bov_manager/view/perfil_screen.dart';
import 'package:bov_manager/viewmodels/usuario_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/timezone.dart' as tz;

// =============================================================================
// FAKE NOTIFIER
// Estende a classe concreta; build() é síncrono (AsyncData(null)) e
// logout() é no-op para isolar a UI de qualquer dependência real.
// =============================================================================

class FakeUsuarioViewModel extends UsuarioViewModel {
  @override
  AsyncValue<UsuarioModel?> build() => const AsyncData(null);

  @override
  Future<void> logout() async {}
}

// =============================================================================
// FAKE NOTIFICATION PLUGIN
// Implementa a interface pública NotificationPluginAdapter com no-ops,
// permitindo instanciar NotificationService sem plugin nativo.
// =============================================================================

class _FakeNotificationPlugin implements NotificationPluginAdapter {
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
  Future<List<PendingNotificationRequest>> pendingNotificationRequests() async => [];

  @override
  Future<void> show({
    required int id,
    String? title,
    String? body,
    NotificationDetails? notificationDetails,
    String? payload,
  }) async {}

  @override
  AndroidFlutterLocalNotificationsPlugin? get androidPlugin => null;
}

// =============================================================================
// TESTES
// =============================================================================

void main() {
  // Usuário fake — ajuste os campos se UsuarioModel tiver parâmetros diferentes.
  final fakeUser = UsuarioModel(
    id: 'fake-id',
    nome: 'Fazendeiro Teste',
    email: 'teste@bov.com',
    cpf: '000.000.000-00',
  );

  group('PerfilScreen', () {
    // -------------------------------------------------------------------------
    // Helper centralizado.
    // comUsuario: true  → usuarioAtualProvider emite o fakeUser.
    // comUsuario: false → emite null  →  tela mostra CircularProgressIndicator.
    // -------------------------------------------------------------------------
    Widget buildScreen({bool comUsuario = true}) {
      return ProviderScope(
        overrides: [
          usuarioViewModelProvider.overrideWith(() => FakeUsuarioViewModel()),
          usuarioAtualProvider.overrideWith(
            (ref) =>
                comUsuario ? Stream.value(fakeUser) : Stream.value(null),
          ),
          notificationServiceProvider.overrideWith(
            (ref) => NotificationService(_FakeNotificationPlugin()),
          ),
        ],
        child: const MaterialApp(home: PerfilScreen()),
      );
    }

    // -------------------------------------------------------------------------
    // 1. Smoke test
    // -------------------------------------------------------------------------
    testWidgets('renderiza sem crashar', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();
    });

    // -------------------------------------------------------------------------
    // 2. Widgets principais
    // -------------------------------------------------------------------------
    testWidgets('exibe saudação ao usuário, subtítulo e botão de logout', (
      tester,
    ) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      // Subtítulo de conexão (Text simples — fácil de localizar)
      expect(
        find.text('Você está conectado ao BovManager.'),
        findsOneWidget,
      );

      // Botão principal de ação destrutiva
      expect(find.text('Sair da conta'), findsOneWidget);

      // Ao menos um botão de navegação secundário
      expect(find.text('Ver Dados'), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // 3. Comportamento básico
    // Quando o usuário ainda não foi carregado (null), a tela exibe apenas
    // um indicador de progresso — sem renderizar o conteúdo do perfil.
    // -------------------------------------------------------------------------
    testWidgets(
      'exibe CircularProgressIndicator enquanto usuário é nulo',
      (tester) async {
        await tester.pumpWidget(buildScreen(comUsuario: false));
        await tester.pump(); // pumpAndSettle não funciona com CircularProgressIndicator (animação infinita)

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Sair da conta'), findsNothing);
      },
    );
  });
}
