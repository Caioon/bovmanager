// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rebanho_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(RebanhoEmVisualizacao)
const rebanhoEmVisualizacaoProvider = RebanhoEmVisualizacaoProvider._();

final class RebanhoEmVisualizacaoProvider
    extends $NotifierProvider<RebanhoEmVisualizacao, RebanhoModel?> {
  const RebanhoEmVisualizacaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rebanhoEmVisualizacaoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rebanhoEmVisualizacaoHash();

  @$internal
  @override
  RebanhoEmVisualizacao create() => RebanhoEmVisualizacao();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RebanhoModel? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RebanhoModel?>(value),
    );
  }
}

String _$rebanhoEmVisualizacaoHash() =>
    r'77bc25e65d03d7ce5f319becd305defbda9bd974';

abstract class _$RebanhoEmVisualizacao extends $Notifier<RebanhoModel?> {
  RebanhoModel? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<RebanhoModel?, RebanhoModel?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<RebanhoModel?, RebanhoModel?>,
              RebanhoModel?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(rebanhoLista)
const rebanhoListaProvider = RebanhoListaProvider._();

final class RebanhoListaProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RebanhoModel>>,
          List<RebanhoModel>,
          Stream<List<RebanhoModel>>
        >
    with
        $FutureModifier<List<RebanhoModel>>,
        $StreamProvider<List<RebanhoModel>> {
  const RebanhoListaProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rebanhoListaProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rebanhoListaHash();

  @$internal
  @override
  $StreamProviderElement<List<RebanhoModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<RebanhoModel>> create(Ref ref) {
    return rebanhoLista(ref);
  }
}

String _$rebanhoListaHash() => r'623e24bcb48a37da337b9df1ebc1a6a417eec414';

@ProviderFor(rebanhosSelecionados)
const rebanhosSelecionadosProvider = RebanhosSelecionadosProvider._();

final class RebanhosSelecionadosProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RebanhoModel>>,
          List<RebanhoModel>,
          Stream<List<RebanhoModel>>
        >
    with
        $FutureModifier<List<RebanhoModel>>,
        $StreamProvider<List<RebanhoModel>> {
  const RebanhosSelecionadosProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rebanhosSelecionadosProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rebanhosSelecionadosHash();

  @$internal
  @override
  $StreamProviderElement<List<RebanhoModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<RebanhoModel>> create(Ref ref) {
    return rebanhosSelecionados(ref);
  }
}

String _$rebanhosSelecionadosHash() =>
    r'51d4ef66fde1a4220b445709b7d25687a1298351';

@ProviderFor(RebanhoViewModel)
const rebanhoViewModelProvider = RebanhoViewModelProvider._();

final class RebanhoViewModelProvider
    extends $AsyncNotifierProvider<RebanhoViewModel, void> {
  const RebanhoViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rebanhoViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rebanhoViewModelHash();

  @$internal
  @override
  RebanhoViewModel create() => RebanhoViewModel();
}

String _$rebanhoViewModelHash() => r'd633275028268ca2ee06bf7bb8130a3f6c7b6fbc';

abstract class _$RebanhoViewModel extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    build();
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleValue(ref, null);
  }
}
