import 'package:bov_manager/view/novo_rebanho_screen.dart';
import 'package:bov_manager/viewmodels/rebanho_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// =============================================================================
// FAKE NOTIFIER
// Estende a classe concreta 
// build() retorna imediatamente; criar() é no-op para isolar a UI.
// =============================================================================

class FakeRebanhoViewModel extends RebanhoViewModel {
  @override
  Future<void> build() async {}

  @override
  Future<void> criar({
    required String nome,
    required String pastoId,
    String? propriedadeId,
  }) async {}
}

// =============================================================================
// TESTES
// =============================================================================

void main() {
  group('NovoRebanhoScreen', () {
    // -------------------------------------------------------------------------
    // Helper centralizado.
    // propriedadeId: null  →  _carregarPastos faz early-return sem tocar em
    // pastoServiceProvider, então nenhum override de serviço é necessário.
    // -------------------------------------------------------------------------
    Widget buildScreen({String? propriedadeId}) {
      return ProviderScope(
        overrides: [
          rebanhoViewModelProvider.overrideWith(() => FakeRebanhoViewModel()),
        ],
        child: MaterialApp(
          home: NovoRebanhoScreen(propriedadeId: propriedadeId),
        ),
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
    // Com propriedadeId null, pastos = [] → _InfoBox "Nenhum pasto cadastrado."
    // -------------------------------------------------------------------------
    testWidgets('exibe título, campo de nome, dropdown vazio e botões', (
      tester,
    ) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      // Título da tela
      expect(find.text('Novo Rebanho'), findsOneWidget);

      // Campo de texto para o nome do rebanho
      expect(find.byType(TextField), findsOneWidget);

      // Info box exibida quando não há pastos
      expect(find.text('Nenhum pasto cadastrado.'), findsOneWidget);

      // Botão principal e botão de cancelar
      expect(find.text('Criar Rebanho'), findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // 3. Comportamento básico
    // Pressionar "Criar Rebanho" com nome vazio deve exibir snackbar de erro.
    // -------------------------------------------------------------------------
    testWidgets(
      'exibe snackbar de erro ao tentar criar rebanho com nome vazio',
      (tester) async {
        await tester.pumpWidget(buildScreen());
        await tester.pumpAndSettle();

        // Campo de nome propositalmente vazio — nenhuma interação com TextField

        await tester.tap(find.text('Criar Rebanho'));
        await tester.pump(); // um frame é suficiente para o SnackBar aparecer

        expect(find.text('Informe o nome do lote.'), findsOneWidget);
      },
    );
  });
}
