import 'package:bov_manager/models/pasto_model.dart';
import 'package:bov_manager/repositories/pasto_repository.dart';
import 'package:bov_manager/repositories/poligono_repository.dart';
import 'package:bov_manager/repositories/rebanho_repository.dart';
import 'package:bov_manager/services/animal_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final pastoServiceProvider = Provider<PastoService>((ref) {
  return PastoService(
    ref.watch(pastoRepositoryProvider),
    ref.watch(poligonoRepositoryProvider),
    ref.watch(rebanhoRepositoryProvider),
    ref.watch(animalServiceProvider),
    FirebaseFirestore.instance,
  );
});

class PastoService {
  PastoService(
    this._repository,
    this._poligonoRepository,
    this._rebanhoRepository,
    this._animalService,
    this._firestore,
  );

  final PastoRepository _repository;
  final PoligonoRepository _poligonoRepository;
  final RebanhoRepository _rebanhoRepository;
  final AnimalService _animalService;
  final FirebaseFirestore _firestore;

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

  // ---------------------------------------------------------------------------
  // Verifica se o pasto pode ser apagado, na ordem de prioridade definida:
  // 1. Rebanhos ativos no pasto
  // 2. Animais atualmente no pasto (diretamente ou via rebanho)
  // Retorna null se não há bloqueio, ou a mensagem a exibir ao usuário.
  // ---------------------------------------------------------------------------
  Future<String?> verificarBloqueioExclusao({
    required String propriedadeId,
    required String pastoId,
  }) async {
    final rebanhos = await _rebanhoRepository.listar(propriedadeId);
    final qtdRebanhos = rebanhos.where((r) => r.pastoId == pastoId).length;
    if (qtdRebanhos > 0) {
      return 'Este pasto possui $qtdRebanhos rebanho(s) associado(s). '
          'Mova-os para outro pasto antes de apagar.';
    }

    final qtdAnimais = await _animalService.contarAnimaisPorPasto(
      propriedadeId: propriedadeId,
      pastoId: pastoId,
    );
    if (qtdAnimais > 0) {
      return 'Este pasto possui $qtdAnimais animal(is) atualmente. '
          'Mova-os antes de apagar.';
    }

    return null;
  }

  // ---------------------------------------------------------------------------
  // Indica se existe um polígono desenhado para este pasto no mapa, para que
  // a UI possa mencioná-lo no diálogo de confirmação de exclusão.
  // ---------------------------------------------------------------------------
  Future<bool> possuiPoligono({
    required String propriedadeId,
    required String pastoId,
  }) async {
    final poligono = await _poligonoRepository.buscarPorPasto(
      propriedadeId: propriedadeId,
      pastoId: pastoId,
    );
    return poligono != null;
  }

  // ---------------------------------------------------------------------------
  // Apaga o pasto e, se existir, o polígono associado a ele no mapa, na
  // mesma operação atômica (WriteBatch). Históricos que referenciam este
  // pasto NÃO são apagados — permanecem no banco com o nome salvo (Etapa 1)
  // ou com o fallback de UI quando não houver nome salvo.
  //
  // Pressupõe que verificarBloqueioExclusao já foi chamado pela UI e
  // retornou null; esta função não repete as verificações de bloqueio.
  // ---------------------------------------------------------------------------
  Future<void> apagar({
    required String propriedadeId,
    required String pastoId,
  }) async {
    if (pastoId.isEmpty || propriedadeId.isEmpty) {
      throw Exception('IDs inválidos para exclusão.');
    }

    final batch = _firestore.batch();

    await _poligonoRepository.apagarEmBatch(
      propriedadeId: propriedadeId,
      pastoId: pastoId,
      batch: batch,
    );

    _repository.apagarEmBatch(
      propriedadeId: propriedadeId,
      pastoId: pastoId,
      batch: batch,
    );

    await batch.commit();
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
