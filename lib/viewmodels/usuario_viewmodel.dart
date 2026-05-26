// ==========================================
// viewmodels/usuario_viewmodel.dart
// ==========================================

import 'package:bov_manager/models/usuario_model.dart';
import 'package:bov_manager/services/usuario_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'usuario_viewmodel.g.dart';

@riverpod
class UsuarioViewModel extends _$UsuarioViewModel {
  @override
  AsyncValue<UsuarioModel?> build() {
    return const AsyncData(null);
  }

  // =========================
  // CRIAR USUÁRIO
  // =========================
  Future<void> criarUsuario({
    required String nome,
    required String email,
    required String cpf,
    required String senha,
  }) async {
    state = const AsyncLoading();

    try {
      final service = ref.read(usuarioServiceProvider);

      final usuario = await service.criarUsuario(
        nome: nome,
        email: email,
        cpf: cpf,
        senha: senha,
      );

      state = AsyncData(usuario);
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
    }
  }

  // =========================
  // LOGIN
  // =========================
  Future<void> login({required String email, required String senha}) async {
    state = const AsyncLoading();
    try {
      await ref.read(usuarioServiceProvider).login(email: email, senha: senha);
      state = const AsyncData(null); 
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  // =========================
  // LOGOUT
  // =========================
  Future<void> logout() async {
    try {
      final service = ref.read(usuarioServiceProvider);

      await service.logout();

      state = const AsyncData(null);
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
    }
  }

  // =========================
  // HELPERS DE LEITURA
  // =========================

  /// Retorna o usuário atual ou null se não autenticado.
  UsuarioModel? get usuarioAtual => state.value;

  /// True enquanto qualquer operação async está em andamento.
  bool get isLoading => state.isLoading;

  /// Mensagem do último erro, ou null se não há erro.
  String? get errorMessage => state.hasError ? state.error.toString() : null;
}
