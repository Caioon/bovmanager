import 'package:bov_manager/core/theme/app_colors.dart';
import 'package:bov_manager/core/widgets/bov_widgets.dart';
import 'package:bov_manager/models/pasto_model.dart';
import 'package:bov_manager/services/pasto_service.dart';
import 'package:bov_manager/viewmodels/animal_viewmodel.dart';
import 'package:bov_manager/viewmodels/pasto_viewmodel.dart';
import 'package:bov_manager/viewmodels/propriedade_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// =============================================================================
// MODAL DE SELEÇÃO — chamado pelo DetalhesAnimalScreen
// =============================================================================

void showAtualizarHistoricoModal(BuildContext context) {
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
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) =>
                          const _RegistrarPesagemScreen(),
                      transitionDuration: const Duration(milliseconds: 300),
                      transitionsBuilder: (_, animation, __, child) {
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

              // ── Movimentação ─────────────────────────────────────────────
              _ModalOpcao(
                icon: Icons.arrow_forward_rounded,
                titulo: 'Movimentação',
                subtitulo: 'Registrar troca de pasto',
                onTap: () async {
                  // Fecha o modal de seleção antes de qualquer I/O
                  Navigator.of(ctx).pop();

                  final propriedadeId =
                      ref.read(propriedadeEmVisualizacaoProvider)?.id ?? '';

                  final pastos = await ref.read(pastosListaProvider.future);

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
                      pageBuilder: (_, __, ___) =>
                          _RegistrarMovimentacaoScreen(pastos: pastos),
                      transitionDuration: const Duration(milliseconds: 300),
                      transitionsBuilder: (_, animation, __, child) {
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
                    // Peso atual como referência
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

                    // ── Novo Peso e Data ──────────────────────────────────
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
                            .registrarPesagem(novoPeso: novoPeso, data: _data);
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
// TELA — REGISTRAR MOVIMENTAÇÃO
// =============================================================================

class _RegistrarMovimentacaoScreen extends ConsumerStatefulWidget {
  const _RegistrarMovimentacaoScreen({required this.pastos});

  final List<PastoModel> pastos;

  @override
  ConsumerState<_RegistrarMovimentacaoScreen> createState() =>
      _RegistrarMovimentacaoScreenState();
}

class _RegistrarMovimentacaoScreenState
    extends ConsumerState<_RegistrarMovimentacaoScreen> {
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

    // Opções de destino excluem o pasto já selecionado como origem
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
            // ── Header ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  BovBackButton(),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Registrar Movimentação',
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
                    // ── Pasto Origem ──────────────────────────────────────
                    const BovFieldLabel(label: 'PASTO ORIGEM'),
                    const SizedBox(height: 6),
                    _BovDropdown<PastoModel>(
                      value: _origem,
                      items: widget.pastos,
                      itemLabel: (p) => p.nome,
                      hint: 'Selecionar pasto de origem...',
                      onChanged: (p) => setState(() {
                        _origem = p;
                        // Limpa destino se for o mesmo que o novo origem
                        if (_destino?.id == p?.id) _destino = null;
                      }),
                    ),

                    const SizedBox(height: 14),

                    // ── Pasto Destino ─────────────────────────────────────
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

                    // ── Data ──────────────────────────────────────────────
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
                                  .registrarMovimentacao(
                                    pastoOrigemId: _origem!.id,
                                    pastoDestinoId: _destino!.id,
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
