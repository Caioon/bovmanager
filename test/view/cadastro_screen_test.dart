import 'package:bov_manager/models/usuario_model.dart';
import 'package:bov_manager/view/cadastro_screen.dart';
import 'package:bov_manager/viewmodels/usuario_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeUsuarioNotifier extends UsuarioViewModel {
  @override
  AsyncValue<UsuarioModel?> build() => const AsyncData(null);

  @override
  Future<void> criarUsuario({
    required String nome,
    required String email,
    required String cpf,
    required String senha,
  }) async {}
}

void main() {
  group('CadastroScreen', () {
    Widget buildScreen() {
      return ProviderScope(
        overrides: [
          usuarioViewModelProvider.overrideWith(() => FakeUsuarioNotifier()),
        ],
        child: const MaterialApp(home: CadastroScreen()),
      );
    }

    testWidgets('Smoke test - renderiza sem crashar', (tester) async {
      await tester.pumpWidget(buildScreen());

      expect(find.byType(CadastroScreen), findsOneWidget);
    });

    testWidgets('Widgets principais - exibe título, campos e botão principal', (
      tester,
    ) async {
      await tester.pumpWidget(buildScreen());

      expect(find.text('Criar Conta'), findsWidgets);

      expect(find.text('NOME COMPLETO'), findsOneWidget);
      expect(find.text('CPF'), findsOneWidget);
      expect(find.text('E-MAIL'), findsOneWidget);
      expect(find.text('CONFIRMAR E-MAIL'), findsOneWidget);
      expect(find.text('SENHA'), findsOneWidget);
      expect(find.text('CONFIRMAR SENHA'), findsOneWidget);

      expect(find.byType(TextField), findsWidgets);

      expect(find.text('João da Silva'), findsOneWidget);
      expect(find.text('000.000.000-00'), findsOneWidget);
      expect(find.text('seu@email.com'), findsOneWidget);
      expect(find.text('Repita o e-mail'), findsOneWidget);
      expect(find.text('Mínimo 6 caracteres'), findsOneWidget);
      expect(find.text('Repita a senha'), findsOneWidget);

      // RichText não expõe os TextSpan via find.text
      expect(find.byType(RichText), findsWidgets);
    });

    testWidgets(
      'Comportamento básico - exibe erro quando e-mails não correspondem',
      (tester) async {
        await tester.pumpWidget(buildScreen());

        final textFields = find.byType(TextField);

        await tester.enterText(textFields.at(2), 'teste@email.com');
        await tester.enterText(textFields.at(3), 'outro@email.com');

        await tester.pump();

        expect(find.text('Os e-mails não correspondem'), findsOneWidget);
      },
    );
  });
}
