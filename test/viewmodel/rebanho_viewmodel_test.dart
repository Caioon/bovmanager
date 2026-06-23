import 'package:bov_manager/models/rebanho_model.dart';
import 'package:bov_manager/viewmodels/rebanho_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RebanhoEmVisualizacao', () {
    test('build() retorna null inicialmente', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(rebanhoEmVisualizacaoProvider);

      expect(state, isNull);
    });

    test('abrir() atualiza o rebanho em visualização', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final rebanho = RebanhoModel(
        id: '1',
        nome: 'Rebanho Teste',
        pastoId: 'pasto1',
        propriedadeId: 'prop1',
        dataCadastro: DateTime(2024, 1, 1),
      );

      container.read(rebanhoEmVisualizacaoProvider.notifier).abrir(rebanho);

      final state = container.read(rebanhoEmVisualizacaoProvider);

      expect(state, rebanho);
      expect(state?.id, '1');
      expect(state?.nome, 'Rebanho Teste');
    });

    test('fechar() limpa o rebanho em visualização', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final rebanho = RebanhoModel(
        id: '1',
        nome: 'Rebanho Teste',
        pastoId: 'pasto1',
        propriedadeId: 'prop1',
        dataCadastro: DateTime(2024, 1, 1),
      );

      final notifier = container.read(rebanhoEmVisualizacaoProvider.notifier);

      notifier.abrir(rebanho);
      notifier.fechar();

      final state = container.read(rebanhoEmVisualizacaoProvider);

      expect(state, isNull);
    });
  });

  group('RebanhoViewModel', () {
    test('build() inicializa com AsyncData(null)', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(rebanhoViewModelProvider.notifier);

      expect(notifier.state, const AsyncData<void>(null));
    });
  });
}
