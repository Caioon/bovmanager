import 'package:bov_manager/models/propriedade_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'propriedade_repository.g.dart';

// =============================================================================
// PROVIDER
// =============================================================================

@riverpod
PropriedadeRepository propriedadeRepository(Ref ref) {
  return PropriedadeRepositoryImpl(FirebaseFirestore.instance);
}

// =============================================================================
// INTERFACE
// =============================================================================

abstract class PropriedadeRepository {
  Stream<List<PropriedadeModel>> listarPropriedades({
    required String proprietarioId,
  });

  Future<void> criarPropriedade({
    required String nome,
    required String proprietarioId,
  });

  Future<void> editarPropriedade({
    required String propriedadeId,
    required String nome,
  });

  Future<void> apagarPropriedade({required String propriedadeId});

  Future<PropriedadeModel?> buscarPorId({required String propriedadeId});

  Future<void> salvarCentro({
    required String propriedadeId,
    required double lat,
    required double lng,
  });
}

// =============================================================================
// IMPLEMENTAÇÃO FIRESTORE
// =============================================================================

class PropriedadeRepositoryImpl implements PropriedadeRepository {
  const PropriedadeRepositoryImpl(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('propriedades');

  @override
  Stream<List<PropriedadeModel>> listarPropriedades({
    required String proprietarioId,
  }) {
    //AVISO: where + orderBy obriga a indexar os campos buscados via site do firestore ou arquivo de config
    //Senão podem ocorrer bugs imprevisiveis no app
    //Quando esse tipo de bug ocorre, pra corrigir:
    //Acesse o link que aparece nos logs do flutter
    //Vá no "Indexes" e clique em "Add Index", na tabela
    //Selecione Structured Index
    //Coloque o nome da collection,a primeira propriedade ascending, e a outra descending, e salva
    return _col
        .where('proprietarioId', isEqualTo: proprietarioId)
        .orderBy('dataCadastro', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs.map((doc) {
            final data = doc.data();

            return PropriedadeModel.fromMap(data, doc.id);
          }).toList(),
        );
  }

  @override
  Future<void> criarPropriedade({
    required String nome,
    required String proprietarioId,
  }) async {
    final model = PropriedadeModel(
      id: '',
      nome: nome,
      proprietarioId: proprietarioId,
      dataCadastro: DateTime.now(),
    );

    await _col.add(model.toMap());
  }

  @override
  Future<void> editarPropriedade({
    required String propriedadeId,
    required String nome,
  }) async {
    await _col.doc(propriedadeId).update({'nome': nome});
  }

  @override
  Future<void> apagarPropriedade({required String propriedadeId}) async {
    await _col.doc(propriedadeId).delete();
  }

  @override
  Future<PropriedadeModel?> buscarPorId({
    required String propriedadeId,
  }) async {
    final doc = await _col.doc(propriedadeId).get();
    if (!doc.exists) return null;
    return PropriedadeModel.fromMap(doc.data()!, doc.id);
  }

  @override
  Future<void> salvarCentro({
    required String propriedadeId,
    required double lat,
    required double lng,
  }) async {
    await _col.doc(propriedadeId).update({
      'centroLat': lat,
      'centroLng': lng,
    });
  }
}
