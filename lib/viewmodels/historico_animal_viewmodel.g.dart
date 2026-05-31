// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'historico_animal_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(historicoAnimalLista)
const historicoAnimalListaProvider = HistoricoAnimalListaProvider._();

final class HistoricoAnimalListaProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<HistoricoAnimalModel>>,
          List<HistoricoAnimalModel>,
          Stream<List<HistoricoAnimalModel>>
        >
    with
        $FutureModifier<List<HistoricoAnimalModel>>,
        $StreamProvider<List<HistoricoAnimalModel>> {
  const HistoricoAnimalListaProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'historicoAnimalListaProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$historicoAnimalListaHash();

  @$internal
  @override
  $StreamProviderElement<List<HistoricoAnimalModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<HistoricoAnimalModel>> create(Ref ref) {
    return historicoAnimalLista(ref);
  }
}

String _$historicoAnimalListaHash() =>
    r'95debf0ca8c58ac8f4aab700e757c11edd355d25';

@ProviderFor(HistoricoAnimalViewModel)
const historicoAnimalViewModelProvider = HistoricoAnimalViewModelProvider._();

final class HistoricoAnimalViewModelProvider
    extends $NotifierProvider<HistoricoAnimalViewModel, AsyncValue<void>> {
  const HistoricoAnimalViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'historicoAnimalViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$historicoAnimalViewModelHash();

  @$internal
  @override
  HistoricoAnimalViewModel create() => HistoricoAnimalViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$historicoAnimalViewModelHash() =>
    r'4ea065a07bc6e0c3d6b1b9606392c7499fec9273';

abstract class _$HistoricoAnimalViewModel extends $Notifier<AsyncValue<void>> {
  AsyncValue<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<void>, AsyncValue<void>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, AsyncValue<void>>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
