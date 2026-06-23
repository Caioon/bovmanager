import 'package:bov_manager/core/widgets/bov_widgets.dart';
import 'package:bov_manager/models/usuario_model.dart';
import 'package:bov_manager/repositories/usuario_repository.dart';
import 'package:bov_manager/view/home_screen.dart';
import 'package:bov_manager/viewmodels/usuario_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// ── Fake ViewModel (padrão Riverpod 3.0 — estende classe concreta) ─────────

class FakeUsuarioNotifier extends UsuarioViewModel {
  @override
  AsyncValue<UsuarioModel?> build() => const AsyncData(null);

  @override
  Future<void> logout() async {} // no-op
}

// ── Usuário de teste ────────────────────────────────────────────────────────

final fakeUsuario = UsuarioModel(
  id: 'fake-id',
  nome: 'João',
  email: 'joao@email.com',
  cpf: '000.000.000-00',
);

// ── Helper ─────────────────────────────────────────────────────────────────

Widget buildScreen({UsuarioModel? usuario}) {
  return ProviderScope(
    overrides: [
      usuarioViewModelProvider.overrideWith(() => FakeUsuarioNotifier()),
      usuarioAtualProvider.overrideWith((ref) => Stream.value(usuario)),
    ],
    child: const MaterialApp(home: HomeScreen()),
  );
}

// ── Testes ─────────────────────────────────────────────────────────────────

void main() {
  group('HomeScreen', () {
    // 1. Smoke test
    testWidgets('renderiza sem crashar quando usuário está carregado', (
      tester,
    ) async {
      await tester.pumpWidget(buildScreen(usuario: fakeUsuario));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    // 2. Widgets principais
    testWidgets('exibe logo, saudação com nome do usuário e botão de logout', (
      tester,
    ) async {
      await tester.pumpWidget(buildScreen(usuario: fakeUsuario));
      await tester.pumpAndSettle();

      // Logo
      expect(find.byType(BovLogo), findsOneWidget);

      // Texto de boas-vindas com o nome
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is RichText &&
              widget.text.toPlainText().contains('Bem-vindo,'),
        ),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is RichText && widget.text.toPlainText().contains('João!'),
        ),
        findsOneWidget,
      );
      // Subtítulo
      expect(find.text('Você está conectado ao BovManager.'), findsOneWidget);

      // Botão de logout
      expect(find.byType(BovDangerButton), findsOneWidget);
      expect(find.text('Sair da conta'), findsOneWidget);
    });

    // 3. Comportamento básico — exibe loading quando usuário é null
    testWidgets(
      'exibe CircularProgressIndicator enquanto usuário não está disponível',
      (tester) async {
        await tester.pumpWidget(buildScreen(usuario: null));
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.byType(BovDangerButton), findsNothing);
      },
    );
  });
}
