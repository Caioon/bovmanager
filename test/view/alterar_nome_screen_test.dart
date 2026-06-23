import 'package:bov_manager/models/usuario_model.dart';
import 'package:bov_manager/view/alterar_nome_screen.dart';
import 'package:bov_manager/viewmodels/usuario_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeUsuarioNotifier extends UsuarioViewModel {
  @override
  AsyncValue<UsuarioModel?> build() => const AsyncData(null);

  @override
  Future<void> atualizarNome(String nome) async {}
}

void main() {
  group('AlterarNomeScreen', () {
    Widget buildScreen({String nomeAtual = 'João da Silva'}) {
      return ProviderScope(
        overrides: [
          usuarioViewModelProvider.overrideWith(() => FakeUsuarioNotifier()),
        ],
        child: MaterialApp(home: AlterarNomeScreen(nomeAtual: nomeAtual)),
      );
    }

    testWidgets('Smoke test - renderiza sem crashar', (tester) async {
      await tester.pumpWidget(buildScreen());

      expect(find.byType(AlterarNomeScreen), findsOneWidget);
    });

    testWidgets(
      'Widgets principais - exibe título, campo de nome e botão salvar',
      (tester) async {
        await tester.pumpWidget(buildScreen());

        expect(find.text('Alterar Nome'), findsOneWidget);

        expect(find.byType(TextField), findsOneWidget);
        expect(find.text('Nome'), findsOneWidget);

        expect(find.text('Salvar'), findsOneWidget);

        expect(find.text('João da Silva'), findsOneWidget);
      },
    );

    testWidgets(
      'Comportamento básico - campo inicia preenchido com o nome atual',
      (tester) async {
        await tester.pumpWidget(buildScreen(nomeAtual: 'Maria Oliveira'));

        final textField = tester.widget<TextField>(find.byType(TextField));

        expect(textField.controller?.text, 'Maria Oliveira');

        await tester.enterText(find.byType(TextField), 'Maria Souza');

        expect(find.text('Maria Souza'), findsOneWidget);
      },
    );
  });
}
