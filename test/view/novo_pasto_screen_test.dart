import 'package:bov_manager/view/novo_pasto_screen.dart';
import 'package:bov_manager/viewmodels/pasto_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Fake Notifier 
// ---------------------------------------------------------------------------
class FakePastosNotifier extends PastosViewModel {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  @override
  Future<void> criar({
    required String nome,
    required double area,
    String? descricao,
    int? limiteAnimais,
    String? propriedadeIdOverride,
  }) async {}
}

// ---------------------------------------------------------------------------
// Helper
// ---------------------------------------------------------------------------
Widget buildScreen({String? propriedadeId}) {
  return ProviderScope(
    overrides: [
      pastosViewModelProvider.overrideWith(() => FakePastosNotifier()),
    ],
    child: MaterialApp(
      home: NovoPastoScreen(propriedadeId: propriedadeId),
    ),
  );
}

// ---------------------------------------------------------------------------
// Testes
// ---------------------------------------------------------------------------
void main() {
  group('NovoPastoScreen', () {
    // 1. Smoke test
    testWidgets('renderiza sem crashar', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(NovoPastoScreen), findsOneWidget);
    });

    // 2. Widgets principais
    testWidgets('exibe título, campos obrigatórios e botões de ação',
        (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      // Título
      expect(find.text('Novo Pasto'), findsOneWidget);

      // Campos de texto (hint texts visíveis com controllers vazios)
      expect(find.text('Ex: Pasto Norte A'), findsOneWidget);
      expect(find.text('0.00'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
      expect(find.text('Observações sobre o pasto...'), findsOneWidget);

      // Botões
      expect(find.text('Salvar Pasto'), findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);
    });

    // 3. Comportamento básico — SnackBar de erro ao salvar com campos vazios
    testWidgets(
        'exibe snackbar de erro ao tentar salvar com campos obrigatórios vazios',
        (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      // Campos vazios — toca direto no botão salvar
      await tester.tap(find.text('Salvar Pasto'));
      await tester.pumpAndSettle();

      expect(
        find.text('Preencha todos os campos obrigatórios.'),
        findsOneWidget,
      );
    });
  });
}
