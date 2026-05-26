// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pasto_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(pastosLista)
const pastosListaProvider = PastosListaProvider._();

final class PastosListaProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PastoModel>>,
          List<PastoModel>,
          Stream<List<PastoModel>>
        >
    with $FutureModifier<List<PastoModel>>, $StreamProvider<List<PastoModel>> {
  const PastosListaProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pastosListaProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pastosListaHash();

  @$internal
  @override
  $StreamProviderElement<List<PastoModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<PastoModel>> create(Ref ref) {
    return pastosLista(ref);
  }
}

String _$pastosListaHash() => r'95a94aa45086a2615c856a73ed2feffa37bb2f32';

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
    r'f4b593b98f741d1db2ec171705f8a187b6dcf602';

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

String _$pastosViewModelHash() => r'f026e17fedd89c8db313da6bb909b076c63a8268';

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
