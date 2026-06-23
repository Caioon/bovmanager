import 'package:bov_manager/models/pasto_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// =============================================================================
// PROVIDER
// =============================================================================

final pastoRepositoryProvider = Provider<PastoRepository>((ref) {
  return PastoRepository(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
  );
});

// =============================================================================
// REPOSITORY
// =============================================================================

class PastoRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  PastoRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : firestore = firestore ?? FirebaseFirestore.instance,
      auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> _col(String propriedadeId) =>
      firestore
          .collection('propriedades')
          .doc(propriedadeId)
          .collection('pastos');

  // ---------------------------------------------------------------------------
  // Listar — Stream (tempo real)
  // ---------------------------------------------------------------------------
  Stream<List<PastoModel>> listarStream(String propriedadeId) {
    return _col(propriedadeId)
        .orderBy('nome')
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => PastoModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // ---------------------------------------------------------------------------
  // Listar — Future (busca pontual)
  // ---------------------------------------------------------------------------
  Future<List<PastoModel>> listar(String propriedadeId) async {
    final snap = await _col(propriedadeId).orderBy('nome').get();
    return snap.docs
        .map((doc) => PastoModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  // ---------------------------------------------------------------------------
  // Criar novo pasto
  // ---------------------------------------------------------------------------
  Future<void> criar(PastoModel pasto) async {
    await _col(pasto.propriedadeId).add(pasto.toMap());
  }

  // ---------------------------------------------------------------------------
  // Apagar pasto
  // ---------------------------------------------------------------------------
  Future<void> apagar({
    required String propriedadeId,
    required String pastoId,
  }) async {
    await _col(propriedadeId).doc(pastoId).delete();
  }

  // ---------------------------------------------------------------------------
  // Editar pasto
  // ---------------------------------------------------------------------------
  Future<void> editar(PastoModel pasto) async {
    await _col(pasto.propriedadeId).doc(pasto.id).update(pasto.toMap());
  }
}
