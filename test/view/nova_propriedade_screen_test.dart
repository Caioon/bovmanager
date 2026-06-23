import 'package:bov_manager/view/nova_propriedade_screen.dart';
import 'package:bov_manager/viewmodels/propriedade_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Fake Notifier
// ---------------------------------------------------------------------------

class FakePropriedadesViewModel extends PropriedadesViewModel {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  @override
  Future<void> criar({required String nome}) async {}
}

// ---------------------------------------------------------------------------
// Helper
// ---------------------------------------------------------------------------

Widget buildScreen() {
  return ProviderScope(
    overrides: [
      propriedadesViewModelProvider.overrideWith(
        () => FakePropriedadesViewModel(),
      ),
    ],
    child: const MaterialApp(home: NovaPropriedadeScreen()),
  );
}

// ---------------------------------------------------------------------------
// Testes
// ---------------------------------------------------------------------------

void main() {
  group('NovaPropriedadeScreen', () {
    testWidgets('1. Smoke test — tela renderiza sem crashar', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(NovaPropriedadeScreen), findsOneWidget);
    });

    testWidgets(
      '2. Widgets principais — título, campo de nome e botões estão presentes',
      (tester) async {
        await tester.pumpWidget(buildScreen());
        await tester.pumpAndSettle();

        // Título da tela
        expect(find.text('Nova Propriedade'), findsOneWidget);

        // Campo de texto para o nome da fazenda
        expect(find.byType(TextField), findsOneWidget);

        // Botão primário de ação
        expect(find.text('Salvar Propriedade'), findsOneWidget);

        // Botão secundário de cancelamento
        expect(find.text('Cancelar'), findsOneWidget);
      },
    );

    testWidgets(
      '3. Comportamento básico — campo aceita input e botão salvar permanece habilitado',
      (tester) async {
        await tester.pumpWidget(buildScreen());
        await tester.pumpAndSettle();

        // Digita um nome no campo
        await tester.enterText(
          find.byType(TextField),
          'Fazenda Santa Clara',
        );
        await tester.pump();

        // O texto digitado é refletido no campo
        expect(find.text('Fazenda Santa Clara'), findsOneWidget);

        // O botão "Salvar Propriedade" continua visível e acionável
        // (a tela não desabilita o botão com base no conteúdo do campo)
        expect(find.text('Salvar Propriedade'), findsOneWidget);

        // Tap no botão não lança exceção
        await tester.tap(find.text('Salvar Propriedade'));
        await tester.pump();
      },
    );
  });
}
