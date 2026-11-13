import 'dart:typed_data';

import 'package:bov_manager/models/tarefa_model.dart';
import 'package:bov_manager/reports/relatorio_dados.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Produz PDF A4 em memória; o compartilhamento fica a cargo da interface.
class RelatorioPdfService {
  const RelatorioPdfService();

  Future<Uint8List> gerar(RelatorioDados dados) async {
    final pdf = pw.Document(
      title: 'Relatório da propriedade ${dados.propriedade.nome}',
      author: 'BovManager',
    );
    final data = DateFormat('dd/MM/yyyy HH:mm');
    final dataSimples = DateFormat('dd/MM/yyyy');
    final peso = NumberFormat.decimalPattern('pt_BR');
    final verde = PdfColor.fromHex('#167D56');
    final cinza = PdfColor.fromHex('#5F6672');
    final titulo = pw.TextStyle(
      font: pw.Font.helveticaBold(),
      fontSize: 14,
      color: verde,
    );

    pw.Widget tabela(List<String> cabecalhos, List<List<String>> linhas) {
      if (linhas.isEmpty) {
        return pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 12),
          child: pw.Text('Nenhum registro encontrado.',
              style: pw.TextStyle(color: cinza, fontSize: 10)),
        );
      }
      return pw.TableHelper.fromTextArray(
        headers: cabecalhos,
        data: linhas,
        border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
        headerDecoration: pw.BoxDecoration(color: verde),
        headerStyle: pw.TextStyle(
          font: pw.Font.helveticaBold(),
          color: PdfColors.white,
          fontSize: 9,
        ),
        cellStyle: const pw.TextStyle(fontSize: 9),
        cellPadding: const pw.EdgeInsets.all(6),
        headerPadding: const pw.EdgeInsets.all(7),
        oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
      );
    }

    pw.Widget secao(String nome) => pw.Padding(
      padding: const pw.EdgeInsets.only(top: 16, bottom: 8),
      child: pw.Text(nome, style: titulo),
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        maxPages: 200,
        header: (_) => pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 12),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('BOVMANAGER', style: pw.TextStyle(
                font: pw.Font.helveticaBold(), fontSize: 11, color: verde)),
              pw.Text('Gestão Pecuária',
                  style: pw.TextStyle(fontSize: 9, color: cinza)),
            ],
          ),
        ),
        footer: (ctx) => pw.Container(
          padding: const pw.EdgeInsets.only(top: 8),
          decoration: const pw.BoxDecoration(
            border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300)),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Gerado pelo BovManager',
                  style: pw.TextStyle(fontSize: 8, color: cinza)),
              pw.Text('Página ${ctx.pageNumber} de ${ctx.pagesCount}',
                  style: pw.TextStyle(fontSize: 8, color: cinza)),
            ],
          ),
        ),
        build: (_) => [
          pw.Text('Relatório da propriedade', style: pw.TextStyle(
            font: pw.Font.helveticaBold(), fontSize: 21)),
          pw.SizedBox(height: 4),
          pw.Text(dados.propriedade.nome,
              style: pw.TextStyle(fontSize: 15, color: verde)),
          pw.SizedBox(height: 6),
          pw.Text('Emitido em ${data.format(dados.geradoEm)}',
              style: pw.TextStyle(fontSize: 9, color: cinza)),
          secao('Resumo geral'),
          tabela(['Indicador', 'Total'], [
            ['Pastos', '${dados.totalPastos}'],
            ['Rebanhos', '${dados.totalRebanhos}'],
            ['Animais', '${dados.totalAnimais}'],
            ['Tarefas agendadas', '${dados.totalTarefas}'],
            ['Tarefas pendentes', '${dados.tarefasPendentes}'],
            ['Tarefas concluídas', '${dados.tarefasConcluidas}'],
            ['Peso médio dos animais', dados.pesoMedio == null
                ? 'Sem dados' : '${peso.format(dados.pesoMedio!)} kg'],
          ]),
          secao('Pastos'),
          tabela(['Pasto', 'Área (ha)', 'Capacidade'], [
            for (final pasto in dados.pastos)
              [pasto.nome, peso.format(pasto.area),
                pasto.limiteAnimais?.toString() ?? 'Não informada'],
          ]),
          secao('Rebanhos'),
          tabela(['Rebanho', 'Pasto vinculado'], [
            for (final rebanho in dados.rebanhos)
              [rebanho.nome, dados.nomePasto(rebanho.pastoId)],
          ]),
          secao('Animais'),
          tabela(['Identificação', 'Brinco', 'Raça', 'Peso atual'], [
            for (final animal in dados.animais)
              [animal.nome.isEmpty ? 'Sem nome' : animal.nome,
                animal.brinco.isEmpty ? '-' : animal.brinco,
                animal.raca.isEmpty ? '-' : animal.raca,
                '${peso.format(animal.pesoAtual)} kg'],
          ]),
          secao('Atividades da propriedade'),
          tabela(['Tarefa', 'Data', 'Status'], [
            for (final tarefa in dados.tarefas)
              [tarefa.titulo,
                dataSimples.format(tarefa.dataExecucao),
                tarefa.status == StatusTarefa.concluida
                    ? 'Concluída' : 'Pendente'],
          ]),
          pw.SizedBox(height: 16),
          pw.Text(
            'Informações consultadas no momento da emissão. '
            'O documento apresenta somente os registros disponíveis na propriedade selecionada.',
            style: pw.TextStyle(fontSize: 9, color: cinza),
          ),
        ],
      ),
    );

    return pdf.save();
  }
}
