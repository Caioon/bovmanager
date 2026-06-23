import 'package:bov_manager/core/widgets/bov_widgets.dart';
import 'package:bov_manager/models/usuario_model.dart';
import 'package:bov_manager/view/alterar_cpf_screen.dart';
import 'package:bov_manager/viewmodels/usuario_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// Estende a classe concreta UsuarioViewModel (não a gerada _$UsuarioViewModel).
// Sobrescreve apenas os métodos usados pela tela como no-ops.
class FakeUsuarioNotifier extends UsuarioViewModel {
  @override
  AsyncValue<UsuarioModel?> build() => const AsyncData(null);

  @override
  Future<void> atualizarCpf(String novoCpf) async {}
}

void main() {
  group('AlterarCpfScreen', () {
    Widget buildScreen({String cpfAtual = ''}) {
      return ProviderScope(
        overrides: [
          usuarioViewModelProvider.overrideWith(() => FakeUsuarioNotifier()),
        ],
        child: MaterialApp(
          home: AlterarCpfScreen(cpfAtual: cpfAtual),
        ),
      );
    }

    // ── Teste 1: Smoke test ───────────────────────────────────────────────
    testWidgets('renderiza a tela sem crashar', (tester) async {
      await tester.pumpWidget(buildScreen());

      expect(find.byType(AlterarCpfScreen), findsOneWidget);
    });

    // ── Teste 2: Widgets principais ──────────────────────────────────────
    testWidgets('exibe título, campo CPF e botão Salvar', (tester) async {
      await tester.pumpWidget(buildScreen());

      expect(find.text('Alterar CPF'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Salvar'), findsOneWidget);
      expect(find.byType(BovBackButton), findsOneWidget);
    });

    // ── Teste 3: Comportamento do campo CPF e botão ──────────────────────
    testWidgets(
      'botão Salvar fica desabilitado com CPF inválido e habilitado com CPF válido',
      (tester) async {
        await tester.pumpWidget(buildScreen(cpfAtual: ''));

        // CPF vazio → botão desabilitado
        final botaoInicial =
            tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        expect(botaoInicial.onPressed, isNull);

        // Digita CPF incompleto → mensagem de erro aparece
        await tester.enterText(find.byType(TextField), '12345');
        await tester.pump();

        expect(find.text('CPF inválido — insira 11 dígitos'), findsOneWidget);

        // Digita CPF completo válido → botão habilitado
        await tester.enterText(find.byType(TextField), '52998224725');
        await tester.pump();

        final botaoHabilitado =
            tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        expect(botaoHabilitado.onPressed, isNotNull);
      },
    );
  });
}
