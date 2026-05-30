// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'poligono_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(poligonosLista)
const poligonosListaProvider = PoligonosListaProvider._();

final class PoligonosListaProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PoligonoModel>>,
          List<PoligonoModel>,
          Stream<List<PoligonoModel>>
        >
    with
        $FutureModifier<List<PoligonoModel>>,
        $StreamProvider<List<PoligonoModel>> {
  const PoligonosListaProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'poligonosListaProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$poligonosListaHash();

  @$internal
  @override
  $StreamProviderElement<List<PoligonoModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<PoligonoModel>> create(Ref ref) {
    return poligonosLista(ref);
  }
}

String _$poligonosListaHash() => r'd5fd1920ad6f7db611a205a58dab52cf57e98d5a';

@ProviderFor(PoligonoViewModel)
const poligonoViewModelProvider = PoligonoViewModelProvider._();

final class PoligonoViewModelProvider
    extends $NotifierProvider<PoligonoViewModel, AsyncValue<void>> {
  const PoligonoViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'poligonoViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$poligonoViewModelHash();

  @$internal
  @override
  PoligonoViewModel create() => PoligonoViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$poligonoViewModelHash() => r'3f11ffc54d74aa5108b9fb5dc2f4099223ba5ea6';

abstract class _$PoligonoViewModel extends $Notifier<AsyncValue<void>> {
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
