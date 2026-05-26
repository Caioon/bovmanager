// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usuario_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(UsuarioViewModel)
const usuarioViewModelProvider = UsuarioViewModelProvider._();

final class UsuarioViewModelProvider
    extends $NotifierProvider<UsuarioViewModel, AsyncValue<UsuarioModel?>> {
  const UsuarioViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'usuarioViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$usuarioViewModelHash();

  @$internal
  @override
  UsuarioViewModel create() => UsuarioViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<UsuarioModel?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<UsuarioModel?>>(value),
    );
  }
}

String _$usuarioViewModelHash() => r'e857aab293c26cfb856a037827e0ecc528693df9';

abstract class _$UsuarioViewModel extends $Notifier<AsyncValue<UsuarioModel?>> {
  AsyncValue<UsuarioModel?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<UsuarioModel?>, AsyncValue<UsuarioModel?>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<UsuarioModel?>, AsyncValue<UsuarioModel?>>,
              AsyncValue<UsuarioModel?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
