import 'package:bov_manager/models/usuario_model.dart';
import 'package:bov_manager/view/alterar_senha_screen.dart';
import 'package:bov_manager/viewmodels/usuario_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeUsuarioNotifier extends UsuarioViewModel {
  @override
  AsyncValue<UsuarioModel?> build() => const AsyncData(null);

  @override
  Future<void> atualizarSenha(String senhaAtual, String novaSenha) async {}
}

void main() {
  group('AlterarSenhaScreen', () {
    Widget buildScreen({String senhaAtual = 'senha_atual'}) {
      return ProviderScope(
        overrides: [
          usuarioViewModelProvider.overrideWith(() => FakeUsuarioNotifier()),
        ],
        child: MaterialApp(home: AlterarSenhaScreen(senhaAtual: senhaAtual)),
      );
    }

    testWidgets('Smoke test - renderiza sem crashar', (tester) async {
      await tester.pumpWidget(buildScreen());

      expect(find.byType(AlterarSenhaScreen), findsOneWidget);
    });

    testWidgets('Widgets principais - exibe título, campos e botão salvar', (
      tester,
    ) async {
      await tester.pumpWidget(buildScreen());

      expect(find.text('Alterar Senha'), findsOneWidget);

      expect(find.text('Mínimo 6 caracteres'), findsOneWidget);
      expect(find.text('Repita a nova senha'), findsOneWidget);

      expect(find.byType(TextField), findsNWidgets(2));

      expect(find.text('Salvar'), findsOneWidget);

      expect(find.byIcon(Icons.visibility_off_outlined), findsNWidgets(2));
    });

    testWidgets(
      'Comportamento básico - exibe erro e mantém botão desabilitado com senha inválida',
      (tester) async {
        await tester.pumpWidget(buildScreen());

        final textFields = find.byType(TextField);

        await tester.enterText(textFields.at(0), '123');
        await tester.pump();

        expect(
          find.text('A senha deve ter pelo menos 6 caracteres'),
          findsOneWidget,
        );

        final elevatedButton = tester.widget<ElevatedButton>(
          find.byType(ElevatedButton),
        );

        expect(elevatedButton.onPressed, isNull);

        await tester.enterText(textFields.at(1), '123');
        await tester.pump();

        expect(elevatedButton.onPressed, isNull);
      },
    );
  });
}
