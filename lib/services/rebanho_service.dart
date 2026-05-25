import 'package:bov_manager/models/rebanho_model.dart';
import 'package:bov_manager/repositories/rebanho_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// =============================================================================
// PROVIDER
// =============================================================================

final rebanhoServiceProvider = Provider<RebanhoService>((ref) {
  return RebanhoService(repository: ref.watch(rebanhoRepositoryProvider));
});

// =============================================================================
// SERVICE
// =============================================================================

class RebanhoService {
  RebanhoService({required this.repository});

  final RebanhoRepository repository;

  // ---------------------------------------------------------------------------
  // Listar
  // ---------------------------------------------------------------------------
  Future<List<RebanhoModel>> listar(String propriedadeId) {
    return repository.listar(propriedadeId);
  }

  // ---------------------------------------------------------------------------
  // Criar
  // ---------------------------------------------------------------------------
  Future<void> criar({
    required String nome,
    required String pastoId,
    required String propriedadeId,
  }) {
    if (nome.trim().isEmpty) {
      throw Exception('O nome do rebanho é obrigatório.');
    }
    if (pastoId.isEmpty) {
      throw Exception('Selecione um pasto para o rebanho.');
    }

    final model = RebanhoModel(
      id: '',
      nome: nome.trim(),
      pastoId: pastoId,
      propriedadeId: propriedadeId,
      dataCadastro: DateTime.now(),
    );

    return repository.criar(model);
  }

  // ---------------------------------------------------------------------------
  // Mover
  // ---------------------------------------------------------------------------
  Future<void> mover({
    required String rebanhoId,
    required String propriedadeId,
    required String novoPastoId,
  }) {
    if (novoPastoId.isEmpty) {
      throw Exception('Selecione o pasto de destino.');
    }

    return repository.mover(
      propriedadeId: propriedadeId,
      rebanhoId: rebanhoId,
      novoPastoId: novoPastoId,
    );
  }

  // ---------------------------------------------------------------------------
  // Apagar
  // ---------------------------------------------------------------------------
  Future<void> apagar({
    required String rebanhoId,
    required String propriedadeId,
  }) {
    return repository.apagar(
      propriedadeId: propriedadeId,
      rebanhoId: rebanhoId,
    );
  }
}
