import 'package:bov_manager/core/theme/app_colors.dart';
import 'package:bov_manager/models/propriedade_model.dart';
import 'package:bov_manager/models/tarefa_model.dart';
import 'package:bov_manager/repositories/animal_repository.dart';
import 'package:bov_manager/repositories/pasto_repository.dart';
import 'package:bov_manager/repositories/rebanho_repository.dart';
import 'package:bov_manager/repositories/tarefa_repository.dart';
import 'package:bov_manager/reports/relatorio_dados.dart';
import 'package:bov_manager/reports/relatorio_pdf_service.dart';
import 'package:bov_manager/reports/relatorio_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

/// Tela de consulta e emissão do relatório de uma propriedade (RF09).
/// Recebe a propriedade aberta em Detalhes, sem alterar a seleção global do app.
class RelatorioScreen extends ConsumerStatefulWidget {
  const RelatorioScreen({super.key, required this.propriedade});

  final PropriedadeModel propriedade;

  @override
  ConsumerState<RelatorioScreen> createState() => _RelatorioScreenState();
}

class _RelatorioScreenState extends ConsumerState<RelatorioScreen> {
  late Future<RelatorioDados> _carregamento;
  bool _exportando = false;

  @override
  void initState() {
    super.initState();
    _carregamento = _buscarDados();
  }

  Future<RelatorioDados> _buscarDados() {
    final repositorio = RelatorioRepository(
      pastosRepository: ref.read(pastoRepositoryProvider),
      rebanhosRepository: ref.read(rebanhoRepositoryProvider),
      animaisRepository: ref.read(animalRepositoryProvider),
      tarefasRepository: ref.read(tarefaRepositoryProvider),
    );
    return repositorio.carregar(widget.propriedade);
  }

  void _recarregar() {
    setState(() {
      _carregamento = _buscarDados();
    });
  }

