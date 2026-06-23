import 'package:bov_manager/models/usuario_model.dart';
import 'package:bov_manager/repositories/usuario_repository.dart';
import 'package:bov_manager/view/detalhes_perfil_screen.dart';
import 'package:bov_manager/viewmodels/notificacao_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final usuarioFake = UsuarioModel(
  id: '1',
  nome: 'João Silva',
  email: 'joao@email.com',
  cpf: '12345678900',
);

class FakeNotificacaoViewModel extends NotificacaoViewModel {
  @override
  Future<bool> build() async {
    return true;
  }
}

void main() {
  testWidgets('DetalhesPerfilScreen exibe usuário não encontrado', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          usuarioAtualProvider.overrideWith((ref) => Stream.value(null)),
          notificacaoViewModelProvider.overrideWith(
            () => FakeNotificacaoViewModel(),
          ),
        ],
        child: const MaterialApp(home: DetalhesPerfilScreen()),
      ),
    );

    await tester.pump();

    expect(find.text('Usuário não encontrado'), findsOneWidget);
  });

  testWidgets('DetalhesPerfilScreen exibe dados do usuário', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          usuarioAtualProvider.overrideWith((ref) => Stream.value(usuarioFake)),
          notificacaoViewModelProvider.overrideWith(
            () => FakeNotificacaoViewModel(),
          ),
        ],
        child: const MaterialApp(home: DetalhesPerfilScreen()),
      ),
    );

    await tester.pump();

    expect(find.text('Meus dados'), findsOneWidget);
    expect(find.text('João Silva'), findsOneWidget);
    expect(find.text('joao@email.com'), findsOneWidget);
    expect(find.text('Alterar Senha'), findsOneWidget);
  });

  testWidgets('DetalhesPerfilScreen abre diálogo de senha', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          usuarioAtualProvider.overrideWith((ref) => Stream.value(usuarioFake)),
          notificacaoViewModelProvider.overrideWith(
            () => FakeNotificacaoViewModel(),
          ),
        ],
        child: const MaterialApp(home: DetalhesPerfilScreen()),
      ),
    );

    await tester.pump();

    final scrollable = find.byType(Scrollable);

    await tester.scrollUntilVisible(
      find.text('Alterar Senha'),
      200,
      scrollable: scrollable,
    );

    await tester.tap(find.text('Alterar Senha'));

    await tester.pump();

    expect(find.text('Confirmar senha'), findsOneWidget);
  });
}
