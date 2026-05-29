import 'package:bov_manager/models/acesso_compartilhado_model.dart';
import 'package:bov_manager/repositories/acesso_compartilhado_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final acessoCompartilhadoServiceProvider =
    Provider<AcessoCompartilhadoService>((ref) {
      final repo = ref.watch(acessoCompartilhadoRepositoryProvider);
      return AcessoCompartilhadoService(repo);
    });

class AcessoCompartilhadoService {
  final AcessoCompartilhadoRepository _repo;

  AcessoCompartilhadoService(this._repo);

  // =========================
  // LISTAR ACESSOS DO USUÁRIO
  // =========================
  Future<List<AcessoCompartilhadoModel>> listarPorUsuario(
    String usuarioId,
  ) {
    return _repo.listarPorUsuario(usuarioId);
  }

  // =========================
  // CONVIDAR POR EMAIL
  // Busca o usuário pelo email, valida a existência e cria o acesso.
  // Lança exceção com mensagem amigável se o email não for encontrado.
  // =========================
  Future<void> convidarPorEmail({
    required String propriedadeId,
    required String email,
    required String papel,
  }) async {
    final usuarioId = await _repo.buscarUsuarioIdPorEmail(email);

    if (usuarioId == null) {
      throw Exception('Email de usuário não encontrado.');
    }

    await _repo.criar(
      propriedadeId: propriedadeId,
      usuarioId: usuarioId,
      papel: papel,
    );
  }

  // =========================
  // LISTAR IDs DE PROPRIEDADES COMPARTILHADAS COM O USUÁRIO
  // =========================
  Future<List<String>> listarPropriedadeIdsCompartilhadas(
    String usuarioId,
  ) async {
    final acessos = await _repo.listarPorUsuario(usuarioId);
    return acessos.map((a) => a.propriedadeId).toList();
  }
}
