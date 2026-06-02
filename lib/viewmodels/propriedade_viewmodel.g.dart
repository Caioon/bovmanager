// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'propriedade_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(propriedadesLista)
const propriedadesListaProvider = PropriedadesListaProvider._();

final class PropriedadesListaProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PropriedadeModel>>,
          List<PropriedadeModel>,
          Stream<List<PropriedadeModel>>
        >
    with
        $FutureModifier<List<PropriedadeModel>>,
        $StreamProvider<List<PropriedadeModel>> {
  const PropriedadesListaProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'propriedadesListaProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$propriedadesListaHash();

  @$internal
  @override
  $StreamProviderElement<List<PropriedadeModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<PropriedadeModel>> create(Ref ref) {
    return propriedadesLista(ref);
  }
}

String _$propriedadesListaHash() => r'bb3a7aa1cdabef00003aa9b86ae85dbc9634479c';

@ProviderFor(PropriedadeSelecionada)
const propriedadeSelecionadaProvider = PropriedadeSelecionadaProvider._();

final class PropriedadeSelecionadaProvider
    extends
        $NotifierProvider<
          PropriedadeSelecionada,
          AsyncValue<PropriedadeModel?>
        > {
  const PropriedadeSelecionadaProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'propriedadeSelecionadaProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$propriedadeSelecionadaHash();

  @$internal
  @override
  PropriedadeSelecionada create() => PropriedadeSelecionada();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<PropriedadeModel?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<PropriedadeModel?>>(
        value,
      ),
    );
  }
}

String _$propriedadeSelecionadaHash() =>
    r'f0d10557fc0ba3e2c62dc44b4f85d3f874891ae4';

abstract class _$PropriedadeSelecionada
    extends $Notifier<AsyncValue<PropriedadeModel?>> {
  AsyncValue<PropriedadeModel?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<
              AsyncValue<PropriedadeModel?>,
              AsyncValue<PropriedadeModel?>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<PropriedadeModel?>,
                AsyncValue<PropriedadeModel?>
              >,
              AsyncValue<PropriedadeModel?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(PropriedadeEmVisualizacao)
const propriedadeEmVisualizacaoProvider = PropriedadeEmVisualizacaoProvider._();

final class PropriedadeEmVisualizacaoProvider
    extends $NotifierProvider<PropriedadeEmVisualizacao, PropriedadeModel?> {
  const PropriedadeEmVisualizacaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'propriedadeEmVisualizacaoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$propriedadeEmVisualizacaoHash();

  @$internal
  @override
  PropriedadeEmVisualizacao create() => PropriedadeEmVisualizacao();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PropriedadeModel? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PropriedadeModel?>(value),
    );
  }
}

String _$propriedadeEmVisualizacaoHash() =>
    r'72b6ae3cda570f1ab2c96e2dae6df7fd7b56a7c6';

abstract class _$PropriedadeEmVisualizacao
    extends $Notifier<PropriedadeModel?> {
  PropriedadeModel? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<PropriedadeModel?, PropriedadeModel?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PropriedadeModel?, PropriedadeModel?>,
              PropriedadeModel?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(PropriedadesViewModel)
const propriedadesViewModelProvider = PropriedadesViewModelProvider._();

final class PropriedadesViewModelProvider
    extends $NotifierProvider<PropriedadesViewModel, AsyncValue<void>> {
  const PropriedadesViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'propriedadesViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$propriedadesViewModelHash();

  @$internal
  @override
  PropriedadesViewModel create() => PropriedadesViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$propriedadesViewModelHash() =>
    r'e38c4e59c71c4c2387bed443dbc590b05a3a203b';

abstract class _$PropriedadesViewModel extends $Notifier<AsyncValue<void>> {
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
