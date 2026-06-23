import 'package:bov_manager/models/propriedade_model.dart';
import 'package:bov_manager/viewmodels/propriedade_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PropriedadeEmVisualizacao', () {
    test('build() inicia sem propriedade selecionada', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(
        propriedadeEmVisualizacaoProvider,
      );

      expect(state, null);
    });

    test('abrir() define a propriedade em visualização', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final propriedade = PropriedadeModel(
        id: '1',
        nome: 'Fazenda Teste',
        proprietarioId: 'user1',
        dataCadastro: DateTime(2025, 1, 1),
      );

      container
          .read(
            propriedadeEmVisualizacaoProvider.notifier,
          )
          .abrir(propriedade);

      final state = container.read(
        propriedadeEmVisualizacaoProvider,
      );

      expect(state, propriedade);
      expect(state?.id, '1');
      expect(state?.nome, 'Fazenda Teste');
    });

    test('fechar() remove a propriedade em visualização', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final propriedade = PropriedadeModel(
        id: '1',
        nome: 'Fazenda Teste',
        proprietarioId: 'user1',
        dataCadastro: DateTime(2025, 1, 1),
      );

      final notifier = container.read(
        propriedadeEmVisualizacaoProvider.notifier,
      );

      notifier.abrir(propriedade);
      notifier.fechar();

      final state = container.read(
        propriedadeEmVisualizacaoProvider,
      );

      expect(state, null);
    });
  });

  group('PropriedadeSelecionada', () {
    test('selecionar() atualiza a propriedade selecionada', () {
      final container = ProviderContainer(
        overrides: [
          propriedadesListaProvider.overrideWith(
            (ref) => Stream.value([]),
          ),
        ],
      );

      addTearDown(container.dispose);

      final propriedade = PropriedadeModel(
        id: '1',
        nome: 'Fazenda Teste',
        proprietarioId: 'user1',
        dataCadastro: DateTime(2025, 1, 1),
      );

      container
          .read(
            propriedadeSelecionadaProvider.notifier,
          )
          .selecionar(propriedade);

      final state = container.read(
        propriedadeSelecionadaProvider,
      );

      expect(state.value, propriedade);
      expect(state.value?.id, '1');
    });

    test('limpar() remove a propriedade selecionada', () {
      final container = ProviderContainer(
        overrides: [
          propriedadesListaProvider.overrideWith(
            (ref) => Stream.value([]),
          ),
        ],
      );

      addTearDown(container.dispose);

      final propriedade = PropriedadeModel(
        id: '1',
        nome: 'Fazenda Teste',
        proprietarioId: 'user1',
        dataCadastro: DateTime(2025, 1, 1),
      );

      final notifier = container.read(
        propriedadeSelecionadaProvider.notifier,
      );

      notifier.selecionar(propriedade);
      notifier.limpar();

      final state = container.read(
        propriedadeSelecionadaProvider,
      );

      expect(state.value, null);
    });
  });

  group('PropriedadesViewModel', () {
    test('build() retorna estado inicial AsyncData(null)', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(
        propriedadesViewModelProvider,
      );

      expect(state, const AsyncData<void>(null));
    });
  });
}
