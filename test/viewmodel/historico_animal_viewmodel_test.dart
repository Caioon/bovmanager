import 'package:bov_manager/viewmodels/historico_animal_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HistoricoAnimalViewModel', () {
    test('build() retorna estado inicial AsyncData(null)', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(
        historicoAnimalViewModelProvider,
      );

      expect(state, const AsyncData<void>(null));
    });
  });
}
