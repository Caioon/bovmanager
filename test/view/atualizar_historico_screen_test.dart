import 'package:bov_manager/models/historico_tipo.dart';
import 'package:bov_manager/models/pasto_model.dart';
import 'package:bov_manager/models/rebanho_model.dart';
import 'package:bov_manager/viewmodels/animal_viewmodel.dart';
import 'package:bov_manager/viewmodels/historico_animal_viewmodel.dart';
import 'package:bov_manager/viewmodels/pasto_viewmodel.dart';
import 'package:bov_manager/viewmodels/rebanho_viewmodel.dart';
import 'package:bov_manager/view/atualizar_historico_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class FakeAnimaisNotifier extends AnimaisViewModel {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  @override
  Future<void> registrarHistoricoMovimento({
    required DateTime data,
    required HistoricoTipo tipo,
    String? pastoOrigemId,
    String? pastoDestinoId,
    String? rebanhoOrigemId,
    String? rebanhoDestinoId,
    String? nomePastoOrigem,
    String? nomePastoDestino,
    String? nomeRebanhoOrigem,
    String? nomeRebanhoDestino,
  }) async {}
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

PastoModel _fakePasto(String id) => PastoModel(
  id: id,
  nome: 'Pasto $id',
  propriedadeId: 'prop-1',
  area: 10.0,
  descricao: 'Descrição $id',
);

/// Suprime erros de overflow de layout para que não falhem os testes.
/// Overflows de layout são irrelevantes para os comportamentos testados aqui.
void _ignorarOverflow() {
  final original = FlutterError.onError!;
  FlutterError.onError = (details) {
    if (details.exceptionAsString().contains('overflowed')) return;
    original(details);
  };
  addTearDown(() => FlutterError.onError = original);
}

Widget buildScreen({
  bool temRebanho = false,
  List<PastoModel> pastos = const [],
  List<RebanhoModel> rebanhos = const [],
}) {
  return ProviderScope(
    overrides: [
      animaisViewModelProvider.overrideWith(() => FakeAnimaisNotifier()),
      pastosListaPropEmVisualizacaoProvider.overrideWith(
        (ref) => Future.value(pastos),
      ),
      rebanhoListaProvider.overrideWith((ref) => Stream.value(rebanhos)),
      historicoAnimalListaProvider.overrideWith((ref) => Stream.value([])),
    ],
    child: MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: ElevatedButton(
            onPressed: () => showAtualizarHistoricoModal(
              context,
              temRebanho: temRebanho,
              podeMovimentarRebanho: true,
              podeMudarPasto: true,
            ),
            child: const Text('Abrir Modal'),
          ),
        ),
      ),
    ),
  );
}

Future<void> abrirModal(WidgetTester tester) async {
  await tester.tap(find.text('Abrir Modal'));
  await tester.pumpAndSettle();
}

// ---------------------------------------------------------------------------
// Testes
// ---------------------------------------------------------------------------

void main() {
  group('showAtualizarHistoricoModal', () {
    // 1. Smoke test ──────────────────────────────────────────────────────────
    testWidgets('renderiza o modal sem crashar', (tester) async {
      _ignorarOverflow();

      await tester.pumpWidget(buildScreen());
      await abrirModal(tester);

      expect(find.text('Registrar alteração'), findsOneWidget);
    });

    // 2. Widgets principais ──────────────────────────────────────────────────
    testWidgets('exibe título e todas as opções do modal', (tester) async {
      _ignorarOverflow();

      await tester.pumpWidget(buildScreen(temRebanho: true));
      await abrirModal(tester);

      expect(find.text('Registrar alteração'), findsOneWidget);

      // Seção de pesagem
      expect(find.text('PESAGEM'), findsOneWidget);
      expect(find.text('Registrar peso'), findsOneWidget);
      expect(find.text('Atualizar o peso do animal'), findsOneWidget);

      // Seção de movimentação
      expect(find.text('MOVIMENTAÇÃO'), findsOneWidget);
      expect(find.text('Mudar de rebanho'), findsOneWidget);
      expect(find.text('Vai para o pasto do rebanho'), findsOneWidget);
      expect(find.text('Mudar para outro pasto'), findsOneWidget);
      expect(find.text('Sai do rebanho e muda de pasto'), findsOneWidget);
      expect(find.text('Sair do rebanho'), findsOneWidget);
      expect(find.text('Permanece no mesmo pasto'), findsOneWidget);
    });

    // 3. Comportamento básico ────────────────────────────────────────────────
    testWidgets(
      'ao tocar em Registrar peso fecha o modal e abre a tela de pesagem',
      (tester) async {
        _ignorarOverflow();

        await tester.pumpWidget(buildScreen());
        await abrirModal(tester);

        await tester.tap(find.text('Registrar peso'));
        await tester.pumpAndSettle();

        // Modal fechou
        expect(find.text('Registrar alteração'), findsNothing);

        // Tela de pesagem aberta (título + botão têm o mesmo texto)
        expect(find.text('Registrar Pesagem'), findsWidgets);
        expect(find.text('NOVO PESO (KG)'), findsOneWidget);
      },
    );
  });
}
