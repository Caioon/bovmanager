import 'package:bov_manager/models/propriedade_model.dart';
import 'package:bov_manager/view/propriedade_screen.dart';
import 'package:bov_manager/viewmodels/propriedade_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// =============================================================================
// FAKE NOTIFIER — PropriedadeEmVisualizacao
// Estende a classe concreta. build() retorna null; abrir() é no-op para
// evitar qualquer dependência real ao tocar num card da lista.
// =============================================================================

class FakePropriedadeEmVisualizacao extends PropriedadeEmVisualizacao {
  @override
  PropriedadeModel? build() => null;

  @override
  void abrir(PropriedadeModel propriedade) {}
}

// =============================================================================
// DADOS FAKE
// =============================================================================

final _fakeProp = PropriedadeModel(
  id: 'prop-1',
  nome: 'Fazenda Boa Vista',
  proprietarioId: 'user-1',
  dataCadastro: DateTime(2024, 1, 15),
);

// =============================================================================
// TESTES
// =============================================================================

void main() {
  group('PropriedadesScreen', () {
    // -------------------------------------------------------------------------
    // Helper centralizado.
    //
    // propriedades         → lista emitida pelo StreamProvider da tela.
    // idsCompartilhadas    → IDs que o FutureProvider de badges deve retornar.
    // -------------------------------------------------------------------------
    Widget buildScreen({
      List<PropriedadeModel> propriedades = const [],
      Set<String> idsCompartilhadas = const {},
    }) {
      return ProviderScope(
        overrides: [
          // Stream da lista principal
          propriedadesListaProvider.overrideWith(
            (ref) => Stream.value(propriedades),
          ),
          // FutureProvider definido no próprio arquivo da tela —
          // sobrescrito diretamente, sem precisar de acessoCompartilhadoService
          // nem de usuarioAtualProvider.
          propriedadesCompartilhadasIdsProvider.overrideWith(
            (ref) => Future.value(idsCompartilhadas),
          ),
          // Notifier de navegação — no-op para isolar AppCoordinator
          propriedadeEmVisualizacaoProvider.overrideWith(
            () => FakePropriedadeEmVisualizacao(),
          ),
        ],
        child: const MaterialApp(home: PropriedadesScreen()),
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
    // Com uma propriedade na lista: título, botão de adição e card visíveis.
    // -------------------------------------------------------------------------
    testWidgets('exibe título, botão de adicionar e card da propriedade', (
      tester,
    ) async {
      await tester.pumpWidget(buildScreen(propriedades: [_fakeProp]));
      await tester.pumpAndSettle();

      // Título do header
      expect(find.text('Propriedades'), findsOneWidget);

      // Ícone de adicionar no header
      expect(find.byIcon(Icons.add_rounded), findsWidgets);

      // Nome da propriedade renderizado no card
      expect(find.text('Fazenda Boa Vista'), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // 3. Comportamento básico
    // Quando o ID da propriedade está no set de compartilhadas, o card exibe
    // o badge "Propriedade compartilhada".
    // -------------------------------------------------------------------------
    testWidgets(
      'exibe badge de propriedade compartilhada quando id está no set',
      (tester) async {
        await tester.pumpWidget(
          buildScreen(
            propriedades: [_fakeProp],
            idsCompartilhadas: {_fakeProp.id},
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Propriedade compartilhada'), findsOneWidget);
      },
    );
  });
}
