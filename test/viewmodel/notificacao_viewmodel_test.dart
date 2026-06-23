import 'package:bov_manager/services/notification_service.dart';
import 'package:bov_manager/viewmodels/notificacao_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('NotificacaoViewModel', () {
    test('build() retorna true quando nenhuma preferência existe', () async {
      SharedPreferences.setMockInitialValues({});

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = await container.read(
        notificacaoViewModelProvider.future,
      );

      expect(state, true);
    });

    test('build() retorna valor salvo em SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({
        'notificacoes_ativas': false,
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = await container.read(
        notificacaoViewModelProvider.future,
      );

      expect(state, false);
    });

    test('NotificacaoSlotsViewModel cria slots como true por padrão', () async {
      SharedPreferences.setMockInitialValues({});

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = await container.read(
        notificacaoSlotsViewModelProvider.future,
      );

      for (final slot in NotificationService.todosOsSlots) {
        expect(state[slot], true);
      }
    });

    test('NotificacaoSlotsViewModel carrega slots salvos', () async {
      SharedPreferences.setMockInitialValues({
        NotificationService.kComHorario24h: false,
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = await container.read(
        notificacaoSlotsViewModelProvider.future,
      );

      expect(
        state[NotificationService.kComHorario24h],
        false,
      );

      expect(
        state[NotificationService.kComHorario12h],
        true,
      );
    });

    test('alternarSlot altera e salva preferência do slot', () async {
      SharedPreferences.setMockInitialValues({});

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(
        notificacaoSlotsViewModelProvider.future,
      );

      await container
          .read(
            notificacaoSlotsViewModelProvider.notifier,
          )
          .alternarSlot(
            NotificationService.kComHorario24h,
          );

      final state = container.read(
        notificacaoSlotsViewModelProvider,
      );

      expect(
        state.value?[NotificationService.kComHorario24h],
        false,
      );

      final prefs = await SharedPreferences.getInstance();

      expect(
        prefs.getBool(NotificationService.kComHorario24h),
        false,
      );
    });
  });
}
