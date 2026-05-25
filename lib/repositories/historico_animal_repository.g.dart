// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'historico_animal_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(historicoAnimalRepository)
const historicoAnimalRepositoryProvider = HistoricoAnimalRepositoryProvider._();

final class HistoricoAnimalRepositoryProvider
    extends
        $FunctionalProvider<
          HistoricoAnimalRepository,
          HistoricoAnimalRepository,
          HistoricoAnimalRepository
        >
    with $Provider<HistoricoAnimalRepository> {
  const HistoricoAnimalRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'historicoAnimalRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$historicoAnimalRepositoryHash();

  @$internal
  @override
  $ProviderElement<HistoricoAnimalRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  HistoricoAnimalRepository create(Ref ref) {
    return historicoAnimalRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HistoricoAnimalRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HistoricoAnimalRepository>(value),
    );
  }
}

String _$historicoAnimalRepositoryHash() =>
    r'f4d9d8f2ca25ba1908f4f98d8c797af246670145';
