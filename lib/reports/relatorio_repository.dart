import 'package:bov_manager/models/propriedade_model.dart';
import 'package:bov_manager/repositories/animal_repository.dart';
import 'package:bov_manager/repositories/pasto_repository.dart';
import 'package:bov_manager/repositories/rebanho_repository.dart';
import 'package:bov_manager/repositories/tarefa_repository.dart';
import 'package:bov_manager/reports/relatorio_dados.dart';

/// Utiliza somente consultas de leitura já existentes no BovManager.
/// As quatro consultas são iniciadas juntas para reduzir o tempo de espera.
class RelatorioRepository {
  const RelatorioRepository({
    required this.pastosRepository,
    required this.rebanhosRepository,
    required this.animaisRepository,
    required this.tarefasRepository,
  });

  final PastoRepository pastosRepository;
  final RebanhoRepository rebanhosRepository;
  final AnimalRepository animaisRepository;
  final TarefaRepository tarefasRepository;

  Future<RelatorioDados> carregar(PropriedadeModel propriedade) async {
    final id = propriedade.id;
    final buscaPastos = pastosRepository.listar(id);
    final buscaRebanhos = rebanhosRepository.listar(id);
    final buscaAnimais =
        animaisRepository.listarPorPropriedade(propriedadeId: id).first;
    final buscaTarefas = tarefasRepository.listar(id).first;

    final pastos = await buscaPastos;
    final rebanhos = await buscaRebanhos;
    final animais = await buscaAnimais;
    final tarefas = await buscaTarefas;

    pastos.sort((a, b) => a.nome.compareTo(b.nome));
    rebanhos.sort((a, b) => a.nome.compareTo(b.nome));
    animais.sort((a, b) => a.nome.compareTo(b.nome));
    tarefas.sort((a, b) => a.dataExecucao.compareTo(b.dataExecucao));

    return RelatorioDados(
      propriedade: propriedade,
      pastos: pastos,
      rebanhos: rebanhos,
      animais: animais,
      tarefas: tarefas,
      geradoEm: DateTime.now(),
    );
  }
}
