// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'propriedade_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(propriedadeRepository)
const propriedadeRepositoryProvider = PropriedadeRepositoryProvider._();

final class PropriedadeRepositoryProvider
    extends
        $FunctionalProvider<
          PropriedadeRepository,
          PropriedadeRepository,
          PropriedadeRepository
        >
    with $Provider<PropriedadeRepository> {
  const PropriedadeRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'propriedadeRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$propriedadeRepositoryHash();

  @$internal
  @override
  $ProviderElement<PropriedadeRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PropriedadeRepository create(Ref ref) {
    return propriedadeRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PropriedadeRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PropriedadeRepository>(value),
    );
  }
}

String _$propriedadeRepositoryHash() =>
    r'724010ff9b43ad0c4d9db4e787f14881241e2a14';
