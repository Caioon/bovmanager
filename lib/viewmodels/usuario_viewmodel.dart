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
      final usuario = await ref.read(usuarioServiceProvider).criarUsuario(
            nome: nome,
            email: email,
            cpf: cpf,
            senha: senha,
          );
      state = AsyncData(usuario);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
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
      rethrow;
    }
  }

  // =========================
  // LOGOUT
  // =========================
  Future<void> logout() async {
    try {
      await ref.read(usuarioServiceProvider).logout();
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  // =========================
  // HELPERS DE LEITURA
  // =========================
  UsuarioModel? get usuarioAtual => state.value;
  bool get isLoading => state.isLoading;
  String? get errorMessage => state.hasError ? state.error.toString() : null;

  // =========================
  // VERIFICAR SENHA
  // Não altera o state — apenas valida a senha via Firebase.
  // Usado como portão antes de navegar para telas de edição.
  // =========================
  Future<void> verificarSenha(String senha) async {
    await ref.read(usuarioServiceProvider).verificarSenha(senha);
  }

  // =========================
  // ATUALIZAR NOME
  // =========================
  Future<void> atualizarNome(String novoNome) async {
    state = const AsyncLoading();
    try {
      await ref.read(usuarioServiceProvider).atualizarNome(novoNome);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  // =========================
  // ATUALIZAR EMAIL
  // =========================
  Future<void> atualizarEmail(String senhaAtual, String novoEmail) async {
    state = const AsyncLoading();
    try {
      await ref.read(usuarioServiceProvider).atualizarEmail(senhaAtual, novoEmail);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  // =========================
  // ATUALIZAR CPF
  // =========================
  Future<void> atualizarCpf(String novoCpf) async {
    state = const AsyncLoading();
    try {
      await ref.read(usuarioServiceProvider).atualizarCpf(novoCpf);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  // =========================
  // ATUALIZAR SENHA
  // =========================
  Future<void> atualizarSenha(String senhaAtual, String novaSenha) async {
    state = const AsyncLoading();
    try {
      await ref.read(usuarioServiceProvider).atualizarSenha(senhaAtual, novaSenha);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}
