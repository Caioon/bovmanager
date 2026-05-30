import 'package:bov_manager/models/poligono_model.dart';
import 'package:bov_manager/repositories/poligono_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final poligonoServiceProvider = Provider<PoligonoService>((ref) {
  return PoligonoService(ref.watch(poligonoRepositoryProvider));
});

class PoligonoService {
  PoligonoService(this._repository);

  final PoligonoRepository _repository;

  Future<List<PoligonoModel>> listar(String propriedadeId) {
    return _repository.listar(propriedadeId);
  }

  Future<PoligonoModel?> buscarPorPasto({
    required String propriedadeId,
    required String pastoId,
  }) {
    return _repository.buscarPorPasto(
      propriedadeId: propriedadeId,
      pastoId: pastoId,
    );
  }

  Stream<List<PoligonoModel>> listarStream(String propriedadeId) {
    return _repository.listarStream(propriedadeId);
  }

  Future<void> salvar({
    required String propriedadeId,
    required String pastoId,
    required List<LatLngPoint> pontos,
  }) async {
    if (pontos.length < 3) {
      throw Exception('Um polígono precisa de pelo menos 3 pontos.');
    }

    final poligono = PoligonoModel(
      id: '',
      propriedadeId: propriedadeId,
      pastoId: pastoId,
      pontos: pontos,
    );

    await _repository.salvar(poligono);
  }

  Future<void> apagar({
    required String propriedadeId,
    required String pastoId,
  }) {
    return _repository.apagar(propriedadeId: propriedadeId, pastoId: pastoId);
  }
}
