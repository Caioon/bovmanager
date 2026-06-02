import 'package:bov_manager/models/animal_model.dart';
import 'package:bov_manager/models/historico_animal_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'animal_repository.g.dart';

// =============================================================================
// PROVIDER
// =============================================================================

@riverpod
AnimalRepository animalRepository(Ref ref) {
  return AnimalRepositoryImpl(FirebaseFirestore.instance);
}

// =============================================================================
// INTERFACE
// =============================================================================

abstract class AnimalRepository {
  Stream<List<AnimalModel>> listarPorPropriedade({
    required String propriedadeId,
  });

  Future<String> criarAnimal({
    required String nome,
    required String brinco,
    required String raca,
    required double pesoAtual,
    required DateTime dataNascimento,
    required String propriedadeId,
    String? pastoDestinoId,
    String? fotoUrl,
    required WriteBatch batch,
  });

  Future<void> editarAnimal({
    required String animalId,
    required String nome,
    required String brinco,
    required String raca,
    String? fotoUrl,
  });

  Future<void> apagarAnimal({
    required String animalId,
    required WriteBatch batch,
  });

  Future<void> registrarPesagem({
    required String animalId,
    required double novoPeso,
    required DateTime data,
    required WriteBatch batch,
  });

  Stream<List<HistoricoAnimalModel>> listarHistorico({
    required String animalId,
  });
}

// =============================================================================
// IMPLEMENTAÇÃO FIRESTORE
// =============================================================================

class AnimalRepositoryImpl implements AnimalRepository {
  const AnimalRepositoryImpl(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('animais');

  CollectionReference<Map<String, dynamic>> _historicoCol(String animalId) =>
      _col.doc(animalId).collection('historico');

  @override
  Stream<List<AnimalModel>> listarPorPropriedade({
    required String propriedadeId,
  }) {
    // AVISO: where + orderBy obriga a indexar os campos buscados via site do firestore ou arquivo de config
    return _col
        .where('propriedadeId', isEqualTo: propriedadeId)
        .orderBy('dataNascimento', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => AnimalModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  @override
  Future<String> criarAnimal({
    required String nome,
    required String brinco,
    required String raca,
    required double pesoAtual,
    required DateTime dataNascimento,
    required String propriedadeId,
    String? pastoDestinoId,
    String? fotoUrl,
    required WriteBatch batch,
  }) async {
    // Cria o animal e captura o doc gerado para usar o id no histórico
    final docRef = _col.doc();

    batch.set(docRef, {
      'nome': nome,
      'brinco': brinco,
      'raca': raca,
      'pesoAtual': pesoAtual,
      'dataNascimento': dataNascimento.toIso8601String(),
      'propriedadeId': propriedadeId,
      'fotoUrl': fotoUrl,
    });

    return docRef.id;
  }

  @override
  Future<void> editarAnimal({
    required String animalId,
    required String nome,
    required String brinco,
    required String raca,
    String? fotoUrl,
  }) async {
    await _col.doc(animalId).update({
      'nome': nome,
      'brinco': brinco,
      'raca': raca,
      'fotoUrl': fotoUrl,
    });
  }

  @override
  Future<void> apagarAnimal({
    required String animalId,
    required WriteBatch batch,
  }) async {
    // Firestore não deleta subcoleções automaticamente ao deletar o documento pai.
    // É preciso buscar e deletar todos os docs do histórico manualmente antes.
    batch.delete(_col.doc(animalId));
  }

  @override
  Future<void> registrarPesagem({
    required String animalId,
    required double novoPeso,
    required DateTime data,
    required WriteBatch batch,
  }) async {
    batch.update(_col.doc(animalId), {'pesoAtual': novoPeso});
  }

  @override
  Stream<List<HistoricoAnimalModel>> listarHistorico({
    required String animalId,
  }) {
    return _historicoCol(animalId)
        .orderBy('data', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => HistoricoAnimalModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }
}
