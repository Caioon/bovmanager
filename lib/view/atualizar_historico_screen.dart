//mudar rebanho (pastoId == rebanho.pastoid, rebanhoDestinoId = rebanho.id)
//rebanhoOrigem -> antigoRebanhoId(not null), rebanhoDestino -> novoRebanhoId
//pastoOrigem -> pastoAntigoId(not null), pastoDestino -> rebanho.pastoId
//nome: Mudar rebanho

//entrar em um rebanho (pastoId == rebanho.pastoid, rebanhoDestinoId = rebanho.id)
//rebanhoOrigem -> null, rebanhoDestino -> novoRebanhoId
//pastoOrigem -> pastoAntigoId, pastoDestino -> rebanho.pastoId
//nome: Entrar rebanho

//os dois parecem ser os mesmos, mas eu vou separa-los como movimentações diferentes pra exibir mensagens diferentes na ui

//sair do rebanho e mudar de pasto
//rebanhoOrigem -> antigoRebanhoId(not null), rebanhoDestino -> null
//pastoOrigem -> pastoAntigoId, pastoDestino -> novoPastoId
//nome: Sair Rebanho/mudar Pasto

//sair do rebanho e ficar no mesmo pasto
//rebanhoOrigem -> antigoRebanhoId(not null), rebanhoDestino -> null
//pastoOrigem -> pastoAntigoId, pastoDestino -> antigoPastoDestinoId
//nome: Sair rebanho/manter pasto

//Caso externo: rebanho muda de pasto
//Força o(s) animal(is) a mudar pro pastoId novo do rebanho.pastoId
//rebanhoOrigem -> antigoRebanhoId(not null), rebanhoDestino -> antigoRebanhoDestino(not null)
//pastoOrigem -> pastoAntigoId, pastoDestino -> rebanho.pastoId
//nome: Mudar pasto com rebanho

import 'package:bov_manager/core/theme/app_colors.dart';
import 'package:bov_manager/core/widgets/bov_widgets.dart';
import 'package:bov_manager/models/historico_tipo.dart';
import 'package:bov_manager/models/pasto_model.dart';
import 'package:bov_manager/models/rebanho_model.dart';
import 'package:bov_manager/repositories/rebanho_repository.dart';
import 'package:bov_manager/services/pasto_service.dart';
import 'package:bov_manager/viewmodels/animal_viewmodel.dart';
import 'package:bov_manager/viewmodels/historico_animal_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// =============================================================================
// MODAL DE SELEÇÃO — chamado pelo DetalhesAnimalScreen
// =============================================================================

