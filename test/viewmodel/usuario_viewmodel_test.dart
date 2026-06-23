import 'package:bov_manager/models/usuario_model.dart';
import 'package:bov_manager/viewmodels/usuario_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UsuarioViewModel', () {
    test('build() retorna AsyncData(null)', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(usuarioViewModelProvider);

      expect(state, const AsyncData<UsuarioModel?>(null));
    });

    test('usuarioAtual retorna null no estado inicial', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final viewModel = container.read(
        usuarioViewModelProvider.notifier,
      );

      expect(viewModel.usuarioAtual, isNull);
    });

    test('isLoading retorna false no estado inicial', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final viewModel = container.read(
        usuarioViewModelProvider.notifier,
      );

      expect(viewModel.isLoading, false);
    });

    test('errorMessage retorna null no estado inicial', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final viewModel = container.read(
        usuarioViewModelProvider.notifier,
      );

      expect(viewModel.errorMessage, isNull);
    });
  });
}
