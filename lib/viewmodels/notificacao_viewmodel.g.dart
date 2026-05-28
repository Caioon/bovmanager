// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notificacao_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(NotificacaoViewModel)
const notificacaoViewModelProvider = NotificacaoViewModelProvider._();

final class NotificacaoViewModelProvider
    extends $AsyncNotifierProvider<NotificacaoViewModel, bool> {
  const NotificacaoViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificacaoViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificacaoViewModelHash();

  @$internal
  @override
  NotificacaoViewModel create() => NotificacaoViewModel();
}

String _$notificacaoViewModelHash() =>
    r'0b0ebc54f3c538cf2ff2241ac2ebbe0a40c0fce8';

abstract class _$NotificacaoViewModel extends $AsyncNotifier<bool> {
  FutureOr<bool> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, bool>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Gerencia as preferências individuais de cada slot de notificação,
/// persistidas via SharedPreferences.
///
/// O estado é um [Map<String, bool>] indexado pelas constantes estáticas de
/// [NotificationService] (ex: [NotificationService.kSemHorario24h]).
///
/// Alterar um slot **não** cancela nem reagenda notificações existentes —
/// a preferência só tem efeito na próxima chamada a
/// [NotificationService.agendarNotificacaoTarefa]. Para aplicar imediatamente,
/// use [NotificacaoViewModel.alternar] (desliga e religa o toggle geral).

@ProviderFor(NotificacaoSlotsViewModel)
const notificacaoSlotsViewModelProvider = NotificacaoSlotsViewModelProvider._();

/// Gerencia as preferências individuais de cada slot de notificação,
/// persistidas via SharedPreferences.
///
/// O estado é um [Map<String, bool>] indexado pelas constantes estáticas de
/// [NotificationService] (ex: [NotificationService.kSemHorario24h]).
///
/// Alterar um slot **não** cancela nem reagenda notificações existentes —
/// a preferência só tem efeito na próxima chamada a
/// [NotificationService.agendarNotificacaoTarefa]. Para aplicar imediatamente,
/// use [NotificacaoViewModel.alternar] (desliga e religa o toggle geral).
final class NotificacaoSlotsViewModelProvider
    extends
        $AsyncNotifierProvider<NotificacaoSlotsViewModel, Map<String, bool>> {
  /// Gerencia as preferências individuais de cada slot de notificação,
  /// persistidas via SharedPreferences.
  ///
  /// O estado é um [Map<String, bool>] indexado pelas constantes estáticas de
  /// [NotificationService] (ex: [NotificationService.kSemHorario24h]).
  ///
  /// Alterar um slot **não** cancela nem reagenda notificações existentes —
  /// a preferência só tem efeito na próxima chamada a
  /// [NotificationService.agendarNotificacaoTarefa]. Para aplicar imediatamente,
  /// use [NotificacaoViewModel.alternar] (desliga e religa o toggle geral).
  const NotificacaoSlotsViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificacaoSlotsViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificacaoSlotsViewModelHash();

  @$internal
  @override
  NotificacaoSlotsViewModel create() => NotificacaoSlotsViewModel();
}

String _$notificacaoSlotsViewModelHash() =>
    r'6a95889a09d5c2b1ca801d0b5b756bd27fa869ea';

/// Gerencia as preferências individuais de cada slot de notificação,
/// persistidas via SharedPreferences.
///
/// O estado é um [Map<String, bool>] indexado pelas constantes estáticas de
/// [NotificationService] (ex: [NotificationService.kSemHorario24h]).
///
/// Alterar um slot **não** cancela nem reagenda notificações existentes —
/// a preferência só tem efeito na próxima chamada a
/// [NotificationService.agendarNotificacaoTarefa]. Para aplicar imediatamente,
/// use [NotificacaoViewModel.alternar] (desliga e religa o toggle geral).

abstract class _$NotificacaoSlotsViewModel
    extends $AsyncNotifier<Map<String, bool>> {
  FutureOr<Map<String, bool>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<Map<String, bool>>, Map<String, bool>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Map<String, bool>>, Map<String, bool>>,
              AsyncValue<Map<String, bool>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
