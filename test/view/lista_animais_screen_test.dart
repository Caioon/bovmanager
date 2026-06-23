import 'package:bov_manager/core/widgets/bov_widgets.dart';
import 'package:bov_manager/models/animal_model.dart';
import 'package:bov_manager/models/propriedade_model.dart';
import 'package:bov_manager/view/lista_animais_screen.dart';
import 'package:bov_manager/viewmodels/animal_viewmodel.dart';
import 'package:bov_manager/viewmodels/propriedade_viewmodel.dart';
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

final fakeAnimal = AnimalModel(
  id: 'animal-1',
  nome: 'Mimosa',
  brinco: '001',
  raca: 'Nelore',
  pesoAtual: 450,
  dataNascimento: DateTime(2021, 6, 15),
  fotoUrl: null,
  propriedadeId: 'prop-1',
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

class FakeAnimalEmVisualizacaoNotifier extends AnimalEmVisualizacao {
  @override
  AnimalModel? build() => null;

  @override
  void abrir(AnimalModel animal) {} // no-op

  @override
  void fechar() {} // no-op
}

// ── Helper ──────────────────────────────────────────────────────────────────

Widget buildScreen({
  AsyncValue<PropriedadeModel?> propriedade = const AsyncData(null),
  List<AnimalModel> animais = const [],
}) {
  return ProviderScope(
    overrides: [
      propriedadeSelecionadaProvider.overrideWith(
        () => FakePropriedadeSelecionadaNotifier(estadoInicial: propriedade),
      ),
      animaisListaProvider.overrideWith(
        (ref) => Stream.value(animais),
      ),
      animalEmVisualizacaoProvider.overrideWith(
        () => FakeAnimalEmVisualizacaoNotifier(),
      ),
    ],
    child: const MaterialApp(home: ListaAnimaisScreen()),
  );
}

// ── Testes ───────────────────────────────────────────────────────────────────

void main() {
  group('ListaAnimaisScreen', () {
    // 1. Smoke test
    testWidgets('renderiza sem crashar com propriedade e animais carregados',
        (tester) async {
      await tester.pumpWidget(
        buildScreen(
          propriedade: AsyncData(fakeProprieddade),
          animais: [fakeAnimal],
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    // 2. Widgets principais
    testWidgets('exibe título, campo de busca e botão de adicionar animal',
        (tester) async {
      await tester.pumpWidget(
        buildScreen(
          propriedade: AsyncData(fakeProprieddade),
          animais: [fakeAnimal],
        ),
      );
      await tester.pumpAndSettle();

      // Título da tela
      expect(find.text('Animais'), findsOneWidget);

      // Botão de adicionar (ícone dentro do container no header)
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);

      // Campo de busca
      expect(find.byType(BovTextField), findsOneWidget);
      expect(find.text('Buscar por brinco ou nome...'), findsOneWidget);
    });

    // 3. Comportamento básico — busca sem resultado exibe mensagem adequada
    testWidgets(
        'exibe "Nenhum animal encontrado" ao buscar termo sem correspondência',
        (tester) async {
      await tester.pumpWidget(
        buildScreen(
          propriedade: AsyncData(fakeProprieddade),
          animais: [fakeAnimal],
        ),
      );
      await tester.pumpAndSettle();

      // Digita termo que não casa com nenhum animal
      await tester.enterText(find.byType(BovTextField), 'zzznaoexiste');

      await tester.pumpAndSettle();

      expect(find.text('Nenhum animal encontrado'), findsOneWidget);
    });
  });
}
