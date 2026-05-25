// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'animal_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(animalRepository)
const animalRepositoryProvider = AnimalRepositoryProvider._();

final class AnimalRepositoryProvider
    extends
        $FunctionalProvider<
          AnimalRepository,
          AnimalRepository,
          AnimalRepository
        >
    with $Provider<AnimalRepository> {
  const AnimalRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'animalRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$animalRepositoryHash();

  @$internal
  @override
  $ProviderElement<AnimalRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AnimalRepository create(Ref ref) {
    return animalRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AnimalRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AnimalRepository>(value),
    );
  }
}

String _$animalRepositoryHash() => r'94386c8f94ca8f88e5a5ad24a877a5b54a0fe02f';
