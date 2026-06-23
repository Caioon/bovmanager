import 'package:bov_manager/models/animal_model.dart';
import 'package:bov_manager/models/rebanho_model.dart';
import 'package:bov_manager/view/detalhes_animal_screen.dart';
import 'package:bov_manager/viewmodels/animal_viewmodel.dart';
import 'package:bov_manager/viewmodels/historico_animal_viewmodel.dart';
import 'package:bov_manager/viewmodels/rebanho_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// =======================================================
// Fakes
// =======================================================

class FakeAnimalEmVisualizacaoNotifier extends AnimalEmVisualizacao {
  @override
  AnimalModel? build() {
    return AnimalModel(
      id: '1',
      propriedadeId: 'propriedade-1',
      nome: 'Mimosa',
      brinco: '123',
      raca: 'Nelore',
      pesoAtual: 450,
      dataNascimento: DateTime(2022, 1, 10),
    );
  }
}

// =======================================================
// Testes
// =======================================================

void main() {
  group('DetalhesAnimalScreen', () {
    Widget buildScreen({
      AnimalModel? animal,
      AsyncValue<List<RebanhoModel>> rebanhos = const AsyncData([]),
    }) {
      return ProviderScope(
        overrides: [
          animalEmVisualizacaoProvider.overrideWith(
            () => FakeAnimalEmVisualizacaoNotifier(),
          ),

          historicoAnimalListaProvider.overrideWith((ref) => Stream.value([])),

          rebanhoListaProvider.overrideWith(
            (ref) => Stream.value(rebanhos.value ?? []),
          ),
        ],
        child: const MaterialApp(home: DetalhesAnimalScreen()),
      );
    }

    testWidgets('Smoke test - renderiza sem crashar', (tester) async {
      await tester.pumpWidget(buildScreen());

      await tester.pump();

      expect(find.byType(DetalhesAnimalScreen), findsOneWidget);
    });

    testWidgets('Exibe dados do animal', (tester) async {
      await tester.pumpWidget(buildScreen());

      await tester.pump();

      expect(find.text('Mimosa'), findsOneWidget);

      expect(find.text('Nelore'), findsOneWidget);

      expect(find.text('#123'), findsOneWidget);
    });

    testWidgets('Exibe peso e idade', (tester) async {
      await tester.pumpWidget(buildScreen());

      await tester.pump();

      expect(find.text('450kg'), findsOneWidget);

      expect(find.text('4a'), findsOneWidget);
    });

    testWidgets('Exibe sem rebanho quando não existe histórico', (
      tester,
    ) async {
      await tester.pumpWidget(buildScreen());

      await tester.pump();

      expect(find.text('Sem rebanho'), findsOneWidget);
    });

    testWidgets('Botões principais aparecem', (tester) async {
      await tester.pumpWidget(buildScreen());

      await tester.pump();

      expect(find.text('Ver Histórico'), findsOneWidget);

      expect(find.text('Atualizar Histórico'), findsOneWidget);
    });
  });
}
