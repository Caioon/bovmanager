// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'acesso_compartilhado_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ConviteViewModel)
const conviteViewModelProvider = ConviteViewModelProvider._();

final class ConviteViewModelProvider
    extends $NotifierProvider<ConviteViewModel, ConviteState> {
  const ConviteViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'conviteViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$conviteViewModelHash();

  @$internal
  @override
  ConviteViewModel create() => ConviteViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConviteState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConviteState>(value),
    );
  }
}

String _$conviteViewModelHash() => r'653530127efc15f8e03253bbd661c2fc57ee6662';

abstract class _$ConviteViewModel extends $Notifier<ConviteState> {
  ConviteState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<ConviteState, ConviteState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ConviteState, ConviteState>,
              ConviteState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