// As flags `podeMovimentarRebanho` e `podeMudarPasto` são calculadas pela
// tela chamadora (DetalhesAnimalScreen), que já tem acesso à propriedade e
// ao histórico atual do animal. Elas controlam se as opções de "Entrar/Mudar
// rebanho" e "Mudar para outro pasto" aparecem habilitadas ou em vermelho.
// "Sair do rebanho" usa a própria `temRebanho` para a mesma finalidade.
void showAtualizarHistoricoModal(
  BuildContext context, {
  required bool temRebanho,
  required bool podeMovimentarRebanho,
  required bool podeMudarPasto,
  String? motivoMovimentarRebanhoIndisponivel,
  String? motivoMudarPastoIndisponivel,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => Consumer(
      builder: (ctx, ref, _) {
        // O animal já carregado é a fonte confiável do propriedadeId —
        // não usar providers que dependem de "propriedade em visualização"
        // (estado global à parte), que pode nunca ter sido setado nessa
        // tela e faz `rebanhoListaProvider`/`pastosListaPropEmVisualizacao`
        // voltarem vazios (ou, no caso do rebanho, um Stream.empty() que
        // trava um `await` pra sempre, sem erro nenhum).
        final propriedadeId =
            ref.read(animalEmVisualizacaoProvider)?.propriedadeId ?? '';

        return SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Alça
                  Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 2, 2, 2),
                    child: const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Registrar alteração',
                        style: TextStyle(
                          color: AppColors.text,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'DM Sans',
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'PESAGEM',
                        style: TextStyle(
                          color: AppColors.text4,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: .8,
                          fontFamily: 'DM Sans',
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── Pesagem ─────────────────────────────────────────────────
                  _ModalOpcao(
                    icon: Icons.monitor_weight_outlined,
                    titulo: 'Registrar peso',
                    subtitulo: 'Atualizar o peso do animal',

                    onTap: () async {
                      Navigator.of(context).pop();

                      if (!context.mounted) return;

                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder: (_, _, _) =>
                              const _RegistrarPesagemScreen(),
                          transitionDuration: const Duration(milliseconds: 300),
                          transitionsBuilder: (_, animation, _, child) {
                            return SlideTransition(
                              position:
                                  Tween(
                                        begin: const Offset(1.0, 0.0),
                                        end: Offset.zero,
                                      )
                                      .chain(
                                        CurveTween(curve: Curves.easeInOut),
                                      )
                                      .animate(animation),
                              child: child,
                            );
                          },
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        'MOVIMENTAÇÃO',
                        style: TextStyle(
                          color: AppColors.text4,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: .8,
                          fontFamily: 'DM Sans',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Movimentação — entrar/mudar rebanho ──────────────────────
                  _ModalOpcao(
                    icon: Icons.sync_alt_rounded,
                    titulo: temRebanho
                        ? 'Mudar de rebanho'
                        : 'Entrar em um rebanho',
                    subtitulo: 'Vai para o pasto do rebanho',
                    habilitado: podeMovimentarRebanho,
                    motivoIndisponivel: podeMovimentarRebanho
                        ? null
                        : motivoMovimentarRebanhoIndisponivel,
                    onTap: () async {
                      Navigator.of(ctx).pop();

                      final rebanhos = await ref
                          .read(rebanhoRepositoryProvider)
                          .listarStream(propriedadeId)
                          .first;

                      final pastos = await ref
                          .read(pastoServiceProvider)
                          .listar(propriedadeId);

                      if (!context.mounted) return;

                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder: (_, _, _) =>
                              _RegistrarMudancaRebanhoScreen(
                                rebanhos: rebanhos,
                                pastos: pastos,
                                titulo: temRebanho
                                    ? 'Mudar de rebanho'
                                    : 'Entrar em um novo rebanho',
                                temRebanho: temRebanho,
                              ),
                          transitionDuration: const Duration(milliseconds: 300),
                          transitionsBuilder: (_, animation, _, child) {
                            return SlideTransition(
                              position:
                                  Tween(
                                        begin: const Offset(1.0, 0.0),
                                        end: Offset.zero,
                                      )
                                      .chain(
                                        CurveTween(curve: Curves.easeInOut),
                                      )
                                      .animate(animation),
                              child: child,
                            );
                          },
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 5),

                  // ── Movimentação — sair rebanho e mudar pasto ────────────────
                  _ModalOpcao(
                    icon: Icons.grass_rounded,
                    titulo: 'Mudar para outro pasto',
                    subtitulo: temRebanho
                        ? 'Sai do rebanho e muda de pasto'
                        : 'Continua sem rebanho no novo pasto',
                    habilitado: podeMudarPasto,
                    motivoIndisponivel: podeMudarPasto
                        ? null
                        : motivoMudarPastoIndisponivel,
                    onTap: () async {
                      Navigator.of(ctx).pop();

                      final pastos = await ref
                          .read(pastoServiceProvider)
                          .listar(propriedadeId);

                      if (!context.mounted) return;

                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder: (_, _, _) =>
                              _RegistrarMudancaPastoScreen(
                                pastos: pastos,
                                temRebanho: temRebanho,
                              ),
                          transitionDuration: const Duration(milliseconds: 300),
                          transitionsBuilder: (_, animation, _, child) {
                            return SlideTransition(
                              position:
                                  Tween(
                                        begin: const Offset(1.0, 0.0),
                                        end: Offset.zero,
                                      )
                                      .chain(
                                        CurveTween(curve: Curves.easeInOut),
                                      )
                                      .animate(animation),
                              child: child,
                            );
                          },
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 5),

                  // ── Movimentação — sair rebanho e ficar no pasto ─────────────
                  _ModalOpcao(
                    icon: Icons.logout_rounded,
                    titulo: 'Sair do rebanho',
                    subtitulo: 'Permanece no mesmo pasto',
                    habilitado: temRebanho,
                    motivoIndisponivel: temRebanho
                        ? null
                        : 'Animal não pertence a nenhum rebanho',
                    onTap: () async {
                      showBovConfirmDialog(
                        context: context,
                        icon: Icons.exit_to_app_rounded,
                        titulo: 'Sair do rebanho?',
                        descricao:
                            'O animal será removido do rebanho atual e permanecerá no mesmo pasto.',
                        textoConfirmar: 'Confirmar',
                        onConfirmar: () async {
                          Navigator.of(ctx).pop();

                          final ultimoRegistro = ref
                              .read(historicoAnimalListaProvider)
                              .value!
                              .firstWhere(
                                (registro) =>
                                    registro.tipo != HistoricoTipo.pesagem,
                              );

                          final pastos = await ref
                              .read(pastoServiceProvider)
                              .listar(propriedadeId);

                          final nomePastoDestinoAnterior = pastos
                              .firstWhere(
                                (pasto) =>
                                    pasto.id == ultimoRegistro.pastoDestinoId,
                              )
                              .nome;

                          final rebanhos = await ref
                              .read(rebanhoRepositoryProvider)
                              .listarStream(propriedadeId)
                              .first;

                          final nomeRebanhoDestinoAnterior = rebanhos
                              .firstWhere(
                                (rebanho) =>
                                    rebanho.id ==
                                    ultimoRegistro.rebanhoDestinoId,
                              )
                              .nome;

                          await ref
                              .read(animaisViewModelProvider.notifier)
                              .registrarHistoricoMovimento(
                                tipo: HistoricoTipo.sairRebanhoManterPasto,
                                pastoOrigemId: ultimoRegistro.pastoDestinoId,
                                pastoDestinoId: ultimoRegistro.pastoDestinoId,
                                nomePastoOrigem: nomePastoDestinoAnterior,
                                nomePastoDestino: nomePastoDestinoAnterior,
                                rebanhoOrigemId:
                                    ultimoRegistro.rebanhoDestinoId,
                                rebanhoDestinoId: null,
                                nomeRebanhoOrigem: nomeRebanhoDestinoAnterior,
                                nomeRebanhoDestino: null,
                                data: DateTime.now(),
                              );

                          if (!context.mounted) return;

                          final erro = ref.read(animaisViewModelProvider).error;
                          if (erro != null) {
                            showBovErrorSnackBar(context, erro.toString());
                            return;
                          }

                          showBovSuccessSnackBar(
                            context,
                            'Animal removido do rebanho com sucesso!',
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}

// =============================================================================
// OPÇÃO DO MODAL
// =============================================================================

class _ModalOpcao extends StatelessWidget {
  const _ModalOpcao({
    required this.icon,
    required this.titulo,
    required this.subtitulo,
    required this.onTap,
    this.habilitado = true,
    this.motivoIndisponivel,
  });

  final IconData icon;
  final String titulo;
  final String subtitulo;
  final VoidCallback onTap;
  final bool habilitado;
  final String? motivoIndisponivel;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: habilitado ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: habilitado
                ? AppColors.border
                : AppColors.red.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: habilitado
                    ? AppColors.accentBg
                    : AppColors.border.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: habilitado ? AppColors.accent : AppColors.text4,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: TextStyle(
                      color: habilitado ? AppColors.text : AppColors.text4,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'DM Sans',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitulo,
                    style: const TextStyle(
                      color: AppColors.text4,
                      fontSize: 13,
                      height: 1.3,
                      fontFamily: 'DM Sans',
                    ),
                  ),
                  if (!habilitado && motivoIndisponivel != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      motivoIndisponivel!,
                      style: TextStyle(
                        color: AppColors.red.withValues(alpha: 0.9),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'DM Sans',
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// SELETOR DE DATA — widget reutilizado nas duas telas
// =============================================================================

class _BovDatePicker extends StatelessWidget {
  const _BovDatePicker({required this.data, required this.onTap});

  final DateTime data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_rounded,
              color: AppColors.text4,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}',
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 14,
                fontFamily: 'DM Sans',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// TELA — REGISTRAR PESAGEM
// =============================================================================

class _RegistrarPesagemScreen extends ConsumerStatefulWidget {
  const _RegistrarPesagemScreen();

  @override
  ConsumerState<_RegistrarPesagemScreen> createState() =>
      _RegistrarPesagemScreenState();
}

class _RegistrarPesagemScreenState
    extends ConsumerState<_RegistrarPesagemScreen> {
  final _pesoController = TextEditingController();
  DateTime _data = DateTime.now();

  @override
  void dispose() {
    _pesoController.dispose();
    super.dispose();
  }

  Future<void> _selecionarData() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _data,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.accent,
            surface: AppColors.card,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _data = picked);
  }

  @override
  Widget build(BuildContext context) {
    final animal = ref.watch(animalEmVisualizacaoProvider);
    final isLoading = ref.watch(animaisViewModelProvider).isLoading;

    ref.listen(animaisViewModelProvider, (previous, next) {
      next.whenOrNull(
        data: (_) {
          if (previous is! AsyncLoading) return;
          Navigator.of(context).pop();
          showBovSuccessSnackBar(context, 'Peso registrado com sucesso!');
        },
        error: (e, _) => showBovErrorSnackBar(context, e.toString()),
      );
    });

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
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Registrar Pesagem',
                        style: TextStyle(
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

            // ── Formulário ────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (animal != null) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Peso atual',
                              style: TextStyle(
                                color: AppColors.text4,
                                fontSize: 13,
                                fontFamily: 'DM Sans',
                              ),
                            ),
                            Text(
                              '${animal.pesoAtual.toStringAsFixed(0)} kg',
                              style: const TextStyle(
                                color: AppColors.accent,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'DM Sans',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const BovFieldLabel(label: 'NOVO PESO (KG)'),
                              const SizedBox(height: 6),
                              BovTextField(
                                controller: _pesoController,
                                hintText: '0.0',
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                textInputAction: TextInputAction.done,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const BovFieldLabel(label: 'DATA'),
                              const SizedBox(height: 6),
                              _BovDatePicker(
                                data: _data,
                                onTap: _selecionarData,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    BovPrimaryButton(
                      label: 'Registrar Pesagem',
                      isLoading: isLoading,
                      onPressed: () {
                        final novoPeso =
                            double.tryParse(_pesoController.text) ?? 0.0;
                        ref
                            .read(animaisViewModelProvider.notifier)
                            .registrarHistoricoPesagem(
                              tipo: HistoricoTipo.pesagem,
                              novoPeso: novoPeso,
                              data: _data,
                            );
                      },
                    ),

                    const SizedBox(height: 10),

                    BovSecondaryButton(
                      label: 'Cancelar',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// TELA — REGISTRAR MUDANÇA DE PASTO
// =============================================================================

class _RegistrarMudancaPastoScreen extends ConsumerStatefulWidget {
  const _RegistrarMudancaPastoScreen({
    required this.pastos,
    required this.temRebanho,
  });

  final List<PastoModel> pastos;
  final bool temRebanho;

  @override
  ConsumerState<_RegistrarMudancaPastoScreen> createState() =>
      _RegistrarMovimentacaoScreenState();
}

class _RegistrarMovimentacaoScreenState
    extends ConsumerState<_RegistrarMudancaPastoScreen> {
  PastoModel? _destino;
  DateTime _data = DateTime.now();

  Future<void> _selecionarData() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _data,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.accent,
            surface: AppColors.card,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _data = picked);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(animaisViewModelProvider).isLoading;

    // A origem não é escolhida pelo usuário: é o pasto em que o animal já
    // está, obtido a partir do último registro do histórico — mesmo padrão
    // usado em _RegistrarMudancaRebanhoScreen.
    final ultimoRegistro = ref
        .read(historicoAnimalListaProvider)
        .value!
        .firstWhere((registro) => registro.tipo != HistoricoTipo.pesagem);

    PastoModel? origem;
    for (final pasto in widget.pastos) {
      if (pasto.id == ultimoRegistro.pastoDestinoId) {
        origem = pasto;
        break;
      }
    }

    final destinoOpcoes = widget.pastos
        .where((p) => p.id != origem?.id)
        .toList();

    ref.listen(animaisViewModelProvider, (previous, next) {
      next.whenOrNull(
        data: (_) {
          if (previous is! AsyncLoading) return;
          Navigator.of(context).pop();
          showBovSuccessSnackBar(
            context,
            'Movimentação registrada com sucesso!',
          );
        },
        error: (e, _) => showBovErrorSnackBar(context, e.toString()),
      );
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  BovBackButton(),
                  Expanded(
                    child: Center(
                      child: Text(
                        widget.temRebanho
                            ? 'Sair do rebanho e mudar pasto'
                            : 'Mudar de pasto',
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

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const BovFieldLabel(label: 'PASTO ORIGEM'),
                    const SizedBox(height: 6),
                    Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        origem?.nome ?? 'Nenhum pasto atualmente',
                        style: TextStyle(
                          color: origem == null
                              ? AppColors.text4
                              : AppColors.text,
                          fontSize: 14,
                          fontFamily: 'DM Sans',
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    const BovFieldLabel(label: 'PASTO DESTINO'),
                    const SizedBox(height: 6),
                    _BovDropdown<PastoModel>(
                      value: _destino,
                      items: destinoOpcoes,
                      itemLabel: (p) => p.nome,
                      hint: 'Selecionar pasto de destino...',
                      onChanged: (p) => setState(() => _destino = p),
                    ),

                    const SizedBox(height: 14),

                    const BovFieldLabel(label: 'DATA'),
                    const SizedBox(height: 6),
                    _BovDatePicker(data: _data, onTap: _selecionarData),

                    if (widget.temRebanho) ...[
                      const SizedBox(height: 14),
                      const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppColors.text4,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'O animal está em um rebanho. Mudar para outro pasto o removerá do rebanho.',
                              style: TextStyle(
                                color: AppColors.text4,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 24),

                    BovPrimaryButton(
                      label: 'Registrar Movimentação',
                      isLoading: isLoading,
                      onPressed: _destino == null
                          ? null
                          : () {
                              ref
                                  .read(animaisViewModelProvider.notifier)
                                  .registrarHistoricoMovimento(
                                    tipo: widget.temRebanho
                                        ? HistoricoTipo.sairRebanhoMudarPasto
                                        : HistoricoTipo
                                              .mudarPastoContinuarSemRebanho,
                                    pastoOrigemId: origem?.id,
                                    pastoDestinoId: _destino!.id,
                                    data: _data,
                                    rebanhoOrigemId:
                                        ultimoRegistro.rebanhoDestinoId,
                                    rebanhoDestinoId: null,
                                    nomePastoOrigem: origem?.nome,
                                    nomePastoDestino: _destino!.nome,
                                    nomeRebanhoOrigem:
                                        ultimoRegistro.nomeRebanhoDestino,
                                    nomeRebanhoDestino: null,
                                  );
                            },
                    ),

                    const SizedBox(height: 10),

                    BovSecondaryButton(
                      label: 'Cancelar',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// TELA — REGISTRAR MUDANÇA DE REBANHO
// =============================================================================

class _RegistrarMudancaRebanhoScreen extends ConsumerStatefulWidget {
  const _RegistrarMudancaRebanhoScreen({
    required this.rebanhos,
    required this.pastos,
    required this.titulo,
    required this.temRebanho,
  });

  final List<RebanhoModel> rebanhos;
  final List<PastoModel> pastos;
  final String titulo;
  final bool temRebanho;

  @override
  ConsumerState<_RegistrarMudancaRebanhoScreen> createState() =>
      _RegistrarMudancaRebanhoScreenState();
}

class _RegistrarMudancaRebanhoScreenState
    extends ConsumerState<_RegistrarMudancaRebanhoScreen> {
  RebanhoModel? _rebanhoDestino;
  DateTime _data = DateTime.now();

  Future<void> _selecionarData() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _data,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.accent,
            surface: AppColors.card,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _data = picked);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(animaisViewModelProvider).isLoading;

    // A origem não é escolhida pelo usuário: é o rebanho em que o animal
    // já está (ou nenhum, se ainda não pertence a um rebanho).
    final ultimoRegistro = ref
        .read(historicoAnimalListaProvider)
        .value!
        .firstWhere((registro) => registro.tipo != HistoricoTipo.pesagem);

    RebanhoModel? rebanhoOrigem;
    for (final rebanho in widget.rebanhos) {
      if (rebanho.id == ultimoRegistro.rebanhoDestinoId) {
        rebanhoOrigem = rebanho;
        break;
      }
    }

    final destinoRebanhos = widget.rebanhos
        .where((p) => p.id != rebanhoOrigem?.id)
        .toList();

    ref.listen(animaisViewModelProvider, (previous, next) {
      next.whenOrNull(
        data: (_) {
          if (previous is! AsyncLoading) return;
          Navigator.of(context).pop();
          showBovSuccessSnackBar(
            context,
            'Movimentação registrada com sucesso!',
          );
        },
        error: (e, _) => showBovErrorSnackBar(context, e.toString()),
      );
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  BovBackButton(),
                  Expanded(
                    child: Center(
                      child: Text(
                        widget.titulo,
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

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const BovFieldLabel(label: 'REBANHO ORIGEM'),
                    const SizedBox(height: 6),
                    Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        rebanhoOrigem?.nome ?? 'Nenhum rebanho atualmente',
                        style: TextStyle(
                          color: rebanhoOrigem == null
                              ? AppColors.text4
                              : AppColors.text,
                          fontSize: 14,
                          fontFamily: 'DM Sans',
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    const BovFieldLabel(label: 'REBANHO DESTINO'),
                    const SizedBox(height: 6),
                    _BovDropdown<RebanhoModel>(
                      value: _rebanhoDestino,
                      items: destinoRebanhos,
                      itemLabel: (p) => p.nome,
                      hint: 'Selecionar rebanho de destino...',
                      onChanged: (p) => setState(() => _rebanhoDestino = p),
                    ),

                    const SizedBox(height: 14),

                    const BovFieldLabel(label: 'DATA'),
                    const SizedBox(height: 6),
                    _BovDatePicker(data: _data, onTap: _selecionarData),

                    const SizedBox(height: 14),
                    const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppColors.text4,
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'O pasto do animal automaticamente mudará e registrará para o pasto do rebanho destino.',
                            style: TextStyle(
                              color: AppColors.text4,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    BovPrimaryButton(
                      label: 'Registrar Movimentação',
                      isLoading: isLoading,
                      onPressed: _rebanhoDestino == null
                          ? null
                          : () {
                              final nomePastoDestino = widget.pastos
                                  .firstWhere(
                                    (pasto) =>
                                        pasto.id == _rebanhoDestino!.pastoId,
                                  )
                                  .nome;

                              ref
                                  .read(animaisViewModelProvider.notifier)
                                  .registrarHistoricoMovimento(
                                    tipo: widget.temRebanho
                                        ? HistoricoTipo.mudarRebanho
                                        : HistoricoTipo.entrarRebanho,
                                    pastoOrigemId:
                                        ultimoRegistro.pastoDestinoId,
                                    pastoDestinoId: _rebanhoDestino!.pastoId,
                                    data: _data,
                                    rebanhoOrigemId:
                                        ultimoRegistro.rebanhoDestinoId,
                                    rebanhoDestinoId: _rebanhoDestino!.id,
                                    nomePastoOrigem:
                                        ultimoRegistro.nomePastoDestino,
                                    nomePastoDestino: nomePastoDestino,
                                    nomeRebanhoOrigem: rebanhoOrigem?.nome,
                                    nomeRebanhoDestino: _rebanhoDestino!.nome,
                                  );
                            },
                    ),

                    const SizedBox(height: 10),

                    BovSecondaryButton(
                      label: 'Cancelar',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// DROPDOWN ESTILIZADO
// =============================================================================

class _BovDropdown<T> extends StatelessWidget {
  const _BovDropdown({
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.hint,
    required this.onChanged,
    this.enabled = true,
  });

  final T? value;
  final List<T> items;
  final String Function(T) itemLabel;
  final String hint;
  final ValueChanged<T?> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: enabled ? AppColors.card : AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: enabled ? AppColors.text4 : AppColors.border,
            size: 20,
          ),
          dropdownColor: AppColors.card,
          style: const TextStyle(
            color: AppColors.text,
            fontSize: 14,
            fontFamily: 'DM Sans',
          ),
          hint: Text(
            hint,
            style: TextStyle(
              color: enabled ? AppColors.text4 : AppColors.border,
              fontSize: 14,
              fontFamily: 'DM Sans',
            ),
          ),
          onChanged: enabled ? onChanged : null,
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(itemLabel(item)),
            );
          }).toList(),
        ),
      ),
    );
  }
}

Future<void> showBovConfirmDialog({
  required BuildContext context,
  required IconData icon,
  required String titulo,
  required String descricao,
  required String textoConfirmar,
  String textoCancelar = 'Cancelar',
  required VoidCallback onConfirmar,
}) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) {
      return Dialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.accentBg,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: AppColors.accent, size: 32),
              ),

              const SizedBox(height: 20),

              Text(
                titulo,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'DM Sans',
                ),
              ),

              const SizedBox(height: 10),

              Text(
                descricao,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.text4,
                  fontSize: 14,
                  height: 1.4,
                  fontFamily: 'DM Sans',
                ),
              ),

              const SizedBox(height: 28),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.text4,
                        side: BorderSide(color: AppColors.border),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        textoCancelar,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontFamily: 'DM Sans',
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        onConfirmar();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentBg,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: const BorderSide(
                            color: AppColors.accent,
                            width: 1.5,
                          ),
                        ),
                      ),
                      child: Text(
                        textoConfirmar,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontFamily: 'DM Sans',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
