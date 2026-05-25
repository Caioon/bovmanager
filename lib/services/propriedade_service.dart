import 'package:bov_manager/models/propriedade_model.dart';
import 'package:bov_manager/repositories/propriedade_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'propriedade_service.g.dart';

@riverpod
PropriedadeService propriedadeService(Ref ref) {
  final repo = ref.watch(propriedadeRepositoryProvider);
  return PropriedadeService(repo);
}

class PropriedadeService {
  final PropriedadeRepository _repo;

  PropriedadeService(this._repo);

  Stream<List<PropriedadeModel>> listar(String proprietarioId) {
    return _repo.listarPropriedades(proprietarioId: proprietarioId);
  }

  Future<void> criar({
    required String nome,
    required String proprietarioId,
  }) {
    return _repo.criarPropriedade(
      nome: nome,
      proprietarioId: proprietarioId,
    );
  }

  Future<void> editar({
    required String propriedadeId,
    required String nome,
  }) {
    return _repo.editarPropriedade(
      propriedadeId: propriedadeId, nome: nome,
    );
  }

  Future<void> apagar({
    required String propriedadeId,
  }) {
    return _repo.apagarPropriedade(
      propriedadeId: propriedadeId,
    );
  }
}
