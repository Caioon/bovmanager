import 'package:bov_manager/models/animal_model.dart';
import 'package:bov_manager/models/historico_tipo.dart';
import 'package:bov_manager/models/poligono_model.dart';
import 'package:bov_manager/models/propriedade_model.dart';
import 'package:bov_manager/models/pasto_model.dart';
import 'package:bov_manager/services/animal_service.dart';
import 'package:bov_manager/view/mapa_screen.dart';
import 'package:bov_manager/viewmodels/poligono_viewmodel.dart';
import 'package:bov_manager/viewmodels/pasto_viewmodel.dart';
import 'package:bov_manager/viewmodels/propriedade_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
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

// ── Fakes ────────────────────────────────────────────────────────────────────

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

class FakePoligonoViewModelNotifier extends PoligonoViewModel {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  @override
  Future<bool> salvar({
    required String pastoId,
    required List<LatLngPoint> pontos,
  }) async =>
      true;

  @override
  Future<void> apagar({required String pastoId}) async {}
}

// implements evita chamar o construtor de AnimalService,
// contornando o problema de null-safety nos campos finais tipados.
class FakeAnimalService implements AnimalService {
  @override
  Stream<List<AnimalModel>> listar(String propriedadeId) => Stream.value([]);

  @override
  Future<int> contarAnimaisPorPasto({
    required String propriedadeId,
    required String pastoId,
  }) =>
      Future.value(0);

  @override
  Future<void> criar({
    required String nome,
    required String brinco,
    required String raca,
    required double novoPeso,
    required DateTime dataNascimento,
    required String? rebanhoId,
    required String propriedadeId,
    String? pastoDestinoId,
    String? fotoUrl,
  }) async {}

  @override
  Future<void> editar({
    required String animalId,
    required String nome,
    required String brinco,
    required String raca,
    required double pesoAtual,
    String? fotoUrl,
  }) async {}

  @override
  Future<void> apagar({required String animalId}) async {}

  @override
  Future<void> registrarHistorico({
    required String animalId,
    required double? novoPeso,
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

// ── Helper ───────────────────────────────────────────────────────────────────

Widget buildScreen({
  AsyncValue<PropriedadeModel?> propriedade = const AsyncData(null),
  List<PastoModel> pastos = const [],
}) {
  return ProviderScope(
    overrides: [
      propriedadeSelecionadaProvider.overrideWith(
        () => FakePropriedadeSelecionadaNotifier(estadoInicial: propriedade),
      ),
      pastosListaPropSelecionadaProvider.overrideWith(
        (ref) => Future.value(pastos),
      ),
      poligonosListaProvider.overrideWith(
        (ref) => Stream.value([]),
      ),
      poligonoViewModelProvider.overrideWith(
        () => FakePoligonoViewModelNotifier(),
      ),
      animalServiceProvider.overrideWith(
        (ref) => FakeAnimalService(),
      ),
    ],
    child: const MaterialApp(home: MapaScreen()),
  );
}

// ── Testes ───────────────────────────────────────────────────────────────────

void main() {
  group('MapaScreen', () {
    // 1. Smoke test
    testWidgets('renderiza sem crashar com propriedade carregada',
        (tester) async {
      await tester.pumpWidget(
        buildScreen(propriedade: AsyncData(fakeProprieddade)),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    // 2. Widgets principais
    testWidgets('exibe título e widget do mapa', (tester) async {
      await tester.pumpWidget(
        buildScreen(propriedade: AsyncData(fakeProprieddade)),
      );
      await tester.pump();

      expect(find.text('Mapa'), findsOneWidget);
      expect(find.byType(FlutterMap), findsOneWidget);
    });

    // 3. Comportamento básico — subtítulo de desenho ausente no estado inicial
    testWidgets(
        'não exibe subtítulo de modo de desenho enquanto _modoDesenho é false',
        (tester) async {
      await tester.pumpWidget(
        buildScreen(
          propriedade: AsyncData(fakeProprieddade),
          pastos: [fakePasto],
        ),
      );
      await tester.pump();

      expect(find.textContaining('Desenhando:'), findsNothing);
    });
  });
}