  Future<void> _compartilharPdf(RelatorioDados dados) async {
    if (_exportando) return;
    setState(() => _exportando = true);

    try {
      final bytes = await const RelatorioPdfService().gerar(dados);
      final dataArquivo = DateFormat('yyyyMMdd_HHmm').format(dados.geradoEm);
      final nomeSeguro = widget.propriedade.nome
          .trim()
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9_-]+'), '_')
          .replaceAll(RegExp(r'^_+|_+$'), '');
      final nome = 'bovmanager_${nomeSeguro.isEmpty ? 'propriedade' : nomeSeguro}_$dataArquivo.pdf';

      await SharePlus.instance.share(
        ShareParams(
          title: 'Relatório da propriedade',
          text: 'Relatório da propriedade ${widget.propriedade.nome}',
          files: [XFile.fromData(bytes, mimeType: 'application/pdf')],
          fileNameOverrides: [nome],
        ),
      );
    } catch (erro) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível gerar o relatório: $erro')),
      );
    } finally {
      if (mounted) setState(() => _exportando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.text,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Relatórios',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: 'Atualizar dados',
            onPressed: _recarregar,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: FutureBuilder<RelatorioDados>(
        future: _carregamento,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            );
          }
          if (snapshot.hasError) {
            return _EstadoVazio(
              icone: Icons.wifi_off_rounded,
              mensagem: 'Não foi possível carregar os dados desta propriedade.',
              onTentarNovamente: _recarregar,
            );
          }
          final dados = snapshot.data;
          if (dados == null) {
            return _EstadoVazio(
              icone: Icons.description_outlined,
              mensagem: 'Nenhuma informação disponível.',
              onTentarNovamente: _recarregar,
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  children: [
                    _PropriedadeHeader(dados: dados),
                    const SizedBox(height: 22),
                    const _TituloSecao('RESUMO DA PROPRIEDADE'),
                    const SizedBox(height: 10),
                    Row(children: [
                      Expanded(child: _Indicador(
                        icone: Icons.grass_rounded,
                        titulo: 'Pastos',
                        numero: dados.totalPastos.toString(),
                      )),
                      const SizedBox(width: 10),
                      Expanded(child: _Indicador(
                        icone: Icons.groups_rounded,
                        titulo: 'Rebanhos',
                        numero: dados.totalRebanhos.toString(),
                      )),
                    ]),
                    const SizedBox(height: 10),
                    Row(children: [
                      Expanded(child: _Indicador(
                        icone: Icons.pets_rounded,
                        titulo: 'Animais',
                        numero: dados.totalAnimais.toString(),
                      )),
                      const SizedBox(width: 10),
                      Expanded(child: _Indicador(
                        icone: Icons.event_note_rounded,
                        titulo: 'Tarefas',
                        numero: dados.totalTarefas.toString(),
                      )),
                    ]),
                    const SizedBox(height: 20),
                    _CartaoResumoTarefas(dados: dados),
                    const SizedBox(height: 22),
                    _SecaoPreview(
                      titulo: 'Pastos',
                      icone: Icons.grass_rounded,
                      total: dados.totalPastos,
                      itens: dados.pastos.take(5).map((p) => _LinhaResumo(
                        titulo: p.nome,
                        subtitulo: 'Área: ${NumberFormat.decimalPattern('pt_BR').format(p.area)} ha',
                      )).toList(),
                    ),
                    _SecaoPreview(
                      titulo: 'Rebanhos',
                      icone: Icons.groups_rounded,
                      total: dados.totalRebanhos,
                      itens: dados.rebanhos.take(5).map((r) => _LinhaResumo(
                        titulo: r.nome,
                        subtitulo: 'Pasto: ${dados.nomePasto(r.pastoId)}',
                      )).toList(),
                    ),
                    _SecaoPreview(
                      titulo: 'Animais',
                      icone: Icons.pets_rounded,
                      total: dados.totalAnimais,
                      itens: dados.animais.take(5).map((a) => _LinhaResumo(
                        titulo: a.nome.isEmpty ? a.brinco : a.nome,
                        subtitulo: '${a.raca} • ${NumberFormat.decimalPattern('pt_BR').format(a.pesoAtual)} kg',
                      )).toList(),
                    ),
                    _SecaoPreview(
                      titulo: 'Atividades',
                      icone: Icons.event_note_rounded,
                      total: dados.totalTarefas,
                      itens: dados.tarefas.take(5).map((t) => _LinhaResumo(
                        titulo: t.titulo,
                        subtitulo: '${DateFormat('dd/MM/yyyy').format(t.dataExecucao)} • '
                            '${t.status == StatusTarefa.concluida ? 'Concluída' : 'Pendente'}',
                      )).toList(),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'O arquivo PDF incluirá todos os registros carregados, '
                      'mesmo quando a prévia mostrar apenas os primeiros cinco.',
                      style: TextStyle(color: AppColors.text4, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: SafeArea(
                  top: false,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.onAccent,
                      minimumSize: const Size.fromHeight(54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _exportando ? null : () => _compartilharPdf(dados),
                    icon: _exportando
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.onAccent,
                            ),
                          )
                        : const Icon(Icons.picture_as_pdf_rounded),
                    label: Text(_exportando
                        ? 'Gerando relatório...' : 'Gerar e compartilhar PDF'),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PropriedadeHeader extends StatelessWidget {
  const _PropriedadeHeader({required this.dados});

  final RelatorioDados dados;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.accentBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.home_work_rounded, color: AppColors.accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(dados.propriedade.nome,
                    style: const TextStyle(color: AppColors.text,
                      fontSize: 17, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('Atualizado em ${DateFormat('dd/MM/yyyy HH:mm').format(dados.geradoEm)}',
                    style: const TextStyle(color: AppColors.text4, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      );
}

class _TituloSecao extends StatelessWidget {
  const _TituloSecao(this.titulo);
  final String titulo;

  @override
  Widget build(BuildContext context) => Text(titulo,
      style: const TextStyle(color: AppColors.text2, fontSize: 12,
          fontWeight: FontWeight.w700, letterSpacing: 1.1));
}

class _Indicador extends StatelessWidget {
  const _Indicador({required this.icone, required this.titulo, required this.numero});
  final IconData icone;
  final String titulo;
  final String numero;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icone, size: 20, color: AppColors.accent),
      const SizedBox(height: 12),
      Text(numero, style: const TextStyle(color: AppColors.text,
          fontSize: 26, fontWeight: FontWeight.w800)),
      const SizedBox(height: 2),
      Text(titulo, style: const TextStyle(color: AppColors.text4, fontSize: 12)),
    ]),
  );
}

class _CartaoResumoTarefas extends StatelessWidget {
  const _CartaoResumoTarefas({required this.dados});
  final RelatorioDados dados;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.border),
    ),
    child: Row(children: [
      const Icon(Icons.task_alt_rounded, color: AppColors.accent),
      const SizedBox(width: 10),
      Expanded(child: Text('${dados.tarefasConcluidas} concluídas',
        style: const TextStyle(color: AppColors.text,
          fontWeight: FontWeight.w600))),
      Text('${dados.tarefasPendentes} pendentes',
        style: const TextStyle(color: AppColors.text4, fontSize: 13)),
    ]),
  );
}

class _LinhaResumo {
  const _LinhaResumo({required this.titulo, required this.subtitulo});
  final String titulo;
  final String subtitulo;
}

class _SecaoPreview extends StatelessWidget {
  const _SecaoPreview({
    required this.titulo,
    required this.icone,
    required this.total,
    required this.itens,
  });
  final String titulo;
  final IconData icone;
  final int total;
  final List<_LinhaResumo> itens;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icone, color: AppColors.accent, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(titulo, style: const TextStyle(
            color: AppColors.text, fontSize: 15, fontWeight: FontWeight.w700))),
          Text('$total', style: const TextStyle(
            color: AppColors.accent, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 12),
        if (itens.isEmpty)
          const Text('Nenhum registro encontrado.',
            style: TextStyle(color: AppColors.text4, fontSize: 13))
        else
          for (final item in itens) ...[
            const Divider(height: 18, color: AppColors.border),
            Text(item.titulo, style: const TextStyle(
              color: AppColors.text, fontWeight: FontWeight.w600)),
            const SizedBox(height: 3),
            Text(item.subtitulo, style: const TextStyle(
              color: AppColors.text4, fontSize: 12)),
          ],
        if (total > itens.length) ...[
          const SizedBox(height: 12),
          Text('+ ${total - itens.length} registros no PDF',
            style: const TextStyle(color: AppColors.accent, fontSize: 12)),
        ],
      ]),
    ),
  );
}

class _EstadoVazio extends StatelessWidget {
  const _EstadoVazio({
    required this.icone,
    required this.mensagem,
    required this.onTentarNovamente,
  });
  final IconData icone;
  final String mensagem;
  final VoidCallback onTentarNovamente;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icone, color: AppColors.text4, size: 44),
        const SizedBox(height: 12),
        Text(mensagem, textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.text2)),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: onTentarNovamente,
          child: const Text('Tentar novamente'),
        ),
      ]),
    ),
  );
}
