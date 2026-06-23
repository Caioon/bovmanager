import 'package:bov_manager/core/widgets/bov_widgets.dart';
import 'package:bov_manager/models/propriedade_model.dart';
import 'package:bov_manager/models/tarefa_model.dart';
import 'package:bov_manager/view/lista_tarefas_screen.dart';
import 'package:bov_manager/viewmodels/propriedade_viewmodel.dart';
import 'package:bov_manager/viewmodels/tarefa_viewmodel.dart';
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

final fakeTarefa = TarefaModel(
  id: 'tarefa-1',
  titulo: 'Vacinar animais',
  descricao: 'Aplicar vacina FMD',
  dataExecucao: DateTime.now().add(const Duration(days: 1)),
  status: StatusTarefa.pendente,
  propriedadeId: 'prop-1',
  usuarioId: 'user-1',
);

// ── Fakes ───────────────────────────────────────────────────────────────────

class FakePropriedadeSelecionadaNotifier extends PropriedadeSelecionada {
  final AsyncValue<PropriedadeModel?> estadoInicial;

  FakePropriedadeSelecionadaNotifier({required this.estadoInicial});

  @override
  AsyncValue<PropriedadeModel?> build() => estadoInicial;

  @override
  void selecionar(PropriedadeModel propriedade) {}

  @override
  void limpar() {}
}

class FakeTarefasViewModelNotifier extends TarefasViewModel {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  @override
  Future<void> concluir({required String tarefaId}) async {}

  @override
  Future<void> reabrir({required TarefaModel tarefa}) async {}

  @override
  Future<void> adiar({
    required String tarefaId,
    required DateTime novaData,
    required String titulo,
    int? horaExecucaoMinutos,
    bool clearHora = false,
  }) async {}

  @override
  Future<void> editar({
    required String tarefaId,
    required String titulo,
    required String descricao,
    required DateTime dataExecucao,
    int? horaExecucaoMinutos,
    bool clearHora = false,
  }) async {}

  @override
  Future<void> apagar({required String tarefaId}) async {}
}

// ── Helper ──────────────────────────────────────────────────────────────────

Widget buildScreen({
  AsyncValue<PropriedadeModel?> propriedade = const AsyncData(null),
  List<TarefaModel> tarefas = const [],
}) {
  return ProviderScope(
    overrides: [
      propriedadeSelecionadaProvider.overrideWith(
        () => FakePropriedadeSelecionadaNotifier(estadoInicial: propriedade),
      ),
      tarefasListaProvider.overrideWith(
        (ref) => Stream.value(tarefas),
      ),
      tarefasViewModelProvider.overrideWith(
        () => FakeTarefasViewModelNotifier(),
      ),
    ],
    child: const MaterialApp(home: ListaTarefasScreen()),
  );
}

// ── Testes ───────────────────────────────────────────────────────────────────

void main() {
  group('ListaTarefasScreen', () {
    // 1. Smoke test
    testWidgets('renderiza sem crashar com propriedade e tarefas carregadas',
        (tester) async {
      await tester.pumpWidget(
        buildScreen(
          propriedade: AsyncData(fakeProprieddade),
          tarefas: [fakeTarefa],
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    // 2. Widgets principais
    testWidgets('exibe título, botão de adicionar e item da tarefa na lista',
        (tester) async {
      await tester.pumpWidget(
        buildScreen(
          propriedade: AsyncData(fakeProprieddade),
          tarefas: [fakeTarefa],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Tarefas'), findsOneWidget);
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);
      expect(find.text('Vacinar animais'), findsOneWidget);
    });

    // 3. Comportamento básico — sem propriedade exibe _SemPropriedadeState
    testWidgets(
        'exibe estado sem propriedade quando nenhuma propriedade está selecionada',
        (tester) async {
      await tester.pumpWidget(
        buildScreen(propriedade: const AsyncData(null)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Nenhuma propriedade'), findsOneWidget);
      expect(
        find.text('Cadastre uma propriedade para\ngerenciar suas tarefas.'),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(BovPrimaryButton, 'Criar Propriedade'),
        findsOneWidget,
      );
    });
  });
}
