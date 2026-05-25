// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'propriedade_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(propriedadeService)
const propriedadeServiceProvider = PropriedadeServiceProvider._();

final class PropriedadeServiceProvider
    extends
        $FunctionalProvider<
          PropriedadeService,
          PropriedadeService,
          PropriedadeService
        >
    with $Provider<PropriedadeService> {
  const PropriedadeServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'propriedadeServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$propriedadeServiceHash();

  @$internal
  @override
  $ProviderElement<PropriedadeService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PropriedadeService create(Ref ref) {
    return propriedadeService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PropriedadeService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PropriedadeService>(value),
    );
  }
}

String _$propriedadeServiceHash() =>
    r'55d8373cd887ef0b7144ac7fe3f74cd918e61325';
