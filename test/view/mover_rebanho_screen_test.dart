import 'package:bov_manager/models/pasto_model.dart';
import 'package:bov_manager/models/rebanho_model.dart';
import 'package:bov_manager/view/mover_rebanho_screen.dart';
import 'package:bov_manager/viewmodels/pasto_viewmodel.dart';
import 'package:bov_manager/viewmodels/rebanho_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// ── Dados de teste ──────────────────────────────────────────────────────────

final fakeRebanho = RebanhoModel(
  id: 'rebanho-1',
  nome: 'Rebanho Teste',
  pastoId: 'pasto-1',
  propriedadeId: 'prop-1',
  dataCadastro: DateTime(2024, 1, 1),
);

final fakePastoAtual = PastoModel(
  id: 'pasto-1',
  nome: 'Pasto Norte',
  propriedadeId: 'prop-1',
  area: 10.0,
  descricao: '',
);

final fakePastoDestino = PastoModel(
  id: 'pasto-2',
  nome: 'Pasto Sul',
  propriedadeId: 'prop-1',
  area: 8.0,
  descricao: '',
);

// ── Fakes ────────────────────────────────────────────────────────────────────

class FakeRebanhoEmVisualizacaoNotifier extends RebanhoEmVisualizacao {
  final RebanhoModel? estadoInicial;

  FakeRebanhoEmVisualizacaoNotifier({this.estadoInicial});

  @override
  RebanhoModel? build() => estadoInicial;

  @override
  void abrir(RebanhoModel rebanho) {}

  @override
  void fechar() {}
}

class FakeRebanhoViewModelNotifier extends RebanhoViewModel {
  @override
  Future<void> build() async {}

  @override
  Future<void> mover({
    required String rebanhoId,
    required String antigoPastoId,
    required String novoPastoId,
    String? nomePastoOrigem,
    String? nomePastoDestino,
    required DateTime data,
  }) async {}
}

// ── Helper ───────────────────────────────────────────────────────────────────

Widget buildScreen({
  RebanhoModel? rebanho,
  List<PastoModel> pastos = const [],
}) {
  return ProviderScope(
    overrides: [
      rebanhoEmVisualizacaoProvider.overrideWith(
        () => FakeRebanhoEmVisualizacaoNotifier(estadoInicial: rebanho),
      ),
      rebanhoViewModelProvider.overrideWith(
        () => FakeRebanhoViewModelNotifier(),
      ),
      pastosListaPropEmVisualizacaoProvider.overrideWith(
        (ref) => Future.value(pastos),
      ),
    ],
    child: const MaterialApp(home: MoverRebanhoScreen()),
  );
}

// ── Testes ───────────────────────────────────────────────────────────────────

void main() {
  group('MoverRebanhoScreen', () {
    // 1. Smoke test
    testWidgets('renderiza sem crashar com rebanho carregado', (tester) async {
      await tester.pumpWidget(
        buildScreen(
          rebanho: fakeRebanho,
          pastos: [fakePastoAtual, fakePastoDestino],
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    // 2. Widgets principais
    testWidgets('exibe título, labels de origem/destino e botão de confirmar',
        (tester) async {
      await tester.pumpWidget(
        buildScreen(
          rebanho: fakeRebanho,
          pastos: [fakePastoAtual, fakePastoDestino],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Mover Rebanho'), findsOneWidget);
      expect(find.text('ORIGEM'), findsOneWidget);
      expect(find.text('DESTINO'), findsOneWidget);
      expect(find.text('Confirmar movimentação'), findsOneWidget);
    });

    // 3. Comportamento — dropdown vazio quando só existe o pasto atual
    testWidgets(
        'exibe "Sem outros pastos" quando não há pastos de destino disponíveis',
        (tester) async {
      await tester.pumpWidget(
        buildScreen(
          rebanho: fakeRebanho,
          pastos: [fakePastoAtual], // único pasto é o atual → pastosDestino vazio
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sem outros pastos'), findsOneWidget);
    });
  });
}
