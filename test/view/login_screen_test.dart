import 'package:bov_manager/core/widgets/bov_widgets.dart';
import 'package:bov_manager/models/usuario_model.dart';
import 'package:bov_manager/view/login_screen.dart';
import 'package:bov_manager/viewmodels/usuario_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// ── Fake ViewModel ──────────────────────────────────────────────────────────

class FakeUsuarioNotifier extends UsuarioViewModel {
  @override
  AsyncValue<UsuarioModel?> build() => const AsyncData(null);

  @override
  Future<void> login({required String email, required String senha}) async {} // no-op
}

// ── Helper ──────────────────────────────────────────────────────────────────

Widget buildScreen() {
  return ProviderScope(
    overrides: [
      usuarioViewModelProvider.overrideWith(() => FakeUsuarioNotifier()),
    ],
    child: const MaterialApp(home: LoginScreen()),
  );
}

// ── Testes ───────────────────────────────────────────────────────────────────

void main() {
  group('LoginScreen', () {
    // 1. Smoke test
    testWidgets('renderiza sem crashar', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    // 2. Widgets principais
    testWidgets(
        'exibe logo, campos de e-mail e senha, botão entrar e link de cadastro',
        (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      // Logo
      expect(find.byType(BovLogo), findsOneWidget);

      // Títulos
      expect(find.text('Bem-vindo de volta'), findsOneWidget);
      expect(find.text('Entre na sua conta'), findsOneWidget);

      // Campos de texto
      expect(find.byType(BovTextField), findsNWidgets(2));
      expect(find.text('produtor@fazenda.com'), findsOneWidget);
      expect(find.text('Mínimo 8 caracteres'), findsOneWidget);

      // Botão principal
      expect(find.widgetWithText(BovPrimaryButton, 'Entrar'), findsOneWidget);

      // Link de cadastro dentro do RichText
      expect(
        find.byWidgetPredicate(
          (w) => w is RichText && w.text.toPlainText().contains('Cadastrar'),
        ),
        findsOneWidget,
      );
    });

    // 3. Comportamento básico — ícone de visibilidade alterna ao tocar
    testWidgets('alterna visibilidade da senha ao tocar no ícone do campo',
        (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      // Estado inicial: senha oculta
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
      expect(find.byIcon(Icons.visibility_outlined), findsNothing);

      // Toca no ícone para revelar a senha
      await tester.tap(find.byIcon(Icons.visibility_off_outlined));
      await tester.pump();

      // Estado após toque: senha visível
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off_outlined), findsNothing);
    });
  });
}
