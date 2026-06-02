import 'package:bov_manager/models/usuario_model.dart';
import 'package:bov_manager/repositories/usuario_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final usuarioServiceProvider = Provider<UsuarioService>((ref) {
  final repository = ref.watch(usuarioRepositoryProvider);
  return UsuarioService(repository);
});

class UsuarioService {
  final UsuarioRepository _repository;

  UsuarioService(this._repository);

  // =========================
  // CRIAR USUÁRIO
  // =========================
  Future<UsuarioModel> criarUsuario({
    required String nome,
    required String email,
    required String cpf,
    required String senha,
  }) async {
    return await _repository.criarUsuario(
      nome: nome,
      email: email,
      cpf: cpf,
      senha: senha,
    );
  }

  // =========================
  // LOGIN
  // =========================
  Future<void> login({required String email, required String senha}) async {
    await _repository.login(email: email, senha: senha);
  }

  // =========================
  // LOGOUT
  // =========================
  Future<void> logout() async {
    await _repository.logout();
  }

  // =========================
  // VERIFICAR SENHA
  // =========================
  Future<void> verificarSenha(String senha) async {
    await _repository.verificarSenha(senha);
  }

  // =========================
  // ATUALIZAR NOME
  // =========================
  Future<void> atualizarNome(String novoNome) async {
    await _repository.atualizarNome(novoNome);
  }

  // =========================
  // ATUALIZAR EMAIL
  // =========================
  Future<void> atualizarEmail(String senhaAtual, String novoEmail) async {
    await _repository.atualizarEmail(senhaAtual, novoEmail);
  }

  // =========================
  // ATUALIZAR CPF
  // =========================
  Future<void> atualizarCpf(String novoCpf) async {
    await _repository.atualizarCpf(novoCpf);
  }

  // =========================
  // ATUALIZAR SENHA
  // =========================
  Future<void> atualizarSenha(String senhaAtual, String novaSenha) async {
    await _repository.atualizarSenha(senhaAtual, novaSenha);
  }
}
