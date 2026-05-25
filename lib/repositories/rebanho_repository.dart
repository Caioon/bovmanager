import 'package:bov_manager/models/rebanho_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// =============================================================================
// PROVIDER
// =============================================================================

final rebanhoRepositoryProvider = Provider<RebanhoRepository>((ref) {
  return RebanhoRepository(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
  );
});

// =============================================================================
// REPOSITORY
// =============================================================================

class RebanhoRepository {
  RebanhoRepository({required this.firestore, required this.auth});

  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  CollectionReference<Map<String, dynamic>> _col(String propriedadeId) =>
      firestore
          .collection('propriedades')
          .doc(propriedadeId)
          .collection('rebanhos');

  // ---------------------------------------------------------------------------
  // Stream em tempo real (usado pelo StreamProvider da lista)
  // ---------------------------------------------------------------------------
  Stream<List<RebanhoModel>> listarStream(String propriedadeId) {
    return _col(propriedadeId)
        .orderBy('dataCadastro', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => RebanhoModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  // ---------------------------------------------------------------------------
  // Busca pontual (usado pelo service para validações)
  // ---------------------------------------------------------------------------
  Future<List<RebanhoModel>> listar(String propriedadeId) async {
    final snap = await _col(propriedadeId)
        .orderBy('dataCadastro', descending: true)
        .get();
    return snap.docs
        .map((doc) => RebanhoModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  // ---------------------------------------------------------------------------
  // Criar
  // ---------------------------------------------------------------------------
  Future<void> criar(RebanhoModel rebanho) async {
    await _col(rebanho.propriedadeId).add(rebanho.toMap());
  }

  // ---------------------------------------------------------------------------
  // Mover (atualiza o pastoId)
  // ---------------------------------------------------------------------------
  Future<void> mover({
    required String propriedadeId,
    required String rebanhoId,
    required String novoPastoId,
  }) async {
    await _col(propriedadeId).doc(rebanhoId).update({'pastoId': novoPastoId});
  }

  // ---------------------------------------------------------------------------
  // Apagar
  // ---------------------------------------------------------------------------
  Future<void> apagar({
    required String propriedadeId,
    required String rebanhoId,
  }) async {
    await _col(propriedadeId).doc(rebanhoId).delete();
  }
}
