import 'package:bov_manager/core/theme/app_colors.dart';
import 'package:bov_manager/core/widgets/bov_widgets.dart';
import 'package:bov_manager/models/pasto_model.dart';
import 'package:bov_manager/viewmodels/pasto_viewmodel.dart';
import 'package:bov_manager/viewmodels/propriedade_viewmodel.dart';
import 'package:bov_manager/viewmodels/rebanho_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NovoRebanhoScreen extends ConsumerStatefulWidget {
  const NovoRebanhoScreen({super.key});

  @override
  ConsumerState<NovoRebanhoScreen> createState() => _NovoRebanhoScreenState();
}

class _NovoRebanhoScreenState extends ConsumerState<NovoRebanhoScreen> {
  final _nomeController = TextEditingController();

  PastoModel? _pastoSelecionado;
  List<PastoModel> _pastos = [];
  bool _carregandoPastos = true;

  @override
  void initState() {
    super.initState();
    _carregarPastos();
  }

  Future<void> _carregarPastos() async {
    try {
      final pastos = await ref.read(pastosListaProvider.future);
      if (mounted) setState(() => _pastos = pastos);
    } catch (_) {
      // Lista permanece vazia; o dropdown mostrará hint de erro
    } finally {
      if (mounted) setState(() => _carregandoPastos = false);
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(rebanhoViewModelProvider).isLoading;

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
                        'Novo Rebanho',
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
                    // ── Nome do lote ──────────────────────────────────────
                    const BovFieldLabel(label: 'NOME DO LOTE'),
                    const SizedBox(height: 6),
                    BovTextField(
                      controller: _nomeController,
                      hintText: 'Ex: Lote A — Nelore',
                      textInputAction: TextInputAction.done,
                    ),

                    const SizedBox(height: 14),

                    // ── Pasto associado ───────────────────────────────────
                    const BovFieldLabel(label: 'PASTO ASSOCIADO'),
                    const SizedBox(height: 6),
                    _carregandoPastos
                        ? _DropdownSkeleton()
                        : _pastos.isEmpty
                        ? _DropdownVazio()
                        : _BovDropdown<PastoModel>(
                            value: _pastoSelecionado,
                            items: _pastos,
                            itemLabel: (p) => p.nome,
                            hint: 'Selecione um pasto',
                            onChanged: (p) =>
                                setState(() => _pastoSelecionado = p),
                          ),

                    const SizedBox(height: 28),

                    BovPrimaryButton(
                      label: 'Criar Rebanho',
                      isLoading: isLoading,
                      onPressed: () {
                        if (_pastoSelecionado == null) {
                          showBovErrorSnackBar(
                            context,
                            'Selecione um pasto para o rebanho.',
                          );
                          return;
                        }
                        ref
                            .read(rebanhoViewModelProvider.notifier)
                            .criar(
                              nome: _nomeController.text,
                              pastoId: _pastoSelecionado!.id,
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
          items: items
              .map(
                (item) => DropdownMenuItem<T>(
                  value: item,
                  child: Text(itemLabel(item)),
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
      child: const Row(
        children: [
          Expanded(
            child: Text(
              'Carregando pastos...',
              style: TextStyle(
                color: AppColors.text4,
                fontSize: 14,
                fontFamily: 'DM Sans',
              ),
            ),
          ),
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }
}

class _DropdownVazio extends StatelessWidget {
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
      child: const Row(
        children: [
          Icon(Icons.info_outline_rounded, color: AppColors.text4, size: 16),
          SizedBox(width: 8),
          Text(
            'Nenhum pasto cadastrado',
            style: TextStyle(
              color: AppColors.text4,
              fontSize: 14,
              fontFamily: 'DM Sans',
            ),
          ),
        ],
      ),
    );
  }
}
