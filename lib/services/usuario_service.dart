import 'package:bov_manager/models/usuario_model.dart';
import 'package:bov_manager/repositories/usuario_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


// Service Provider
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
    // Aqui poderia existir:
    // - validação
    // - sanitização
    // - regras de negócio
    // - logs
    // - analytics
    // - verificação de CPF
    // etc

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
}
