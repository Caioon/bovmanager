import 'package:bov_manager/models/animal_model.dart';
import 'package:bov_manager/models/pasto_model.dart';
import 'package:bov_manager/models/propriedade_model.dart';
import 'package:bov_manager/models/rebanho_model.dart';
import 'package:bov_manager/models/tarefa_model.dart';
import 'package:bov_manager/reports/relatorio_dados.dart';
import 'package:bov_manager/reports/relatorio_pdf_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final propriedade = PropriedadeModel(
    id: 'propriedade-01',
    nome: 'Fazenda Teste',
    proprietarioId: 'usuario-01',
    dataCadastro: DateTime(2026, 1, 1),
  );

  test('relatório vazio não divide por zero e mostra contadores zerados', () {
    final dados = RelatorioDados(
      propriedade: propriedade,
      pastos: [],
      rebanhos: [],
      animais: [],
      tarefas: [],
      geradoEm: DateTime(2026, 11, 13),
    );

    expect(dados.totalAnimais, 0);
    expect(dados.totalRebanhos, 0);
    expect(dados.tarefasConcluidas, 0);
    expect(dados.tarefasPendentes, 0);
    expect(dados.pesoMedio, isNull);
    expect(dados.nomePasto('indefinido'), 'Não informado');
  });

  test('gera um PDF válido para propriedade sem registros', () async {
    final dados = RelatorioDados(
      propriedade: propriedade,
      pastos: [],
      rebanhos: [],
      animais: [],
      tarefas: [],
      geradoEm: DateTime(2026, 11, 13),
    );
    final pdf = await const RelatorioPdfService().gerar(dados);
    expect(pdf.length, greaterThan(100));
    expect(String.fromCharCodes(pdf.take(4)), '%PDF');
  });

  test('calcula indicadores e identifica pasto vinculado ao rebanho', () {
    final dados = RelatorioDados(
      propriedade: propriedade,
      pastos: [
        PastoModel(
          id: 'pasto-01',
          nome: 'Pasto Norte',
          propriedadeId: propriedade.id,
          area: 10,
          descricao: '',
        ),
      ],
      rebanhos: [
        RebanhoModel(
          id: 'rebanho-01',
          nome: 'Nelore',
          pastoId: 'pasto-01',
          propriedadeId: propriedade.id,
          dataCadastro: DateTime(2026, 2, 1),
        ),
      ],
      animais: [
        AnimalModel(
          id: 'animal-01',
          nome: 'Boi 01',
          brinco: '01',
          raca: 'Nelore',
          pesoAtual: 300,
          dataNascimento: DateTime(2024, 1, 1),
          propriedadeId: propriedade.id,
        ),
        AnimalModel(
          id: 'animal-02',
          nome: 'Boi 02',
          brinco: '02',
          raca: 'Angus',
          pesoAtual: 400,
          dataNascimento: DateTime(2024, 2, 1),
          propriedadeId: propriedade.id,
        ),
      ],
      tarefas: [
        TarefaModel(
          id: 'tarefa-01',
          titulo: 'Vacinar',
          descricao: '',
          dataExecucao: DateTime(2026, 11, 20),
          status: StatusTarefa.pendente,
          propriedadeId: propriedade.id,
          usuarioId: 'usuario-01',
        ),
        TarefaModel(
          id: 'tarefa-02',
          titulo: 'Pesar',
          descricao: '',
          dataExecucao: DateTime(2026, 11, 21),
          status: StatusTarefa.concluida,
          propriedadeId: propriedade.id,
          usuarioId: 'usuario-01',
        ),
      ],
      geradoEm: DateTime(2026, 11, 13),
    );

    expect(dados.totalPastos, 1);
    expect(dados.totalRebanhos, 1);
    expect(dados.totalAnimais, 2);
    expect(dados.totalTarefas, 2);
    expect(dados.tarefasConcluidas, 1);
    expect(dados.tarefasPendentes, 1);
    expect(dados.pesoMedio, 350);
    expect(dados.nomePasto('pasto-01'), 'Pasto Norte');
  });
}
