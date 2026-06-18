// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tarefa_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(tarefaRepository)
const tarefaRepositoryProvider = TarefaRepositoryProvider._();

final class TarefaRepositoryProvider
    extends
        $FunctionalProvider<
          TarefaRepository,
          TarefaRepository,
          TarefaRepository
        >
    with $Provider<TarefaRepository> {
  const TarefaRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tarefaRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tarefaRepositoryHash();

  @$internal
  @override
  $ProviderElement<TarefaRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TarefaRepository create(Ref ref) {
    return tarefaRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TarefaRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TarefaRepository>(value),
    );
  }
}

String _$tarefaRepositoryHash() => r'71b78625e011427c5d5b7c651e71934e46f08fba';
