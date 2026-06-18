// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tarefa_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(tarefasLista)
const tarefasListaProvider = TarefasListaProvider._();

final class TarefasListaProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TarefaModel>>,
          List<TarefaModel>,
          Stream<List<TarefaModel>>
        >
    with
        $FutureModifier<List<TarefaModel>>,
        $StreamProvider<List<TarefaModel>> {
  const TarefasListaProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tarefasListaProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tarefasListaHash();

  @$internal
  @override
  $StreamProviderElement<List<TarefaModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<TarefaModel>> create(Ref ref) {
    return tarefasLista(ref);
  }
}

String _$tarefasListaHash() => r'e0f9ba5547620cac397a1b4f05adccf9064b0ca3';

@ProviderFor(TarefasViewModel)
const tarefasViewModelProvider = TarefasViewModelProvider._();

final class TarefasViewModelProvider
    extends $NotifierProvider<TarefasViewModel, AsyncValue<void>> {
  const TarefasViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tarefasViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tarefasViewModelHash();

  @$internal
  @override
  TarefasViewModel create() => TarefasViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$tarefasViewModelHash() => r'1df2d1caa9beaa3d806638ff78e0cf9a64baa117';

abstract class _$TarefasViewModel extends $Notifier<AsyncValue<void>> {
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
