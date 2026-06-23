import 'package:bov_manager/core/widgets/bov_widgets.dart';
import 'package:bov_manager/models/pasto_model.dart';
import 'package:bov_manager/view/lista_pastos_screen.dart';
import 'package:bov_manager/viewmodels/pasto_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// ── Dados de teste ──────────────────────────────────────────────────────────

final fakePasto = PastoModel(
  id: 'pasto-1',
  nome: 'Pasto Norte A',
  propriedadeId: 'prop-1',
  area: 12.5,
  descricao: 'Pasto principal',
);

// ── Fake Notifier ───────────────────────────────────────────────────────────

class FakePastoEmVisualizacaoNotifier extends PastoEmVisualizacao {
  @override
  PastoModel? build() => null;

  @override
  void abrir(PastoModel pasto) {} // no-op

  @override
  void fechar() {} // no-op
}

// ── Helper ──────────────────────────────────────────────────────────────────

Widget buildScreen({List<PastoModel> pastos = const []}) {
  return ProviderScope(
    overrides: [
      pastosListaPropEmVisualizacaoProvider.overrideWith(
        (ref) => Future.value(pastos),
      ),
      pastoEmVisualizacaoProvider.overrideWith(
        () => FakePastoEmVisualizacaoNotifier(),
      ),
    ],
    child: const MaterialApp(home: ListaPastosScreen()),
  );
}

// ── Testes ───────────────────────────────────────────────────────────────────

void main() {
  group('ListaPastosScreen', () {
    // 1. Smoke test
    testWidgets('renderiza sem crashar com lista de pastos carregada',
        (tester) async {
      await tester.pumpWidget(buildScreen(pastos: [fakePasto]));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    // 2. Widgets principais
    testWidgets('exibe título, botão de adicionar e item da lista', (tester) async {
      await tester.pumpWidget(buildScreen(pastos: [fakePasto]));
      await tester.pumpAndSettle();

      // Título
      expect(find.text('Pastos'), findsOneWidget);

      // Botão de adicionar pasto
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);

      // Item do pasto na lista
      expect(find.text('Pasto Norte A'), findsOneWidget);
    });

    // 3. Comportamento básico — lista vazia exibe empty state
    testWidgets('exibe empty state quando não há pastos cadastrados',
        (tester) async {
      await tester.pumpWidget(buildScreen(pastos: []));
      await tester.pumpAndSettle();

      expect(find.text('Nenhum pasto'), findsOneWidget);
      expect(
        find.text('Cadastre o primeiro pasto desta\npropriedade para começar.'),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(BovPrimaryButton, 'Cadastrar Pasto'),
        findsOneWidget,
      );
    });
  });
}
