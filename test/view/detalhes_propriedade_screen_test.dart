import 'package:bov_manager/models/animal_model.dart';
import 'package:bov_manager/models/pasto_model.dart';
import 'package:bov_manager/models/propriedade_model.dart';
import 'package:bov_manager/models/rebanho_model.dart';
import 'package:bov_manager/view/detalhes_propriedade_screen.dart';
import 'package:bov_manager/viewmodels/animal_viewmodel.dart';
import 'package:bov_manager/viewmodels/pasto_viewmodel.dart';
import 'package:bov_manager/viewmodels/propriedade_viewmodel.dart';
import 'package:bov_manager/viewmodels/rebanho_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Fakes ────────────────────────────────────────────────────────────────────

class FakePropriedadeEmVisualizacao extends PropriedadeEmVisualizacao {
  final PropriedadeModel initialValue;
  FakePropriedadeEmVisualizacao(this.initialValue);

  @override
  PropriedadeModel? build() => initialValue;

  @override
  void fechar() {}
}

class FakePropriedadesViewModel extends PropriedadesViewModel {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  @override
  Future<void> editar({
    required String propriedadeId,
    required String nome,
  }) async {}

  @override
  Future<void> apagar({required String propriedadeId}) async {}
}

// ── Testes ───────────────────────────────────────────────────────────────────

void main() {
  final propriedadeFake = PropriedadeModel(
    id: '1',
    nome: 'Fazenda Teste',
    proprietarioId: 'user-1',
    dataCadastro: DateTime(2024, 1, 1),
  );

  Widget buildScreen() {
    return ProviderScope(
      overrides: [
        propriedadeEmVisualizacaoProvider.overrideWith(
          () => FakePropriedadeEmVisualizacao(propriedadeFake),
        ),
        animaisListaPropEmVisProvider.overrideWith(
          (ref) => Stream<List<AnimalModel>>.value([]),
        ),

        pastosListaPropEmVisualizacaoProvider.overrideWith(
          (ref) async => <PastoModel>[],
        ),

        rebanhoListaProvider.overrideWith(
          (ref) => Stream<List<RebanhoModel>>.value([]),
        ),
        propriedadesViewModelProvider.overrideWith(
          () => FakePropriedadesViewModel(),
        ),
      ],
      child: const MaterialApp(home: DetalhesPropriedadeScreen()),
    );
  }

  testWidgets('DetalhesPropriedadeScreen exibe dados', (tester) async {
    await tester.pumpWidget(buildScreen());
    await tester.pump();

    // Nome aparece no header E no card de info → findsAtLeastNWidgets(1)
    expect(find.text('Fazenda Teste'), findsAtLeastNWidgets(1));
    expect(find.text('RESUMO'), findsOneWidget);
    expect(find.text('ATALHOS RÁPIDOS'), findsOneWidget);
  });

  testWidgets('DetalhesPropriedadeScreen mostra métricas', (tester) async {
    await tester.pumpWidget(buildScreen());
    await tester.pump();

    expect(find.text('Pastos'), findsAtLeastNWidgets(1));
    expect(find.text('Rebanhos'), findsAtLeastNWidgets(1));
    expect(find.text('Animais'), findsOneWidget);
    expect(find.text('Alertas'), findsOneWidget);
  });

  testWidgets('DetalhesPropriedadeScreen abre menu', (tester) async {
    addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));

    await tester.pumpWidget(buildScreen());
    await tester.pump();

    await tester.tap(find.byIcon(Icons.more_horiz_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Editar Propriedade'), findsOneWidget);
    expect(find.text('Apagar Propriedade'), findsOneWidget);
  });

  testWidgets('DetalhesPropriedadeScreen abre confirmação apagar', (
    tester,
  ) async {
    addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));

    await tester.pumpWidget(buildScreen());
    await tester.pump();

    await tester.tap(find.byIcon(Icons.more_horiz_rounded));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Apagar Propriedade'));
    await tester.pumpAndSettle();

    expect(find.text('Apagar propriedade?'), findsOneWidget);
  });
}
