import 'package:bov_manager/models/usuario_model.dart';
import 'package:bov_manager/view/alterar_email_screen.dart';
import 'package:bov_manager/viewmodels/usuario_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeUsuarioNotifier extends UsuarioViewModel {
  @override
  AsyncValue<UsuarioModel?> build() => const AsyncData(null);

  @override
  Future<void> atualizarEmail(String senhaAtual, String novoEmail) async {}
}

void main() {
  group('AlterarEmailScreen', () {
    Widget buildScreen({
      String emailAtual = 'teste@email.com',
      String senhaAtual = '123456',
    }) {
      return ProviderScope(
        overrides: [
          usuarioViewModelProvider.overrideWith(() => FakeUsuarioNotifier()),
        ],
        child: MaterialApp(
          home: AlterarEmailScreen(
            emailAtual: emailAtual,
            senhaAtual: senhaAtual,
          ),
        ),
      );
    }

    testWidgets('Smoke test - renderiza sem crashar', (tester) async {
      await tester.pumpWidget(buildScreen());

      expect(find.byType(AlterarEmailScreen), findsOneWidget);
    });

    testWidgets('Widgets principais - exibe título, campo e botão principal', (
      tester,
    ) async {
      await tester.pumpWidget(buildScreen());

      expect(find.text('Alterar Email'), findsOneWidget);
      expect(find.text('Email atual'), findsOneWidget);
      expect(find.text('teste@email.com'), findsOneWidget);

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Novo email'), findsOneWidget);

      expect(find.text('Enviar confirmação'), findsOneWidget);

      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets(
      'Comportamento básico - botão permanece habilitado com campo vazio',
      (tester) async {
        await tester.pumpWidget(buildScreen());

        final elevatedButton = tester.widget<ElevatedButton>(
          find.byType(ElevatedButton),
        );

        expect(elevatedButton.onPressed, isNotNull);

        await tester.tap(find.text('Enviar confirmação'));
        await tester.pump();

        expect(find.byType(TextField), findsOneWidget);
        expect(find.text('Enviar confirmação'), findsOneWidget);
      },
    );
  });
}
