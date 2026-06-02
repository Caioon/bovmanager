import 'package:bov_manager/models/pasto_model.dart';
import 'package:bov_manager/repositories/pasto_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final pastoServiceProvider = Provider<PastoService>((ref) {
  return PastoService(ref.watch(pastoRepositoryProvider));
});

class PastoService {
  PastoService(this._repository);

  final PastoRepository _repository;

  Stream<List<PastoModel>> listarStream(String propriedadeId) {
    if (propriedadeId.isEmpty) {
      throw Exception('ID da propriedade inválido.');
    }
    return _repository.listarStream(propriedadeId);
  }

  Future<List<PastoModel>> listar(String propriedadeId) async {
    if (propriedadeId.isEmpty) {
      throw Exception('ID da propriedade inválido.');
    }
    return _repository.listar(propriedadeId);
  }

  Future<void> criar({
    required String nome,
    required String propriedadeId,
    required double area,
    required String descricao,
    int? limiteAnimais,
  }) async {
    if (nome.trim().isEmpty) {
      throw Exception('O nome do pasto não pode ser vazio.');
    }
    if (propriedadeId.isEmpty) {
      throw Exception('ID da propriedade inválido.');
    }
    if (area < 0) {
      throw Exception('A área não pode ser negativa.');
    }

    final pasto = PastoModel(
      id: '',
      nome: nome.trim(),
      propriedadeId: propriedadeId,
      area: area,
      descricao: descricao.trim(),
      limiteAnimais: limiteAnimais,
    );

    await _repository.criar(pasto);
  }

  Future<void> apagar({
    required String propriedadeId,
    required String pastoId,
  }) async {
    if (pastoId.isEmpty || propriedadeId.isEmpty) {
      throw Exception('IDs inválidos para exclusão.');
    }
    await _repository.apagar(propriedadeId: propriedadeId, pastoId: pastoId);
  }

  Future<void> editar({
    required String id,
    required String nome,
    required String propriedadeId,
    required double area,
    required String descricao,
    int? limiteAnimais,
  }) async {
    if (nome.trim().isEmpty) {
      throw Exception('O nome do pasto não pode ser vazio.');
    }

    final pasto = PastoModel(
      id: id,
      nome: nome.trim(),
      propriedadeId: propriedadeId,
      area: area,
      descricao: descricao.trim(),
      limiteAnimais: limiteAnimais,
    );

    await _repository.editar(pasto);
  }
}
