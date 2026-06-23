import 'package:bov_manager/viewmodels/poligono_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PoligonoViewModel', () {
    test('build() retorna estado inicial AsyncData(null)', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(
        poligonoViewModelProvider,
      );

      expect(state, const AsyncData<void>(null));
    });
  });
}
