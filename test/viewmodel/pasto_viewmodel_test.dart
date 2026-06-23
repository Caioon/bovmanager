import 'package:bov_manager/models/pasto_model.dart';
import 'package:bov_manager/viewmodels/pasto_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PastoEmVisualizacao', () {
    test('build() inicia sem pasto selecionado', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(
        pastoEmVisualizacaoProvider,
      );

      expect(state, null);
    });

    test('abrir() define o pasto em visualização', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final pasto = PastoModel(
        id: '1',
        nome: 'Pasto Teste',
        propriedadeId: 'prop1',
        area: 10,
        descricao: 'Descrição',
        limiteAnimais: 20,
      );

      container
          .read(
            pastoEmVisualizacaoProvider.notifier,
          )
          .abrir(pasto);

      final state = container.read(
        pastoEmVisualizacaoProvider,
      );

      expect(state, pasto);
      expect(state?.id, '1');
      expect(state?.nome, 'Pasto Teste');
    });

    test('fechar() remove o pasto em visualização', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final pasto = PastoModel(
        id: '1',
        nome: 'Pasto Teste',
        propriedadeId: 'prop1',
        area: 10,
        descricao: 'Descrição',
        limiteAnimais: 20,
      );

      final notifier = container.read(
        pastoEmVisualizacaoProvider.notifier,
      );

      notifier.abrir(pasto);
      notifier.fechar();

      final state = container.read(
        pastoEmVisualizacaoProvider,
      );

      expect(state, null);
    });
  });

  group('PastosViewModel', () {
    test('build() retorna estado inicial AsyncData(null)', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(
        pastosViewModelProvider,
      );

      expect(state, const AsyncData<void>(null));
    });
  });
}
