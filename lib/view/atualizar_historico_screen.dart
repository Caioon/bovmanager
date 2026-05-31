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

//nome: Mudar rebanho    //nome: Entrar rebanho
//nome: Sair Rebanho/mudar Pasto
//nome: Sair rebanho/manter pasto
//nome: Mudar pasto com rebanho

//     ? 'Entrar em novo rebanho'
//     : 'Mudar rebanho',
// tipo: 'Sair rebanho/Mudar pasto',
// tipo: 'Pesagem',

import 'package:bov_manager/core/theme/app_colors.dart';
import 'package:bov_manager/core/widgets/bov_widgets.dart';
import 'package:bov_manager/models/historico_tipo.dart';
import 'package:bov_manager/models/pasto_model.dart';
import 'package:bov_manager/models/rebanho_model.dart';
import 'package:bov_manager/viewmodels/animal_viewmodel.dart';
import 'package:bov_manager/viewmodels/historico_animal_viewmodel.dart';
import 'package:bov_manager/viewmodels/pasto_viewmodel.dart';
import 'package:bov_manager/viewmodels/rebanho_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// =============================================================================
// MODAL DE SELEÇÃO — chamado pelo DetalhesAnimalScreen
// =============================================================================

void showAtualizarHistoricoModal(BuildContext context, bool temRebanho) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => Consumer(
      builder: (ctx, ref, _) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
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

              const Text(
                'O que deseja registrar?',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'DM Sans',
                ),
              ),

              const SizedBox(height: 20),

              // ── Pesagem ─────────────────────────────────────────────────
              _ModalOpcao(
                icon: Icons.monitor_weight_outlined,
                titulo: 'Pesagem',
                subtitulo: 'Registrar novo peso do animal',
                onTap: () async {
                  Navigator.of(context).pop();

                  final pastos = await ref.read(pastosListaPropEmVisualizacaoProvider.future);

                  if (!context.mounted) return;

                  if (pastos.length < 2) {
                    showBovErrorSnackBar(
                      context,
                      'Cadastre ao menos 2 pastos para registrar uma movimentação.',
                    );
                    return;
                  }
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
                                  .chain(CurveTween(curve: Curves.easeInOut))
                                  .animate(animation),
                          child: child,
                        );
                      },
                    ),
                  );
                },
              ),

              const SizedBox(height: 10),

              // ── Movimentação — entrar/mudar rebanho ──────────────────────
              _ModalOpcao(
                icon: Icons.arrow_forward_rounded,
                titulo: 'Movimentação',
                subtitulo: temRebanho
                    ? 'Mudar de rebanho'
                    : 'Entrar em um novo rebanho',
                onTap: () async {
                  final rebanhos = await ref.read(rebanhoListaProvider.future);

                  if (!context.mounted) return;

                  final ultimoRegistro = ref
                      .read(historicoAnimalListaProvider)
                      .value!
                      .firstWhere((registro) =>
                          registro.tipo != HistoricoTipo.pesagem);

                  final possuiOutroRebanho = rebanhos.any(
                    (r) => r.id != ultimoRegistro.rebanhoDestinoId,
                  );

                  if (!possuiOutroRebanho) {
                    showBovErrorSnackBar(
                      context,
                      'Cadastre ao menos 1 outro rebanho para registrar uma movimentação.',
                    );
                    return;
                  }

                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (_, _, _) =>
                          _RegistrarMudancaRebanhoScreen(
                            rebanhos: rebanhos,
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
                                  .chain(CurveTween(curve: Curves.easeInOut))
                                  .animate(animation),
                          child: child,
                        );
                      },
                    ),
                  );
                },
              ),

              // ── Movimentação — sair rebanho e mudar pasto ────────────────
              _ModalOpcao(
                icon: Icons.arrow_forward_rounded,
                titulo: 'Movimentação',
                subtitulo: 'Sair do rebanho e mudar o pasto',
                onTap: () async {
                  Navigator.of(ctx).pop();

                  final pastos = await ref.read(pastosListaPropEmVisualizacaoProvider.future);

                  if (!context.mounted) return;

                  if (pastos.length < 2) {
                    showBovErrorSnackBar(
                      context,
                      'Cadastre ao menos 2 pastos para registrar uma movimentação.',
                    );
                    return;
                  }

                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (_, _, _) =>
                          _RegistrarMudancaPastoScreen(pastos: pastos),
                      transitionDuration: const Duration(milliseconds: 300),
                      transitionsBuilder: (_, animation, _, child) {
                        return SlideTransition(
                          position:
                              Tween(
                                    begin: const Offset(1.0, 0.0),
                                    end: Offset.zero,
                                  )
                                  .chain(CurveTween(curve: Curves.easeInOut))
                                  .animate(animation),
                          child: child,
                        );
                      },
                    ),
                  );
                },
              ),

              // ── Movimentação — sair rebanho e ficar no pasto ─────────────
              _ModalOpcao(
                icon: Icons.arrow_forward_rounded,
                titulo: 'Movimentação',
                subtitulo: 'Sair do rebanho e ficar no pasto',
                onTap: () async {
                  showBovConfirmDialog(
                    context: context,
                    icon: Icons.exit_to_app_rounded,
                    titulo: 'Sair do rebanho?',
                    descricao:
                        'O animal será removido do rebanho atual e permanecerá no mesmo pasto.',
                    textoConfirmar: 'Confirmar',
                    onConfirmar: () {
                      final ultimoRegistro = ref
                          .read(historicoAnimalListaProvider)
                          .value!
                          .firstWhere((registro) =>
                              registro.tipo != HistoricoTipo.pesagem);
                      ref
                          .read(animaisViewModelProvider.notifier)
                          .registrarHistoricoMovimento(
                            tipo: HistoricoTipo.sairRebanhoManterPasto,
                            pastoOrigemId: ultimoRegistro.pastoDestinoId,
                            pastoDestinoId: ultimoRegistro.pastoDestinoId,
                            data: DateTime.now(),
                            rebanhoOrigemId: ultimoRegistro.rebanhoDestinoId,
                            rebanhoDestinoId: null,
                          );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
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
  });

  final IconData icon;
  final String titulo;
  final String subtitulo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.accentBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.accent, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'DM Sans',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitulo,
                    style: const TextStyle(
                      color: AppColors.text4,
                      fontSize: 12,
                      fontFamily: 'DM Sans',
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.text4,
              size: 18,
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

    ref.listen(animaisViewModelProvider, (_, next) {
      next.whenOrNull(
        data: (_) => Navigator.of(context).pop(),
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
  const _RegistrarMudancaPastoScreen({required this.pastos});

  final List<PastoModel> pastos;

  @override
  ConsumerState<_RegistrarMudancaPastoScreen> createState() =>
      _RegistrarMovimentacaoScreenState();
}

class _RegistrarMovimentacaoScreenState
    extends ConsumerState<_RegistrarMudancaPastoScreen> {
  PastoModel? _origem;
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

    final destinoOpcoes = widget.pastos
        .where((p) => p.id != _origem?.id)
        .toList();

    ref.listen(animaisViewModelProvider, (_, next) {
      next.whenOrNull(
        data: (_) => Navigator.of(context).pop(),
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
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Sair do rebanho e mudar pasto',
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

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const BovFieldLabel(label: 'PASTO ORIGEM'),
                    const SizedBox(height: 6),
                    _BovDropdown<PastoModel>(
                      value: _origem,
                      items: widget.pastos,
                      itemLabel: (p) => p.nome,
                      hint: 'Selecionar pasto de origem...',
                      onChanged: (p) => setState(() {
                        _origem = p;
                        if (_destino?.id == p?.id) _destino = null;
                      }),
                    ),

                    const SizedBox(height: 14),

                    const BovFieldLabel(label: 'PASTO DESTINO'),
                    const SizedBox(height: 6),
                    _BovDropdown<PastoModel>(
                      value: _destino,
                      items: destinoOpcoes,
                      itemLabel: (p) => p.nome,
                      hint: _origem == null
                          ? 'Selecione a origem primeiro'
                          : 'Selecionar pasto de destino...',
                      enabled: _origem != null,
                      onChanged: (p) => setState(() => _destino = p),
                    ),

                    const SizedBox(height: 14),

                    const BovFieldLabel(label: 'DATA'),
                    const SizedBox(height: 6),
                    _BovDatePicker(data: _data, onTap: _selecionarData),

                    const SizedBox(height: 24),

                    BovPrimaryButton(
                      label: 'Registrar Movimentação',
                      isLoading: isLoading,
                      onPressed: _origem == null || _destino == null
                          ? null
                          : () {
                              ref
                                  .read(animaisViewModelProvider.notifier)
                                  .registrarHistoricoMovimento(
                                    tipo: HistoricoTipo.sairRebanhoMudarPasto,
                                    pastoOrigemId: _origem!.id,
                                    pastoDestinoId: _destino!.id,
                                    data: _data,
                                    rebanhoOrigemId: null,
                                    rebanhoDestinoId: null,
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
    required this.titulo,
    required this.temRebanho,
  });

  final List<RebanhoModel> rebanhos;
  final String titulo;
  final bool temRebanho;

  @override
  ConsumerState<_RegistrarMudancaRebanhoScreen> createState() =>
      _RegistrarMudancaRebanhoScreenState();
}

class _RegistrarMudancaRebanhoScreenState
    extends ConsumerState<_RegistrarMudancaRebanhoScreen> {
  RebanhoModel? _rebanhoOrigem;
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

    final destinoRebanhos = widget.rebanhos
        .where((p) => p.id != _rebanhoOrigem?.id)
        .toList();

    ref.listen(animaisViewModelProvider, (_, next) {
      next.whenOrNull(
        data: (_) => Navigator.of(context).pop(),
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
                    _BovDropdown<RebanhoModel>(
                      value: _rebanhoOrigem,
                      items: widget.rebanhos,
                      itemLabel: (p) => p.nome,
                      hint: 'Selecionar rebanho de origem...',
                      onChanged: (p) => setState(() {
                        _rebanhoOrigem = p;
                        if (_rebanhoDestino?.id == p?.id) _rebanhoDestino = null;
                      }),
                    ),

                    const SizedBox(height: 14),

                    const BovFieldLabel(label: 'REBANHO DESTINO'),
                    const SizedBox(height: 6),
                    _BovDropdown<RebanhoModel>(
                      value: _rebanhoDestino,
                      items: destinoRebanhos,
                      itemLabel: (p) => p.nome,
                      hint: _rebanhoOrigem == null
                          ? 'Selecione a origem primeiro'
                          : 'Selecionar rebanho de destino...',
                      enabled: _rebanhoOrigem != null,
                      onChanged: (p) => setState(() => _rebanhoDestino = p),
                    ),

                    const SizedBox(height: 14),

                    const BovFieldLabel(label: 'DATA'),
                    const SizedBox(height: 6),
                    _BovDatePicker(data: _data, onTap: _selecionarData),

                    const SizedBox(height: 24),

                    BovPrimaryButton(
                      label: 'Registrar Movimentação',
                      isLoading: isLoading,
                      onPressed:
                          _rebanhoOrigem == null || _rebanhoDestino == null
                          ? null
                          : () {
                              final ultimoRegistro = ref
                                  .read(historicoAnimalListaProvider)
                                  .value!
                                  .firstWhere(
                                    (registro) =>
                                        registro.tipo != HistoricoTipo.pesagem,
                                  );
                              ref
                                  .read(animaisViewModelProvider.notifier)
                                  .registrarHistoricoMovimento(
                                    tipo: widget.temRebanho
                                        ? HistoricoTipo.mudarRebanho
                                        : HistoricoTipo.entrarRebanho,
                                    pastoOrigemId: ultimoRegistro.pastoOrigemId,
                                    pastoDestinoId: _rebanhoDestino!.pastoId,
                                    data: _data,
                                    rebanhoOrigemId:
                                        ultimoRegistro.rebanhoOrigemId,
                                    rebanhoDestinoId: _rebanhoDestino!.id,
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
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
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
