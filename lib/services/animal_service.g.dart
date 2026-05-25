// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'animal_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(animalService)
const animalServiceProvider = AnimalServiceProvider._();

final class AnimalServiceProvider
    extends $FunctionalProvider<AnimalService, AnimalService, AnimalService>
    with $Provider<AnimalService> {
  const AnimalServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'animalServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$animalServiceHash();

  @$internal
  @override
  $ProviderElement<AnimalService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AnimalService create(Ref ref) {
    return animalService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AnimalService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AnimalService>(value),
    );
  }
}

String _$animalServiceHash() => r'2522807003f969e2ed4acfe6eb886395e37db1da';
