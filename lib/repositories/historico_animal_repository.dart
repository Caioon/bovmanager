import 'package:bov_manager/models/historico_animal_model.dart';
import 'package:bov_manager/models/historico_tipo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'historico_animal_repository.g.dart';

// =============================================================================
// PROVIDER
// =============================================================================

@riverpod
HistoricoAnimalRepository historicoAnimalRepository(Ref ref) {
  return HistoricoAnimalRepositoryImpl(FirebaseFirestore.instance);
}

// =============================================================================
// INTERFACE
// =============================================================================

abstract class HistoricoAnimalRepository {
  Stream<List<HistoricoAnimalModel>> listar({required String animalId});

  Future<void> criarHistorico({
    required String animalId,
    required HistoricoTipo tipo,
    required double? novoPeso,
    String? pastoOrigemId,
    String? pastoDestinoId,
    String? rebanhoOrigemId,
    String? rebanhoDestinoId,
    required WriteBatch batch,
  });

  Future<void> apagarTodosHistoricosAnimal({
    required String animalId,
    required WriteBatch batch,
  });

  Future<HistoricoAnimalModel?> buscarUltimaMovimentacao({
    required String animalId,
  });
}

// =============================================================================
// IMPLEMENTAÇÃO FIRESTORE
// =============================================================================

class HistoricoAnimalRepositoryImpl implements HistoricoAnimalRepository {
  const HistoricoAnimalRepositoryImpl(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _col(String animalId) =>
      _firestore.collection('animais').doc(animalId).collection('historico');

  // Tipos de movimentação + entrada — usados para filtrar no Firestore
  static const _tiposMovimentacao = [
    'entrada',
    'entrar_rebanho',
    'mudar_rebanho',
    'sair_rebanho_mudar_pasto',
    'sair_rebanho_manter_pasto',
    'mudar_pasto_com_rebanho',
  ];

  @override
  Stream<List<HistoricoAnimalModel>> listar({required String animalId}) {
    return _col(animalId)
        .orderBy('data', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => HistoricoAnimalModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  @override
  Future<void> criarHistorico({
    required String animalId,
    required HistoricoTipo tipo,
    required double? novoPeso,
    String? pastoOrigemId,
    String? pastoDestinoId,
    String? rebanhoOrigemId,
    String? rebanhoDestinoId,
    required WriteBatch batch,
  }) async {
    final historicoRef = _col(animalId).doc();

    batch.set(historicoRef, {
      'animalId': animalId,
      'tipo': tipo.valor,
      'novoPeso': novoPeso,
      'pastoOrigemId': pastoOrigemId,
      'pastoDestinoId': pastoDestinoId,
      'rebanhoOrigemId': rebanhoOrigemId,
      'rebanhoDestinoId': rebanhoDestinoId,
      'data': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<void> apagarTodosHistoricosAnimal({
    required String animalId,
    required WriteBatch batch,
  }) async {
    final historicoDocs = await _col(animalId).get();
    for (final doc in historicoDocs.docs) {
      batch.delete(doc.reference);
    }
  }

  @override
  Future<HistoricoAnimalModel?> buscarUltimaMovimentacao({
    required String animalId,
  }) async {
    final snap = await _col(animalId)
        .where('tipo', whereIn: _tiposMovimentacao)
        .orderBy('data', descending: true)
        .limit(1)
        .get();

    if (snap.docs.isEmpty) return null;
    return HistoricoAnimalModel.fromMap(
      snap.docs.first.data(),
      snap.docs.first.id,
    );
  }
}
