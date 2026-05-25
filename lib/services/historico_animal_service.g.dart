// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'historico_animal_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(historicoAnimalService)
const historicoAnimalServiceProvider = HistoricoAnimalServiceProvider._();

final class HistoricoAnimalServiceProvider
    extends
        $FunctionalProvider<
          HistoricoAnimalService,
          HistoricoAnimalService,
          HistoricoAnimalService
        >
    with $Provider<HistoricoAnimalService> {
  const HistoricoAnimalServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'historicoAnimalServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$historicoAnimalServiceHash();

  @$internal
  @override
  $ProviderElement<HistoricoAnimalService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  HistoricoAnimalService create(Ref ref) {
    return historicoAnimalService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HistoricoAnimalService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HistoricoAnimalService>(value),
    );
  }
}

String _$historicoAnimalServiceHash() =>
    r'01079315baa35d299caf47dd24a68c13da6fc281';
