// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'animal_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(animaisLista)
const animaisListaProvider = AnimaisListaProvider._();

final class AnimaisListaProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AnimalModel>>,
          List<AnimalModel>,
          Stream<List<AnimalModel>>
        >
    with
        $FutureModifier<List<AnimalModel>>,
        $StreamProvider<List<AnimalModel>> {
  const AnimaisListaProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'animaisListaProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$animaisListaHash();

  @$internal
  @override
  $StreamProviderElement<List<AnimalModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<AnimalModel>> create(Ref ref) {
    return animaisLista(ref);
  }
}

String _$animaisListaHash() => r'b1811063c8f44002b098f31970f4e80d80c57e28';

@ProviderFor(AnimalEmVisualizacao)
const animalEmVisualizacaoProvider = AnimalEmVisualizacaoProvider._();

final class AnimalEmVisualizacaoProvider
    extends $NotifierProvider<AnimalEmVisualizacao, AnimalModel?> {
  const AnimalEmVisualizacaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'animalEmVisualizacaoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$animalEmVisualizacaoHash();

  @$internal
  @override
  AnimalEmVisualizacao create() => AnimalEmVisualizacao();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AnimalModel? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AnimalModel?>(value),
    );
  }
}

String _$animalEmVisualizacaoHash() =>
    r'ad0d56c6d7f88ed253d26739c67d7263229f1eb7';

abstract class _$AnimalEmVisualizacao extends $Notifier<AnimalModel?> {
  AnimalModel? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AnimalModel?, AnimalModel?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AnimalModel?, AnimalModel?>,
              AnimalModel?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(AnimaisViewModel)
const animaisViewModelProvider = AnimaisViewModelProvider._();

final class AnimaisViewModelProvider
    extends $NotifierProvider<AnimaisViewModel, AsyncValue<void>> {
  const AnimaisViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'animaisViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$animaisViewModelHash();

  @$internal
  @override
  AnimaisViewModel create() => AnimaisViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$animaisViewModelHash() => r'1c1f5d259d222476f47ca93628471e3fc48d16bc';

abstract class _$AnimaisViewModel extends $Notifier<AsyncValue<void>> {
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
