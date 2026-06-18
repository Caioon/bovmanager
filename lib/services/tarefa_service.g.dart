// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tarefa_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(tarefaService)
const tarefaServiceProvider = TarefaServiceProvider._();

final class TarefaServiceProvider
    extends $FunctionalProvider<TarefaService, TarefaService, TarefaService>
    with $Provider<TarefaService> {
  const TarefaServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tarefaServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tarefaServiceHash();

  @$internal
  @override
  $ProviderElement<TarefaService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TarefaService create(Ref ref) {
    return tarefaService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TarefaService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TarefaService>(value),
    );
  }
}

String _$tarefaServiceHash() => r'ee1a095821ffaf4b8131704ccc7482301607c968';
