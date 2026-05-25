import 'package:bov_manager/models/historico_animal_model.dart';
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

  Future<void> adicionar({
    required String animalId,
    required String tipo,
    required double valor,
    String? pastoOrigemId,
    String? pastoDestinoId,
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
  Future<void> adicionar({
    required String animalId,
    required String tipo,
    required double valor,
    String? pastoOrigemId,
    String? pastoDestinoId,
  }) async {
    await _col(animalId).add({
      'animalId': animalId,
      'tipo': tipo,
      'valor': valor,
      'pastoOrigemId': pastoOrigemId,
      'pastoDestinoId': pastoDestinoId,
      'data': DateTime.now().toIso8601String(),
    });
  }
}
