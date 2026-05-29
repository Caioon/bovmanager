import 'package:bov_manager/services/acesso_compartilhado_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'acesso_compartilhado_viewmodel.g.dart';

// =============================================================================
// ESTADO DO MODAL DE CONVITE
// =============================================================================

enum PapelAcesso {
  administrador('administrador', 'Administrador'),
  gerente('gerente', 'Gerente'),
  espectador('espectador', 'Espectador');

  const PapelAcesso(this.valor, this.label);

  final String valor;
  final String label;
}

class ConviteState {
  final bool isLoading;
  final String? erro;
  final bool sucesso;

  const ConviteState({
    this.isLoading = false,
    this.erro,
    this.sucesso = false,
  });

  ConviteState copyWith({
    bool? isLoading,
    String? erro,
    bool? sucesso,
    bool clearErro = false,
  }) {
    return ConviteState(
      isLoading: isLoading ?? this.isLoading,
      erro: clearErro ? null : (erro ?? this.erro),
      sucesso: sucesso ?? this.sucesso,
    );
  }
}

// =============================================================================
// VIEWMODEL
// =============================================================================

@riverpod
class ConviteViewModel extends _$ConviteViewModel {
  @override
  ConviteState build() => const ConviteState();

  Future<void> enviarConvite({
    required String propriedadeId,
    required String email,
    required PapelAcesso papel,
  }) async {
    if (email.trim().isEmpty) {
      state = state.copyWith(erro: 'Informe o e-mail do usuário.');
      return;
    }

    state = state.copyWith(isLoading: true, clearErro: true);

    try {
      final service = ref.read(acessoCompartilhadoServiceProvider);

      await service.convidarPorEmail(
        propriedadeId: propriedadeId,
        email: email.trim().toLowerCase(),
        papel: papel.valor,
      );

      state = state.copyWith(isLoading: false, sucesso: true);
    } on Exception catch (e) {
      // Remove o prefixo "Exception: " se existir para exibir só a mensagem
      final mensagem = e.toString().replaceFirst('Exception: ', '');
      state = state.copyWith(isLoading: false, erro: mensagem);
    }
  }

  void resetar() {
    state = const ConviteState();
  }
}
