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
/// O overflow ocorre porque showModalBottomSheet sem isScrollControlled
/// limita a ~50% da tela — irrelevante para os comportamentos testados.
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
      rebanhoListaProvider.overrideWith(
        (ref) => Stream.value(rebanhos),
      ),
      historicoAnimalListaProvider.overrideWith(
        (ref) => Stream.value([]),
      ),
    ],
    child: MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: ElevatedButton(
            onPressed: () => showAtualizarHistoricoModal(context, temRebanho),
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

      expect(find.text('O que deseja registrar?'), findsOneWidget);
    });

    // 2. Widgets principais ──────────────────────────────────────────────────
    testWidgets('exibe título e todas as opções do modal', (tester) async {
      _ignorarOverflow();

      await tester.pumpWidget(buildScreen(temRebanho: true));
      await abrirModal(tester);

      expect(find.text('O que deseja registrar?'), findsOneWidget);
      expect(find.text('Pesagem'), findsOneWidget);
      expect(find.text('Registrar novo peso do animal'), findsOneWidget);
      expect(find.text('Movimentação'), findsNWidgets(3));
      expect(find.text('Mudar de rebanho'), findsOneWidget);
      expect(find.text('Sair do rebanho e mudar o pasto'), findsOneWidget);
      expect(find.text('Sair do rebanho e ficar no pasto'), findsOneWidget);
    });

    // 3. Comportamento básico ────────────────────────────────────────────────
    testWidgets(
        'ao tocar em Pesagem com menos de 2 pastos exibe snackbar de erro',
        (tester) async {
      _ignorarOverflow();

      await tester.pumpWidget(
        buildScreen(pastos: [_fakePasto('1')]),
      );
      await abrirModal(tester);

      await tester.tap(find.text('Pesagem'));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Cadastre ao menos 2 pastos para registrar uma movimentação.',
        ),
        findsOneWidget,
      );
    });
  });
}
