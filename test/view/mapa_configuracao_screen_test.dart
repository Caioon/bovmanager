import 'package:bov_manager/core/widgets/bov_widgets.dart';
import 'package:bov_manager/models/propriedade_model.dart';
import 'package:bov_manager/view/mapa_configuracao_screen.dart';
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
  // sem centro definido — tela inicia com coordenada padrão do Brasil
);

// ── Fake ────────────────────────────────────────────────────────────────────

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

// ── Helper ──────────────────────────────────────────────────────────────────

Widget buildScreen({AsyncValue<PropriedadeModel?> propriedade = const AsyncData(null)}) {
  return ProviderScope(
    overrides: [
      propriedadeSelecionadaProvider.overrideWith(
        () => FakePropriedadeSelecionadaNotifier(estadoInicial: propriedade),
      ),
    ],
    child: const MaterialApp(home: MapaConfiguracaoScreen()),
  );
}

// ── Testes ───────────────────────────────────────────────────────────────────

void main() {
  group('MapaConfiguracaoScreen', () {
    // 1. Smoke test
    testWidgets('renderiza sem crashar com propriedade carregada',
        (tester) async {
      await tester.pumpWidget(
        buildScreen(propriedade: AsyncData(fakeProprieddade)),
      );
      // pump sem settle: TileLayer faz requisições de rede que nunca completam
      // no ambiente de teste — pumpAndSettle entraria em loop infinito.
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    // 2. Widgets principais
    testWidgets(
        'exibe título, campos de busca, instrução de toque e botões Cancelar e Salvar',
        (tester) async {
      await tester.pumpWidget(
        buildScreen(propriedade: AsyncData(fakeProprieddade)),
      );
      await tester.pump();

      // Título
      expect(find.text('Definir Centro do Mapa'), findsOneWidget);

      // Instrução de toque no mapa
      expect(
        find.text('Toque no mapa para definir o ponto central'),
        findsOneWidget,
      );

      // Campos de busca (cidade, lat e lng)
      expect(find.byType(BovTextField), findsNWidgets(3));

      // Botões de ação
      expect(
        find.widgetWithText(BovSecondaryButton, 'Cancelar'),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(BovPrimaryButton, 'Salvar'),
        findsOneWidget,
      );
    });

    // 3. Comportamento básico — coordenadas inválidas exibem mensagem de erro
    testWidgets(
        'exibe erro de coordenadas inválidas ao buscar com campos lat/lng vazios',
        (tester) async {
      await tester.pumpWidget(
        buildScreen(propriedade: AsyncData(fakeProprieddade)),
      );
      await tester.pump();

      // Toca no botão de busca por coordenadas com campos vazios
      await tester.tap(find.byIcon(Icons.my_location_rounded));
      await tester.pump();

      expect(
        find.text('Coordenadas inválidas. Use formato: -20.123'),
        findsOneWidget,
      );
    });
  });
}
