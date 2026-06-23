import 'package:bov_manager/view/tarefa_screen.dart';
import 'package:bov_manager/viewmodels/tarefa_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

// =============================================================================
// FAKE NOTIFIER
// build() é síncrono (AsyncData(null)) — sem async.
// criar() é no-op: isola a tela de qualquer dependência real de serviço.
// =============================================================================

class FakeTarefasViewModel extends TarefasViewModel {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  @override
  Future<void> criar({
    required String titulo,
    required String descricao,
    required DateTime dataExecucao,
    int? horaExecucaoMinutos,
  }) async {}
}

// =============================================================================
// TESTES
// =============================================================================

void main() {
  group('NovaTarefaScreen', () {
    // -------------------------------------------------------------------------
    // Helper centralizado.
    // -------------------------------------------------------------------------
    Widget buildScreen() {
      return ProviderScope(
        overrides: [
          tarefasViewModelProvider.overrideWith(() => FakeTarefasViewModel()),
        ],
        child: const MaterialApp(home: NovaTarefaScreen()),
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
    // Dois TextFields (título e descrição), título da tela e botões de ação.
    // -------------------------------------------------------------------------
    testWidgets('exibe título, campos de texto e botões', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      // Título do header
      expect(find.text('Nova Tarefa'), findsOneWidget);

      // Campo de título e campo de descrição
      expect(find.byType(TextField), findsNWidgets(2));

      // Botão principal e botão de cancelar
      expect(find.text('Salvar Tarefa'), findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // 3. Comportamento básico
    // O campo de data exibe a data de hoje formatada em dd/MM/yyyy ao abrir
    // a tela — confirma que _dataExecucao é inicializado com DateTime.now()
    // e que o widget de data renderiza o valor correto.
    // -------------------------------------------------------------------------
    testWidgets('campo de data exibe a data de hoje ao abrir a tela', (
      tester,
    ) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      final dataHoje = DateFormat('dd/MM/yyyy').format(DateTime.now());
      expect(find.text(dataHoje), findsOneWidget);
    });
  });
}
