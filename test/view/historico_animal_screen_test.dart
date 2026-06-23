import 'package:bov_manager/viewmodels/historico_animal_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bov_manager/models/animal_model.dart';
import 'package:bov_manager/models/historico_animal_model.dart';
import 'package:bov_manager/models/historico_tipo.dart';
import 'package:bov_manager/models/propriedade_model.dart';
import 'package:bov_manager/view/historico_animal_screen.dart';
import 'package:bov_manager/viewmodels/animal_viewmodel.dart';
import 'package:bov_manager/viewmodels/pasto_viewmodel.dart';
import 'package:bov_manager/viewmodels/propriedade_viewmodel.dart';

// =============================================================================
// FAKE NOTIFIER — substitui historicoAnimalListaProvider diretamente
// expondo AsyncValue sem passar por stream
// =============================================================================

// Provider manual que usamos no lugar do gerado
final fakeHistoricoProvider =
    StateProvider<AsyncValue<List<HistoricoAnimalModel>>>(
      (ref) => const AsyncLoading(),
    );

// =============================================================================
// FAKES DOS NOTIFIERS
// =============================================================================

class FakeAnimalEmVisualizacao extends AnimalEmVisualizacao {
  final AnimalModel? initialValue;
  FakeAnimalEmVisualizacao(this.initialValue);

  @override
  AnimalModel? build() => initialValue;
}

class FakePropriedadeEmVisualizacao extends PropriedadeEmVisualizacao {
  final PropriedadeModel? initialValue;
  FakePropriedadeEmVisualizacao(this.initialValue);

  @override
  PropriedadeModel? build() => initialValue;
}

// =============================================================================
// DADOS FAKE
// =============================================================================

final _animalFake = AnimalModel(
  id: 'a1',
  nome: 'Boi Caipira',
  brinco: '001',
  raca: 'Nelore',
  pesoAtual: 450,
  dataNascimento: DateTime(2020, 3, 10),
  propriedadeId: 'p1',
);

final _animalSemNome = AnimalModel(
  id: 'a2',
  nome: '',
  brinco: '042',
  raca: 'Angus',
  pesoAtual: 380,
  dataNascimento: DateTime(2021, 1, 5),
  propriedadeId: 'p1',
);

final _propriedadeFake = PropriedadeModel(
  id: 'p1',
  nome: 'Fazenda Teste',
  proprietarioId: 'u1',
  dataCadastro: DateTime(2024, 1, 1),
);

HistoricoAnimalModel _makeHistorico({
  required String id,
  required HistoricoTipo tipo,
  double? novoPeso,
  String? nomePastoOrigem,
  String? nomePastoDestino,
  String? pastoOrigemId, 
  String? pastoDestinoId, 
}) => HistoricoAnimalModel(
  id: id,
  animalId: 'a1',
  tipo: tipo,
  novoPeso: novoPeso,
  pastoOrigemId: pastoOrigemId, 
  pastoDestinoId: pastoDestinoId, 
  rebanhoOrigemId: null,
  rebanhoDestinoId: null,
  nomePastoOrigem: nomePastoOrigem,
  nomePastoDestino: nomePastoDestino,
  data: DateTime(2024, 6, 1),
);

// =============================================================================
// BUILDER
// =============================================================================

Widget buildScreen({
  AnimalModel? animal,
  bool animalNulo = false,
  AsyncValue<List<HistoricoAnimalModel>> historico = const AsyncLoading(),
}) {
  final animalValue = animalNulo ? null : (animal ?? _animalFake);

  return ProviderScope(
    overrides: [
      animalEmVisualizacaoProvider.overrideWith(
        () => FakeAnimalEmVisualizacao(animalValue),
      ),
      propriedadeEmVisualizacaoProvider.overrideWith(
        () => FakePropriedadeEmVisualizacao(_propriedadeFake),
      ),
      pastosListaPropEmVisualizacaoProvider.overrideWith((_) async => []),
      // overrideWithValue seta o AsyncValue diretamente no provider,
      // sem passar por stream → sem retry, sem timing
      historicoAnimalListaProvider.overrideWithValue(historico),
    ],
    child: MaterialApp(
      home: const HistoricoAnimalScreen(),
      routes: {'/dummy': (_) => const Scaffold()},
    ),
  );
}

// =============================================================================
// TESTES
// =============================================================================

