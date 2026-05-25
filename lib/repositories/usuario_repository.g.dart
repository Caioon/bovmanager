// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usuario_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(usuarioAtual)
const usuarioAtualProvider = UsuarioAtualProvider._();

final class UsuarioAtualProvider
    extends
        $FunctionalProvider<
          AsyncValue<UsuarioModel?>,
          UsuarioModel?,
          Stream<UsuarioModel?>
        >
    with $FutureModifier<UsuarioModel?>, $StreamProvider<UsuarioModel?> {
  const UsuarioAtualProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'usuarioAtualProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$usuarioAtualHash();

  @$internal
  @override
  $StreamProviderElement<UsuarioModel?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<UsuarioModel?> create(Ref ref) {
    return usuarioAtual(ref);
  }
}

String _$usuarioAtualHash() => r'1320cbd15642fcbfc3b2a9cd8ab7be026b2d18d5';

@ProviderFor(usuarioRepository)
const usuarioRepositoryProvider = UsuarioRepositoryProvider._();

final class UsuarioRepositoryProvider
    extends
        $FunctionalProvider<
          UsuarioRepository,
          UsuarioRepository,
          UsuarioRepository
        >
    with $Provider<UsuarioRepository> {
  const UsuarioRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'usuarioRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$usuarioRepositoryHash();

  @$internal
  @override
  $ProviderElement<UsuarioRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UsuarioRepository create(Ref ref) {
    return usuarioRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UsuarioRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UsuarioRepository>(value),
    );
  }
}

String _$usuarioRepositoryHash() => r'b8b3967fc56099529000dae052963e4df825c2ad';
