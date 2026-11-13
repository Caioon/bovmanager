import 'package:bov_manager/core/theme/app_colors.dart';
import 'package:bov_manager/core/widgets/bov_widgets.dart';
import 'package:bov_manager/models/historico_animal_model.dart';
import 'package:bov_manager/models/historico_tipo.dart';
import 'package:bov_manager/models/pasto_model.dart';
import 'package:bov_manager/models/rebanho_model.dart';
import 'package:bov_manager/repositories/rebanho_repository.dart';
import 'package:bov_manager/services/pasto_service.dart';
import 'package:bov_manager/viewmodels/animal_viewmodel.dart';
import 'package:bov_manager/viewmodels/historico_animal_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class HistoricoAnimalScreen extends ConsumerWidget {
  const HistoricoAnimalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animal = ref.watch(animalEmVisualizacaoProvider);
    final historicoState = ref.watch(historicoAnimalListaProvider);

    final titulo = animal != null
        ? 'Histórico — ${animal.nome.isNotEmpty ? animal.nome : '#${animal.brinco}'}'
        : 'Histórico';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  BovBackButton(),
                  Expanded(
                    child: Center(
                      child: Text(
                        titulo,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.text,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'DM Sans',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 36),
                ],
              ),
            ),

            // ── Corpo ─────────────────────────────────────────────────────
            Expanded(
              child: historicoState.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.accent),
                ),
                error: (e, _) => Center(
                  child: Text(
                    e.toString(),
                    style: const TextStyle(
                      color: AppColors.red,
                      fontFamily: 'DM Sans',
                    ),
                  ),
                ),
                data: (historico) {
                  if (animal == null || historico.isEmpty) {
                    return const _EmptyState();
                  }

                  // 'entrada' é incluída nas pesagens para servir de base
                  // na comparação de ganho de peso.
                  // A lista já vem ordenada por data desc (mais recente primeiro).
                  final pesagens = historico
                      .where(
                        (h) =>
                            h.tipo.categoria == HistoricoCategoria.pesagem ||
                            h.tipo.categoria == HistoricoCategoria.entrada,
                      )
                      .toList();

                  final movimentacoes = historico
                      .where(
                        (h) =>
                            h.tipo.categoria ==
                                HistoricoCategoria.movimentacao ||
                            h.tipo.categoria == HistoricoCategoria.entrada,
                      )
                      .toList();

                  final outros = historico
                      .where(
                        (h) =>
                            h.tipo.categoria != HistoricoCategoria.pesagem &&
                            h.tipo.categoria !=
                                HistoricoCategoria.movimentacao &&
                            h.tipo.categoria != HistoricoCategoria.entrada,
                      )
                      .toList();

                  final propriedadeId = animal.propriedadeId;

                  return _HistoricoBody(
                    pesagens: pesagens,
                    movimentacoes: movimentacoes,
                    outros: outros,
                    propriedadeId: propriedadeId,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// CORPO PRINCIPAL — separa o FutureBuilder do resto do build
// =============================================================================

/// Listas "vivas" de pasto e rebanho da propriedade, usadas apenas para
/// checar existência (o histórico já guarda os nomes em si).
class _HistoricoRefs {
  const _HistoricoRefs(this.pastos, this.rebanhos);
  final List<PastoModel> pastos;
  final List<RebanhoModel> rebanhos;
}

PastoModel? _buscarPasto(List<PastoModel> pastos, String? id) {
  if (id == null) return null;
  for (final p in pastos) {
    if (p.id == id) return p;
  }
  return null;
}

RebanhoModel? _buscarRebanho(List<RebanhoModel> rebanhos, String? id) {
  if (id == null) return null;
  for (final r in rebanhos) {
    if (r.id == id) return r;
  }
  return null;
}

/// Resolve o texto a exibir pra um pasto ou rebanho salvo no histórico.
/// O nome em si NUNCA precisa ser buscado — já vem gravado no registro.
/// Isso só decide entre 3 estados: sem vínculo ("Nenhum"), vínculo existente
/// (nome salvo) ou vínculo apagado (aviso de não encontrado).
_NomeResolvido _resolverNome({
  required String? id,
  required String? nomeSalvo,
  required bool existeNoBanco,
  required String labelApagado,
}) {
  if (id == null) return const _NomeResolvido('Nenhum', false);
  return existeNoBanco
      ? _NomeResolvido(nomeSalvo ?? '', false)
      : _NomeResolvido(
          nomeSalvo != null && nomeSalvo.trim().isNotEmpty
              ? '$nomeSalvo (apagado ou não encontrado no banco)'
              : '$labelApagado apagado ou não encontrado no banco',
          true,
        );
}

class _HistoricoBody extends ConsumerStatefulWidget {
  const _HistoricoBody({
    required this.pesagens,
    required this.movimentacoes,
    required this.outros,
    required this.propriedadeId,
  });

  final List<HistoricoAnimalModel> pesagens;
  final List<HistoricoAnimalModel> movimentacoes;
  final List<HistoricoAnimalModel> outros;
  final String propriedadeId;

  @override
  ConsumerState<_HistoricoBody> createState() => _HistoricoBodyState();
}

class _HistoricoBodyState extends ConsumerState<_HistoricoBody> {
  late Future<_HistoricoRefs> _refsFuture;

  @override
  void initState() {
    super.initState();
    _refsFuture = _carregarRefs();
  }

  // Carrega as listas "vivas" de pasto e rebanho da propriedade, usadas
  // apenas para checar se o pasto/rebanho registrado no histórico ainda
  // existe no banco (e, se existir, exibir seus detalhes atuais no modal).
  // O nome exibido no histórico em si NUNCA depende dessa busca — ele já
  // vem gravado no próprio registro (nomePastoOrigem, nomePastoDestino,
  // nomeRebanhoOrigem, nomeRebanhoDestino).
  //
  // IMPORTANTE: buscamos direto pelo widget.propriedadeId (o mesmo usado
  // pra montar o histórico), em vez dos providers "…EmVisualizacao"/
  // "rebanhoLista", que dependem de um estado global separado
  // (propriedadeEmVisualizacaoProvider) — se essa tela for aberta sem
  // aquele estado ter sido setado antes, esses providers voltam vazios
  // mesmo com os dados existindo no banco.
  Future<_HistoricoRefs> _carregarRefs() async {
    if (widget.movimentacoes.isEmpty || widget.propriedadeId.isEmpty) {
      return const _HistoricoRefs([], []);
    }
    try {
      final resultados = await Future.wait([
        ref.read(pastoServiceProvider).listar(widget.propriedadeId),
        ref
            .read(rebanhoRepositoryProvider)
            .listarStream(widget.propriedadeId)
            .first,
      ]);
      return _HistoricoRefs(
        resultados[0] as List<PastoModel>,
        resultados[1] as List<RebanhoModel>,
      );
    } catch (e, st) {
      // Antes esse erro era engolido silenciosamente, o que mascarava
      // problemas reais (permissão, índice faltando, etc). Agora ao menos
      // fica no log — a tela continua funcionando com fallback vazio.
      debugPrint('Erro ao carregar pastos/rebanhos do histórico: $e\n$st');
      return const _HistoricoRefs([], []);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Peso atual ──────────────────────────────────────────────────
          if (widget.pesagens.isNotEmpty) ...[
            const _SectionTitle(title: 'EVOLUÇÃO DE PESO'),
            _PesoCard(pesagens: widget.pesagens),
            const SizedBox(height: 4),
          ],

          // ── Movimentações ────────────────────────────────────────────────
          if (widget.movimentacoes.isNotEmpty) ...[
            const _SectionTitle(title: 'MOVIMENTAÇÕES'),
            FutureBuilder<_HistoricoRefs>(
              future: _refsFuture,
              builder: (context, snapshot) {
                final refs = snapshot.data ?? const _HistoricoRefs([], []);

                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: widget.movimentacoes
                        .asMap()
                        .entries
                        .map(
                          (e) => _MovimentacaoItem(
                            historico: e.value,
                            isFirst: e.key == 0,
                            isLast: e.key == widget.movimentacoes.length - 1,
                            pastos: refs.pastos,
                            rebanhos: refs.rebanhos,
                          ),
                        )
                        .toList(),
                  ),
                );
              },
            ),
          ],

          // ── Outros eventos ───────────────────────────────────────────────
          if (widget.outros.isNotEmpty) ...[
            const _SectionTitle(title: 'OUTROS EVENTOS'),
            Container(
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: widget.outros
                    .asMap()
                    .entries
                    .map(
                      (e) => _EventoItem(
                        historico: e.value,
                        isFirst: e.key == 0,
                        isLast: e.key == widget.outros.length - 1,
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// =============================================================================
// CARD DE PESO
// =============================================================================

class _PesoCard extends StatelessWidget {
  const _PesoCard({required this.pesagens});

  final List<HistoricoAnimalModel> pesagens;

  @override
  Widget build(BuildContext context) {
    if (pesagens.isEmpty) {
      return SizedBox.shrink();
    }
    final pesoMaisRecente = pesagens.first.novoPeso;
    final pesoInicial = pesagens.last.novoPeso;

    final ganho = pesoMaisRecente! - pesoInicial!;
    final ganhoStr = ganho >= 0
        ? '+${ganho.toStringAsFixed(0)}'
        : ganho.toStringAsFixed(0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${pesoMaisRecente.toStringAsFixed(0)} kg',
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'DM Sans',
                    ),
                  ),
                  const Text(
                    'Peso atual',
                    style: TextStyle(
                      color: AppColors.text4,
                      fontSize: 11,
                      fontFamily: 'DM Sans',
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$ganhoStr kg',
                    style: TextStyle(
                      color: ganho >= 0 ? AppColors.accent : AppColors.red,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'DM Sans',
                    ),
                  ),
                  const Text(
                    'desde o início',
                    style: TextStyle(
                      color: AppColors.text4,
                      fontSize: 11,
                      fontFamily: 'DM Sans',
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _GraficoPeso(pesagens: pesagens),
        ],
      ),
    );
  }
}

class _GraficoPeso extends StatelessWidget {
  const _GraficoPeso({required this.pesagens});

  final List<HistoricoAnimalModel> pesagens;

  @override
  Widget build(BuildContext context) {
    // pesagens vem em ordem decrescente (mais recente primeiro). Precisamos
    // da ordem cronológica (mais antiga primeiro) pra tudo — exibição e
    // cálculo de "anterior" — daí o .reversed aplicado uma única vez aqui,
    // sobre a lista inteira, ANTES de qualquer corte.
    final cronologico = pesagens.reversed.toList();

    // Até 7 pontos: mostra tudo. Mais que 7: mostra a primeira pesagem que
    // o animal já teve + as últimas 6, com um salto (···) entre elas.
    final temGap = cronologico.length > 7;
    final indices = temGap
        ? [
            0,
            for (var i = cronologico.length - 6; i < cronologico.length; i++) i,
          ]
        : List<int>.generate(cronologico.length, (i) => i);
    final pontos = indices.map((i) => cronologico[i]).toList();

    final maxPeso = pontos
        .map((p) => p.novoPeso)
        .reduce((a, b) => a! > b! ? a : b);

    final barras = <Widget>[];
    for (var k = 0; k < pontos.length; k++) {
      final ponto = pontos[k];
      final idxReal = indices[k];
      final isLast = k == pontos.length - 1;
      final altura = maxPeso! > 0 ? ponto.novoPeso! / maxPeso : 0.0;
      final mes = DateFormat(
        'dd/MMM',
        'pt_BR',
      ).format(ponto.data).toLowerCase();
      // O "anterior" usado no modal é o registro cronologicamente anterior
      // de verdade (na lista completa), mesmo que ele não apareça no
      // gráfico por causa do salto — a comparação de peso continua correta.
      final anterior = idxReal > 0 ? cronologico[idxReal - 1] : null;

      // Perdeu peso em relação ao registro anterior -> barra fica vermelha.
      final perdeuPeso =
          anterior != null && anterior.novoPeso! > ponto.novoPeso!;
      final corBarra = perdeuPeso
          ? AppColors.red.withValues(alpha: 0.35)
          : (isLast ? AppColors.accent : AppColors.accentBg);
      final corTexto = perdeuPeso
          ? AppColors.red.withValues(alpha: 0.7)
          : (isLast ? AppColors.accent : AppColors.text4);

      barras.add(
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showPesoComparativoModal(
                  context: context,
                  atual: ponto,
                  anterior: anterior,
                ),
                borderRadius: BorderRadius.circular(4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Valor do peso, exibido acima da barra.
                    Text(
                      "${ponto.novoPeso!.toStringAsFixed(0)} kg",
                      style: TextStyle(
                        color: corTexto,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'DM Sans',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: FractionallySizedBox(
                          heightFactor: altura.clamp(0.1, 1.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: corBarra,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      mes,
                      style: TextStyle(
                        color: corTexto,
                        fontSize: 10,
                        fontFamily: 'DM Sans',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      // Reticências logo após o primeiro ponto, só quando há salto.
      if (temGap && k == 0) {
        barras.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Text(
              '···',
              style: TextStyle(
                color: AppColors.text4,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontFamily: 'DM Sans',
              ),
            ),
          ),
        );
      }
    }

    return SizedBox(
      height: 96,
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: barras),
    );
  }
}

// =============================================================================
// ITEM DE MOVIMENTAÇÃO
// =============================================================================

class _MovimentacaoItem extends StatelessWidget {
  const _MovimentacaoItem({
    required this.historico,
    required this.isFirst,
    required this.isLast,
    required this.pastos,
    required this.rebanhos,
  });

  final HistoricoAnimalModel historico;
  final bool isFirst;
  final bool isLast;
  final List<PastoModel> pastos;
  final List<RebanhoModel> rebanhos;

  @override
  Widget build(BuildContext context) {
    final isEntrada = historico.tipo == HistoricoTipo.entrada;

    // Busca cada model uma única vez — reaproveitado tanto pra resolver o
    // texto exibido quanto pros detalhes mostrados dentro do modal.
    final pastoOrigemModel = _buscarPasto(pastos, historico.pastoOrigemId);
    final pastoDestinoModel = _buscarPasto(pastos, historico.pastoDestinoId);
    final rebanhoOrigemModel = _buscarRebanho(
      rebanhos,
      historico.rebanhoOrigemId,
    );
    final rebanhoDestinoModel = _buscarRebanho(
      rebanhos,
      historico.rebanhoDestinoId,
    );

    final pastoOrigem = _resolverNome(
      id: historico.pastoOrigemId,
      nomeSalvo: historico.nomePastoOrigem,
      existeNoBanco: pastoOrigemModel != null,
      labelApagado: 'Pasto',
    );
    final pastoDestino = _resolverNome(
      id: historico.pastoDestinoId,
      nomeSalvo: historico.nomePastoDestino,
      existeNoBanco: pastoDestinoModel != null,
      labelApagado: 'Pasto',
    );

    final temRebanho =
        historico.rebanhoOrigemId != null || historico.rebanhoDestinoId != null;
    final rebanhoOrigem = _resolverNome(
      id: historico.rebanhoOrigemId,
      nomeSalvo: historico.nomeRebanhoOrigem,
      existeNoBanco: rebanhoOrigemModel != null,
      labelApagado: 'Rebanho',
    );
    final rebanhoDestino = _resolverNome(
      id: historico.rebanhoDestinoId,
      nomeSalvo: historico.nomeRebanhoDestino,
      existeNoBanco: rebanhoDestinoModel != null,
      labelApagado: 'Rebanho',
    );

    // O card só é tocável se pelo menos um dos dois lados (origem/destino)
    // ainda existir no banco — senão não há nada pra mostrar em detalhe.
    final pastoAcessivel = !pastoOrigem.isFallback || !pastoDestino.isFallback;
    final rebanhoAcessivel =
        !rebanhoOrigem.isFallback || !rebanhoDestino.isFallback;

    final data = DateFormat('dd MMM yyyy').format(historico.data);

    return Container(
      padding: EdgeInsets.fromLTRB(16, isFirst ? 14 : 10, 16, isLast ? 14 : 10),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Ícone + título do registro, lado a lado ──────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isEntrada ? Icons.login_rounded : Icons.arrow_forward_rounded,
                  color: AppColors.text4,
                  size: 14,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Registro: ${historico.tipo.label}',
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'DM Sans',
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ── Colunas de pasto/rebanho, ocupando toda a largura do bloco ──
          _CaixaTocavel(
            onTap: pastoAcessivel
                ? () => _showPastoComparativoModal(
                    context: context,
                    isEntrada: isEntrada,
                    origemNome: pastoOrigem.texto,
                    origemModel: pastoOrigemModel,
                    destinoNome: pastoDestino.texto,
                    destinoModel: pastoDestinoModel,
                  )
                : null,
            linhas: [
              if (!isEntrada)
                _LinhaRotulo(
                  'Pasto de origem',
                  pastoOrigem.texto,
                  pastoOrigem.isFallback,
                ),
              _LinhaRotulo(
                'Pasto de destino',
                pastoDestino.texto,
                pastoDestino.isFallback,
              ),
            ],
          ),
          if (temRebanho) ...[
            const SizedBox(height: 8),
            _CaixaTocavel(
              onTap: rebanhoAcessivel
                  ? () => _showRebanhoComparativoModal(
                      context: context,
                      isEntrada: isEntrada,
                      origemId: historico.rebanhoOrigemId,
                      origemNome: rebanhoOrigem.texto,
                      origemModel: rebanhoOrigemModel,
                      destinoId: historico.rebanhoDestinoId,
                      destinoNome: rebanhoDestino.texto,
                      destinoModel: rebanhoDestinoModel,
                    )
                  : null,
              linhas: [
                if (!isEntrada)
                  _LinhaRotulo(
                    'Rebanho de origem',
                    rebanhoOrigem.texto,
                    rebanhoOrigem.isFallback,
                  ),
                _LinhaRotulo(
                  'Rebanho de destino',
                  rebanhoDestino.texto,
                  rebanhoDestino.isFallback,
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          Text(
            data,
            style: const TextStyle(
              color: AppColors.text4,
              fontSize: 12,
              fontFamily: 'DM Sans',
            ),
          ),
        ],
      ),
    );
  }
}

/// Resultado da resolução de um nome (pasto ou rebanho): o texto a exibir
/// e se ele representa um fallback (não encontrado/apagado), usado para
/// decidir a cor do texto.
class _NomeResolvido {
  const _NomeResolvido(this.texto, this.isFallback);
  final String texto;
  final bool isFallback;
}

/// Um par rótulo/valor exibido dentro de uma _CaixaTocavel.
class _LinhaRotulo {
  const _LinhaRotulo(this.rotulo, this.valor, this.isFallback);
  final String rotulo;
  final String valor;
  final bool isFallback;
}

/// Agrupa uma ou mais linhas rótulo/valor numa caixa com contorno visível.
/// Só recebe onTap (fica tocável, com destaque de cor) quando existe algo
/// de fato pra mostrar em detalhe — senão fica sem caixa, como texto simples,
/// deixando claro que não há nada além do que já está escrito ali.
class _CaixaTocavel extends StatelessWidget {
  const _CaixaTocavel({required this.linhas, this.onTap});

  final List<_LinhaRotulo> linhas;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final acessivel = onTap != null;

    Widget linha(_LinhaRotulo l) {
      return RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '${l.rotulo}: ',
              style: const TextStyle(
                color: AppColors.text4,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                fontFamily: 'DM Sans',
              ),
            ),
            TextSpan(
              text: l.valor,
              style: TextStyle(
                color: l.isFallback
                    ? AppColors.text4
                    : (acessivel ? AppColors.text2 : AppColors.text),
                fontSize: 13,
                fontWeight: FontWeight.w700,
                fontStyle: l.isFallback ? FontStyle.italic : FontStyle.normal,
                fontFamily: 'DM Sans',
              ),
            ),
          ],
        ),
      );
    }

    if (!acessivel) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < linhas.length; i++) ...[
            if (i > 0) const SizedBox(height: 4),
            linha(linhas[i]),
          ],
        ],
      );
    }

    // Caixa maior e com contorno de destaque — área de toque generosa e
    // visualmente óbvia como interativa.

    // child: Material(
    //   color: Colors.transparent,
    //   child: InkWell(
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        // behavior: HitTestBehavior.opaque,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            // color: AppColors.card,
            borderRadius: BorderRadius.circular(10),
            // ignore: deprecated_member_use
            border: Border.all(color: Colors.grey.withOpacity(0.4), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < linhas.length; i++) ...[
                if (i > 0) const SizedBox(height: 6),
                linha(linhas[i]),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// MODAIS DE DETALHE — PASTO / REBANHO
// =============================================================================

void _showPastoComparativoModal({
  required BuildContext context,
  required bool isEntrada,
  required String origemNome,
  required PastoModel? origemModel,
  required String destinoNome,
  required PastoModel? destinoModel,
}) {
  List<String>? linhasDe(PastoModel? p) {
    if (p == null) return null;
    return [
      'Área: ${p.area.toStringAsFixed(1)} ha',
      if (p.descricao.isNotEmpty) p.descricao,
      if (p.limiteAnimais != null) 'Limite: ${p.limiteAnimais} animais',
    ];
  }

  _showDetalheModal(
    context: context,
    titulo: isEntrada ? 'Entrada do Animal' : 'Movimentação de Pasto',
    icone: isEntrada ? Icons.login_rounded : Icons.grass_rounded,
    // Na entrada não existe pasto anterior por natureza: o animal simplesmente
    // passa a existir já em um pasto, não "vem de" outro.
    anterior: isEntrada
        ? null
        : _DetalheBloco(
            rotulo: 'Pasto anterior',
            nome: origemNome,
            linhas: linhasDe(origemModel),
          ),
    atual: _DetalheBloco(
      rotulo: isEntrada ? 'Pasto' : 'Pasto atual',
      nome: destinoNome,
      linhas: linhasDe(destinoModel),
    ),
  );
}

void _showRebanhoComparativoModal({
  required BuildContext context,
  required bool isEntrada,
  required String? origemId,
  required String origemNome,
  required RebanhoModel? origemModel,
  required String? destinoId,
  required String destinoNome,
  required RebanhoModel? destinoModel,
}) {
  List<String>? linhasDe(RebanhoModel? r) {
    if (r == null) return null;
    return ['Cadastrado em ${DateFormat('MMM yyyy').format(r.dataCadastro)}'];
  }

  // Sem vínculo (id null) é um estado normal, não um erro — só quando o id
  // existe mas não foi encontrado no banco é que é de fato "apagado".
  String? mensagemVaziaDe(String? id, {required bool isOrigem}) {
    if (id != null) return null;
    return isOrigem
        ? 'Animal não fazia parte de nenhum rebanho'
        : 'Animal não faz parte de nenhum rebanho';
  }

  _showDetalheModal(
    context: context,
    titulo: isEntrada ? 'Entrada do Animal' : 'Movimentação de Rebanho',
    icone: isEntrada ? Icons.login_rounded : Icons.groups_outlined,
    // Rebanho origem é sempre null na entrada: o animal não "vinha de" um
    // rebanho, ele só pode já nascer/entrar em um (ou em nenhum).
    anterior: isEntrada
        ? null
        : _DetalheBloco(
            rotulo: 'Rebanho anterior',
            nome: origemNome,
            linhas: linhasDe(origemModel),
            mensagemVazia: mensagemVaziaDe(origemId, isOrigem: true),
          ),
    atual: _DetalheBloco(
      rotulo: isEntrada ? 'Rebanho' : 'Rebanho atual',
      nome: destinoNome,
      linhas: linhasDe(destinoModel),
      mensagemVazia: mensagemVaziaDe(destinoId, isOrigem: false),
    ),
  );
}

/// Bloco de informação de um lado (anterior/atual) de um modal comparativo.
/// `linhas == null` significa "sem dado extra pra mostrar", que pode ser
/// por dois motivos bem diferentes: `mensagemVazia` diz qual dos dois é —
/// se `null`, é o caso padrão "apagado ou não encontrado no banco"; se
/// preenchida, é um estado normal (ex: "não faz parte de nenhum rebanho").
class _DetalheBloco {
  const _DetalheBloco({
    required this.rotulo,
    required this.nome,
    this.linhas,
    this.mensagemVazia,
  });
  final String rotulo;
  final String nome;
  final List<String>? linhas;
  final String? mensagemVazia;
}

void _showDetalheModal({
  required BuildContext context,
  required String titulo,
  required IconData icone,
  required _DetalheBloco? anterior,
  required _DetalheBloco atual,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                Icon(icone, color: AppColors.accent, size: 18),
                const SizedBox(width: 8),
                Text(
                  titulo,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'DM Sans',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (anterior != null) ...[
              _DetalheBlocoView(bloco: anterior),
              const SizedBox(height: 10),
            ],
            _DetalheBlocoView(bloco: atual),
          ],
        ),
      ),
    ),
  );
}

class _DetalheBlocoView extends StatelessWidget {
  const _DetalheBlocoView({required this.bloco});
  final _DetalheBloco bloco;

  @override
  Widget build(BuildContext context) {
    final semDados = bloco.linhas == null;
    final semVinculo = semDados && bloco.mensagemVazia != null;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            bloco.rotulo,
            style: const TextStyle(
              color: AppColors.text4,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              fontFamily: 'DM Sans',
            ),
          ),
          const SizedBox(height: 4),
          if (semVinculo) ...[
            // Estado normal (sem erro): não tinha/não tem vínculo mesmo.
            Text(
              bloco.mensagemVazia!,
              style: const TextStyle(
                color: AppColors.text2,
                fontSize: 13,
                fontFamily: 'DM Sans',
              ),
            ),
          ] else ...[
            Text(
              bloco.nome,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                fontFamily: 'DM Sans',
              ),
            ),
            if (semDados) ...[
              const SizedBox(height: 4),
              const Text(
                'Apagado ou não encontrado no banco',
                style: TextStyle(
                  color: AppColors.text4,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  fontFamily: 'DM Sans',
                ),
              ),
            ] else ...[
              for (final linha in bloco.linhas!) ...[
                const SizedBox(height: 4),
                Text(
                  linha,
                  style: const TextStyle(
                    color: AppColors.text2,
                    fontSize: 13,
                    fontFamily: 'DM Sans',
                  ),
                ),
              ],
            ],
          ],
        ],
      ),
    );
  }
}