void main() {
  // ---------------------------------------------------------------------------
  // HEADER
  // ---------------------------------------------------------------------------

  group('HistoricoAnimalScreen — header', () {
    testWidgets('exibe nome do animal no título', (tester) async {
      await tester.pumpWidget(buildScreen(historico: const AsyncData([])));
      await tester.pump();

      expect(find.textContaining('Boi Caipira'), findsOneWidget);
    });

    testWidgets('exibe brinco no título quando nome está vazio', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildScreen(animal: _animalSemNome, historico: const AsyncData([])),
      );
      await tester.pump();

      expect(find.textContaining('#042'), findsOneWidget);
    });

    testWidgets('exibe título genérico quando animal é null', (tester) async {
      await tester.pumpWidget(
        buildScreen(animalNulo: true, historico: const AsyncData([])),
      );
      await tester.pump();

      expect(find.text('Histórico'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // LOADING
  // ---------------------------------------------------------------------------

  group('HistoricoAnimalScreen — loading', () {
    testWidgets('exibe CircularProgressIndicator enquanto aguarda', (
      tester,
    ) async {
      await tester.pumpWidget(buildScreen(historico: const AsyncLoading()));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // ERRO
  // ---------------------------------------------------------------------------

  group('HistoricoAnimalScreen — erro', () {
    testWidgets('exibe mensagem de erro quando stream falha', (tester) async {
      await tester.pumpWidget(
        buildScreen(
          historico: AsyncError(Exception('falha de rede'), StackTrace.empty),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.textContaining('Exception: falha de rede'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // EMPTY STATE
  // ---------------------------------------------------------------------------

  group('HistoricoAnimalScreen — empty state', () {
    testWidgets('exibe empty state quando histórico está vazio', (
      tester,
    ) async {
      await tester.pumpWidget(buildScreen(historico: const AsyncData([])));
      await tester.pump();

      expect(find.text('Nenhum histórico'), findsOneWidget);
    });

    testWidgets('exibe empty state quando animal é null mesmo com dados', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildScreen(
          animalNulo: true,
          historico: AsyncData([
            _makeHistorico(
              id: 'h1',
              tipo: HistoricoTipo.pesagem,
              novoPeso: 400,
            ),
          ]),
        ),
      );
      await tester.pump();

      expect(find.text('Nenhum histórico'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // DADOS
  // ---------------------------------------------------------------------------

  group('HistoricoAnimalScreen — dados', () {
    testWidgets('exibe seção EVOLUÇÃO DE PESO quando há pesagens', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildScreen(
          historico: AsyncData([
            // mais recente primeiro → pesagens.first.novoPeso = 420
            _makeHistorico(
              id: 'h2',
              tipo: HistoricoTipo.pesagem,
              novoPeso: 420,
            ),
            _makeHistorico(
              id: 'h1',
              tipo: HistoricoTipo.entrada,
              novoPeso: 300,
              pastoDestinoId: 'pasto-a',
              nomePastoDestino: 'Pasto A',
            ),
          ]),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('EVOLUÇÃO DE PESO'), findsOneWidget);
      expect(find.textContaining('420 kg'), findsOneWidget);
    });
    testWidgets('exibe seção MOVIMENTAÇÕES quando há movimentações', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildScreen(
          historico: AsyncData([
            _makeHistorico(
              id: 'h1',
              tipo: HistoricoTipo.entrada,
              novoPeso: 300,
              pastoDestinoId: 'pasto-a',
              nomePastoDestino: 'Pasto Origem',
            ),
            _makeHistorico(
              id: 'h2',
              tipo: HistoricoTipo.mudarPasto,
              pastoOrigemId: 'pasto-a',
              pastoDestinoId: 'pasto-b',
              nomePastoOrigem: 'Pasto Origem',
              nomePastoDestino: 'Pasto Destino',
            ),
          ]),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('MOVIMENTAÇÕES'), findsOneWidget);
      // _MovimentacaoItem usa RichText direto (não Text),
      // então find.textContaining não funciona em versões antigas do Flutter
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is RichText &&
              widget.text.toPlainText().contains('Pasto Destino'),
        ),
        findsOneWidget,
      );
    });
    testWidgets('não exibe loading após dados chegarem', (tester) async {
      await tester.pumpWidget(
        buildScreen(
          historico: AsyncData([
            _makeHistorico(
              id: 'h1',
              tipo: HistoricoTipo.pesagem,
              novoPeso: 400,
            ),
          ]),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('não exibe empty state quando há dados', (tester) async {
      await tester.pumpWidget(
        buildScreen(
          historico: AsyncData([
            _makeHistorico(
              id: 'h1',
              tipo: HistoricoTipo.pesagem,
              novoPeso: 400,
            ),
          ]),
        ),
      );
      await tester.pump();

      expect(find.text('Nenhum histórico'), findsNothing);
    });
  });
}
