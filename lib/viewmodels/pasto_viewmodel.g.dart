// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pasto_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(pastosListaPropSelecionada)
const pastosListaPropSelecionadaProvider =
    PastosListaPropSelecionadaProvider._();

final class PastosListaPropSelecionadaProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PastoModel>>,
          List<PastoModel>,
          FutureOr<List<PastoModel>>
        >
    with $FutureModifier<List<PastoModel>>, $FutureProvider<List<PastoModel>> {
  const PastosListaPropSelecionadaProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pastosListaPropSelecionadaProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pastosListaPropSelecionadaHash();

  @$internal
  @override
  $FutureProviderElement<List<PastoModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PastoModel>> create(Ref ref) {
    return pastosListaPropSelecionada(ref);
  }
}

String _$pastosListaPropSelecionadaHash() =>
    r'7eb103b8da8fdb501073d42c3d344d1309106334';

@ProviderFor(pastosListaPropEmVisualizacao)
const pastosListaPropEmVisualizacaoProvider =
    PastosListaPropEmVisualizacaoProvider._();

final class PastosListaPropEmVisualizacaoProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PastoModel>>,
          List<PastoModel>,
          FutureOr<List<PastoModel>>
        >
    with $FutureModifier<List<PastoModel>>, $FutureProvider<List<PastoModel>> {
  const PastosListaPropEmVisualizacaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pastosListaPropEmVisualizacaoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pastosListaPropEmVisualizacaoHash();

  @$internal
  @override
  $FutureProviderElement<List<PastoModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PastoModel>> create(Ref ref) {
    return pastosListaPropEmVisualizacao(ref);
  }
}

String _$pastosListaPropEmVisualizacaoHash() =>
    r'd15a311a1b0daaa093ff0f73f3ab1a466e4983b2';

@ProviderFor(pastosSelecionados)
const pastosSelecionadosProvider = PastosSelecionadosProvider._();

final class PastosSelecionadosProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PastoModel>>,
          List<PastoModel>,
          Stream<List<PastoModel>>
        >
    with $FutureModifier<List<PastoModel>>, $StreamProvider<List<PastoModel>> {
  const PastosSelecionadosProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pastosSelecionadosProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pastosSelecionadosHash();

  @$internal
  @override
  $StreamProviderElement<List<PastoModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<PastoModel>> create(Ref ref) {
    return pastosSelecionados(ref);
  }
}

String _$pastosSelecionadosHash() =>
    r'27891d79bdf51447701f4b9ba680fd2cf34e2596';

@ProviderFor(PastoEmVisualizacao)
const pastoEmVisualizacaoProvider = PastoEmVisualizacaoProvider._();

final class PastoEmVisualizacaoProvider
    extends $NotifierProvider<PastoEmVisualizacao, PastoModel?> {
  const PastoEmVisualizacaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pastoEmVisualizacaoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pastoEmVisualizacaoHash();

  @$internal
  @override
  PastoEmVisualizacao create() => PastoEmVisualizacao();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PastoModel? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PastoModel?>(value),
    );
  }
}

String _$pastoEmVisualizacaoHash() =>
    r'53f32b054332c8de885ecc4a20183ae0d2e3d557';

abstract class _$PastoEmVisualizacao extends $Notifier<PastoModel?> {
  PastoModel? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<PastoModel?, PastoModel?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PastoModel?, PastoModel?>,
              PastoModel?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(PastosViewModel)
const pastosViewModelProvider = PastosViewModelProvider._();

final class PastosViewModelProvider
    extends $NotifierProvider<PastosViewModel, AsyncValue<void>> {
  const PastosViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pastosViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pastosViewModelHash();

  @$internal
  @override
  PastosViewModel create() => PastosViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$pastosViewModelHash() => r'eb01fefc48004f29258d1ae025d7d6d2352324ae';

abstract class _$PastosViewModel extends $Notifier<AsyncValue<void>> {
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