// =============================================================================
// MODAL DE DETALHE — PESO
// =============================================================================

void _showPesoComparativoModal({
  required BuildContext context,
  required HistoricoAnimalModel atual,
  required HistoricoAnimalModel? anterior,
}) {
  final isEntrada = atual.tipo == HistoricoTipo.entrada;
  final pesoAtual = atual.novoPeso;
  // Na entrada não existe "peso anterior" por natureza — é o primeiro
  // registro de peso do animal, não uma comparação com nada.
  final pesoAnterior = isEntrada ? null : anterior?.novoPeso;
  final delta = (pesoAtual != null && pesoAnterior != null)
      ? pesoAtual - pesoAnterior
      : null;

  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                Icon(
                  isEntrada
                      ? Icons.login_rounded
                      : Icons.monitor_weight_outlined,
                  color: AppColors.accent,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  isEntrada ? 'Entrada do Animal' : 'Pesagem',
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'DM Sans',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (isEntrada)
              Row(
                children: [
                  Expanded(
                    child: _PesoBloco(
                      rotulo: 'Peso inicial',
                      peso: pesoAtual,
                      data: atual.data,
                    ),
                  ),
                  Expanded(child: SizedBox.shrink()),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: _PesoBloco(
                      rotulo: 'Anterior',
                      peso: pesoAnterior,
                      data: anterior?.data,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _PesoBloco(
                      rotulo: 'Atual',
                      peso: pesoAtual,
                      data: atual.data,
                    ),
                  ),
                ],
              ),
            if (delta != null) ...[
              const SizedBox(height: 12),
              Text(
                delta >= 0
                    ? 'Ganho de ${delta.toStringAsFixed(1)} kg'
                    : 'Perda de ${delta.abs().toStringAsFixed(1)} kg',
                style: TextStyle(
                  color: delta >= 0 ? AppColors.accent : AppColors.red,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'DM Sans',
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

class _PesoBloco extends StatelessWidget {
  const _PesoBloco({
    required this.rotulo,
    required this.peso,
    required this.data,
  });

  final String rotulo;
  final double? peso;
  final DateTime? data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            rotulo,
            style: const TextStyle(
              color: AppColors.text4,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              fontFamily: 'DM Sans',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            peso == null ? '—' : '${peso!.toStringAsFixed(1)} kg',
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              fontFamily: 'DM Sans',
            ),
          ),
          if (data != null) ...[
            const SizedBox(height: 2),
            Text(
              DateFormat('dd MMM yyyy').format(data!),
              style: const TextStyle(
                color: AppColors.text2,
                fontSize: 12,
                fontFamily: 'DM Sans',
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// =============================================================================
// ITEM DE EVENTO GENÉRICO
// =============================================================================

class _EventoItem extends StatelessWidget {
  const _EventoItem({
    required this.historico,
    required this.isFirst,
    required this.isLast,
  });

  final HistoricoAnimalModel historico;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final data = DateFormat('dd MMM yyyy').format(historico.data);

    return Container(
      padding: EdgeInsets.fromLTRB(16, isFirst ? 14 : 10, 16, isLast ? 14 : 10),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.event_note_rounded,
              color: AppColors.text4,
              size: 14,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  historico.tipo.label,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'DM Sans',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  data,
                  style: const TextStyle(
                    color: AppColors.text4,
                    fontSize: 12,
                    fontFamily: 'DM Sans',
                  ),
                ),
              ],
            ),
          ),
          Text(
            historico.novoPeso!.toStringAsFixed(1),
            style: const TextStyle(
              color: AppColors.text2,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              fontFamily: 'DM Sans',
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// WIDGETS AUXILIARES
// =============================================================================

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.text4,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.0,
          fontFamily: 'DM Sans',
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_rounded, color: AppColors.text4, size: 48),
            SizedBox(height: 16),
            Text(
              'Nenhum histórico',
              style: TextStyle(
                color: AppColors.text,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontFamily: 'DM Sans',
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Os registros de pesagem e\nmovimentação aparecerão aqui.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.text4,
                fontSize: 13,
                fontFamily: 'DM Sans',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
