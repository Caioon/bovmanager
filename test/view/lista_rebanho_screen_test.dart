import 'package:bov_manager/core/widgets/bov_widgets.dart';
import 'package:bov_manager/models/pasto_model.dart';
import 'package:bov_manager/models/rebanho_model.dart';
import 'package:bov_manager/models/propriedade_model.dart';
import 'package:bov_manager/view/lista_rebanho_screen.dart';
import 'package:bov_manager/viewmodels/pasto_viewmodel.dart';
import 'package:bov_manager/viewmodels/propriedade_viewmodel.dart';
import 'package:bov_manager/viewmodels/rebanho_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// ── Dados de teste ──────────────────────────────────────────────────────────

final fakeProprieddade = PropriedadeModel(
  id: 'prop-1',
  nome: 'Fazenda Teste',
  proprietarioId: 'user-1',
  dataCadastro: DateTime(2024, 1, 1),
);

final fakePasto = PastoModel(
  id: 'pasto-1',
  nome: 'Pasto Norte',
  propriedadeId: 'prop-1',
  area: 10.0,
  descricao: '',
);

final fakeRebanho = RebanhoModel(
  id: 'rebanho-1',
  nome: 'Rebanho Alpha',
  pastoId: 'pasto-1',
  propriedadeId: 'prop-1',
  dataCadastro: DateTime(2024, 3, 1),
);

// ── Fakes ───────────────────────────────────────────────────────────────────

class FakePropriedadeEmVisualizacaoNotifier
    extends PropriedadeEmVisualizacao {
  @override
  PropriedadeModel? build() => fakeProprieddade;

  @override
  void abrir(PropriedadeModel propriedade) {}

  @override
  void fechar() {}
}

class FakeRebanhoEmVisualizacaoNotifier extends RebanhoEmVisualizacao {
  @override
  RebanhoModel? build() => null;

  @override
  void abrir(RebanhoModel rebanho) {} // no-op

  @override
  void fechar() {} // no-op
}

class FakeRebanhoViewModelNotifier extends RebanhoViewModel {
  @override
  Future<void> build() async {}

  @override
  Future<void> apagarRebanho({required String rebanhoId}) async {} // no-op
}

// ── Helper ──────────────────────────────────────────────────────────────────

Widget buildScreen({List<RebanhoModel> rebanhos = const []}) {
  return ProviderScope(
    overrides: [
      propriedadeEmVisualizacaoProvider.overrideWith(
        () => FakePropriedadeEmVisualizacaoNotifier(),
      ),
      rebanhoListaProvider.overrideWith(
        (ref) => Stream.value(rebanhos),
      ),
      pastosListaPropEmVisualizacaoProvider.overrideWith(
        (ref) => Future.value([fakePasto]),
      ),
      rebanhoEmVisualizacaoProvider.overrideWith(
        () => FakeRebanhoEmVisualizacaoNotifier(),
      ),
      rebanhoViewModelProvider.overrideWith(
        () => FakeRebanhoViewModelNotifier(),
      ),
    ],
    child: const MaterialApp(home: ListaRebanhoScreen()),
  );
}

// ── Testes ───────────────────────────────────────────────────────────────────

void main() {
  group('ListaRebanhoScreen', () {
    // 1. Smoke test
    testWidgets('renderiza sem crashar com lista de rebanhos carregada',
        (tester) async {
      await tester.pumpWidget(buildScreen(rebanhos: [fakeRebanho]));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    // 2. Widgets principais
    testWidgets('exibe título, botão de adicionar e item do rebanho',
        (tester) async {
      await tester.pumpWidget(buildScreen(rebanhos: [fakeRebanho]));
      await tester.pumpAndSettle();

      // Título
      expect(find.text('Rebanhos'), findsOneWidget);

      // Botão de adicionar
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);

      // Nome do rebanho e badge de status na lista
      expect(find.text('Rebanho Alpha'), findsOneWidget);
      expect(find.text('Ativo'), findsOneWidget);
    });

    // 3. Comportamento básico — lista vazia exibe empty state
    testWidgets('exibe empty state quando não há rebanhos cadastrados',
        (tester) async {
      await tester.pumpWidget(buildScreen(rebanhos: []));
      await tester.pumpAndSettle();

      expect(find.text('Nenhum rebanho'), findsOneWidget);
      expect(
        find.text(
            'Cadastre o primeiro rebanho desta\npropriedade para começar.'),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(BovPrimaryButton, 'Criar Rebanho'),
        findsOneWidget,
      );
    });
  });
}
