import 'package:bov_manager/core/theme/app_colors.dart';
import 'package:bov_manager/core/widgets/bov_widgets.dart';
import 'package:bov_manager/models/pasto_model.dart';
import 'package:bov_manager/viewmodels/pasto_viewmodel.dart';
import 'package:bov_manager/viewmodels/rebanho_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MoverRebanhoScreen extends ConsumerStatefulWidget {
  const MoverRebanhoScreen({super.key});

  @override
  ConsumerState<MoverRebanhoScreen> createState() => _MoverRebanhoScreenState();
}

class _MoverRebanhoScreenState extends ConsumerState<MoverRebanhoScreen> {
  List<PastoModel> _pastos = [];
  PastoModel? _pastoDestino;
  bool _carregandoPastos = true;
  DateTime _data = DateTime.now();

  @override
  void initState() {
    super.initState();
    _carregarPastos();
  }

  Future<void> _carregarPastos() async {
    try {
      final pastos = await ref.read(pastosListaPropEmVisualizacaoProvider.future);
      if (mounted) setState(() => _pastos = pastos);
    } catch (_) {
      // lista permanece vazia
    } finally {
      if (mounted) setState(() => _carregandoPastos = false);
    }
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

  String _formatarData(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final rebanho = ref.watch(rebanhoEmVisualizacaoProvider);
    final isLoading = ref.watch(rebanhoViewModelProvider).isLoading;

    // Pasto atual do rebanho
    final pastoAtual = _pastos
        .where((p) => p.id == rebanho?.pastoId)
        .firstOrNull;

    // Pastos disponíveis para destino (exclui o pasto atual)
    final pastosDestino = _pastos
        .where((p) => p.id != rebanho?.pastoId)
        .toList();

    ref.listen(rebanhoViewModelProvider, (_, next) {
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
                        'Mover Rebanho',
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
                    // ── Card do rebanho ───────────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: AppColors.card,
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
                            child: const Icon(
                              Icons.groups_rounded,
                              color: AppColors.accent,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                rebanho?.nome ?? '—',
                                style: const TextStyle(
                                  color: AppColors.text,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'DM Sans',
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                pastoAtual?.nome ?? '...',
                                style: const TextStyle(
                                  color: AppColors.text4,
                                  fontSize: 12,
                                  fontFamily: 'DM Sans',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // ── Linha Origem → Destino ────────────────────────────
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // ORIGEM (readonly)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const BovFieldLabel(label: 'ORIGEM'),
                              const SizedBox(height: 6),
                              _OrigemDisplay(
                                label: _carregandoPastos
                                    ? '...'
                                    : (pastoAtual?.nome ?? '—'),
                              ),
                            ],
                          ),
                        ),

                        // Seta separadora
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: 12,
                            left: 10,
                            right: 10,
                          ),
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            color: AppColors.accent,
                            size: 22,
                          ),
                        ),

                        // DESTINO (dropdown)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const BovFieldLabel(label: 'DESTINO'),
                              const SizedBox(height: 6),
                              _carregandoPastos
                                  ? _DropdownSkeleton()
                                  : pastosDestino.isEmpty
                                  ? _DropdownVazio()
                                  : _BovDropdown<PastoModel>(
                                      value: _pastoDestino,
                                      items: pastosDestino,
                                      itemLabel: (p) => p.nome,
                                      hint: 'Selecionar',
                                      onChanged: (p) =>
                                          setState(() => _pastoDestino = p),
                                    ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // ── Data da movimentação ──────────────────────────────
                    const BovFieldLabel(label: 'DATA DA MOVIMENTAÇÃO'),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: _selecionarData,
                      child: Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              color: AppColors.text4,
                              size: 16,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _formatarData(_data),
                                style: const TextStyle(
                                  color: AppColors.text,
                                  fontSize: 14,
                                  fontFamily: 'DM Sans',
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: AppColors.text4,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

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
                            'Todos os animais referentes ao pasto registrarão um histórico de movimentação para o novo pasto',
                            style: TextStyle(
                              color: AppColors.text4,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // ── Confirmar ─────────────────────────────────────────
                    BovPrimaryButton(
                      label: 'Confirmar movimentação',
                      isLoading: isLoading,
                      onPressed: rebanho == null || _pastoDestino == null
                          ? null
                          : () {
                              ref
                                  .read(rebanhoViewModelProvider.notifier)
                                  .mover(
                                    rebanhoId: rebanho.id,
                                    antigoPastoId: rebanho.pastoId,
                                    novoPastoId: _pastoDestino!.id,
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
// DISPLAY DE ORIGEM (somente leitura)
// =============================================================================

class _OrigemDisplay extends StatelessWidget {
  const _OrigemDisplay({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.text4,
            fontSize: 14,
            fontFamily: 'DM Sans',
          ),
          overflow: TextOverflow.ellipsis,
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
  });

  final T? value;
  final List<T> items;
  final String Function(T) itemLabel;
  final String hint;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.text4,
            size: 18,
          ),
          dropdownColor: AppColors.card,
          style: const TextStyle(
            color: AppColors.text,
            fontSize: 14,
            fontFamily: 'DM Sans',
          ),
          hint: Text(
            hint,
            style: const TextStyle(
              color: AppColors.text4,
              fontSize: 14,
              fontFamily: 'DM Sans',
            ),
          ),
          onChanged: onChanged,
          items: items
              .map(
                (item) => DropdownMenuItem<T>(
                  value: item,
                  child: Text(itemLabel(item), overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

// =============================================================================
// ESTADOS AUXILIARES DO DROPDOWN
// =============================================================================

class _DropdownSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: const Center(
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.accent,
          ),
        ),
      ),
    );
  }
}

class _DropdownVazio extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: const Center(
        child: Text(
          'Sem outros pastos',
          style: TextStyle(
            color: AppColors.text4,
            fontSize: 13,
            fontFamily: 'DM Sans',
          ),
        ),
      ),
    );
  }
}
