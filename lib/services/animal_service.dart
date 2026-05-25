import 'package:bov_manager/models/animal_model.dart';
import 'package:bov_manager/repositories/animal_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'animal_service.g.dart';

@riverpod
AnimalService animalService(Ref ref) {
  return AnimalService(ref.watch(animalRepositoryProvider));
}

class AnimalService {
  const AnimalService(this._repo);

  final AnimalRepository _repo;

  Stream<List<AnimalModel>> listar(String propriedadeId) {
    return _repo.listarPorPropriedade(propriedadeId: propriedadeId);
  }

  Future<void> criar({
    required String nome,
    required String brinco,
    required String raca,
    required double pesoAtual,
    required DateTime dataNascimento,
    required String rebanhoId,
    required String propriedadeId,
    String? pastoDestinoId,
    String? fotoUrl,
  }) {
    return _repo.criarAnimal(
      nome: nome,
      brinco: brinco,
      raca: raca,
      pesoAtual: pesoAtual,
      dataNascimento: dataNascimento,
      rebanhoId: rebanhoId,
      propriedadeId: propriedadeId,
      pastoDestinoId: pastoDestinoId,
      fotoUrl: fotoUrl,
    );
  }

  Future<void> editar({
    required String animalId,
    required String nome,
    required String brinco,
    required String raca,
    required double pesoAtual,
    String? fotoUrl,
  }) {
    return _repo.editarAnimal(
      animalId: animalId,
      nome: nome,
      brinco: brinco,
      raca: raca,
      pesoAtual: pesoAtual,
      fotoUrl: fotoUrl,
    );
  }

  Future<void> apagar({required String animalId}) {
    return _repo.apagarAnimal(animalId: animalId);
  }

  Future<void> registrarPesagem({
    required String animalId,
    required double novoPeso,
    required DateTime data,
  }) {
    return _repo.registrarPesagem(
      animalId: animalId,
      novoPeso: novoPeso,
      data: data,
    );
  }

  Future<void> registrarMovimentacao({
    required String animalId,
    required String pastoOrigemId,
    required String pastoDestinoId,
    required DateTime data,
  }) {
    return _repo.registrarMovimentacao(
      animalId: animalId,
      pastoOrigemId: pastoOrigemId,
      pastoDestinoId: pastoDestinoId,
      data: data,
    );
  }
}
