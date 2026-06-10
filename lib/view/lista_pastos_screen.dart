import 'package:bov_manager/core/navigation/app_coordinator.dart';
import 'package:bov_manager/core/theme/app_colors.dart';
import 'package:bov_manager/core/widgets/bov_widgets.dart';
import 'package:bov_manager/models/pasto_model.dart';
import 'package:bov_manager/viewmodels/pasto_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ListaPastosScreen extends ConsumerWidget {
  const ListaPastosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listaState = ref.watch(pastosListaPropEmVisualizacaoProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      BovBackButton(),
                      const SizedBox(width: 12),
                      const Text(
                        'Pastos',
                        style: TextStyle(
                          color: AppColors.text,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'DM Sans',
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => AppCoordinator.goToNovoPasto(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        color: AppColors.text2,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Corpo ─────────────────────────────────────────────────────
            Expanded(
              child: listaState.when(
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
                data: (lista) {
                  if (lista.isEmpty) return const _EmptyState();

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                    itemCount: lista.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 1),
                    itemBuilder: (context, i) => _PastoItem(
                      pasto: lista[i],
                      isFirst: i == 0,
                      isLast: i == lista.length - 1,
                      onTap: () {
                        ref
                            .read(pastoEmVisualizacaoProvider.notifier)
                            .abrir(lista[i]);
                        _showDetalhesPasto(context, ref, lista[i]);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // BOTTOM SHEET DE DETALHES / AÇÕES
  // ===========================================================================

  void _showDetalhesPasto(
    BuildContext context,
    WidgetRef ref,
    PastoModel pasto,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
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

              // Nome e área
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.accentBg,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.grass_rounded,
                      color: AppColors.accent,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pasto.nome,
                          style: const TextStyle(
                            color: AppColors.text,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'DM Sans',
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${pasto.area.toStringAsFixed(1)} ha',
                          style: const TextStyle(
                            color: AppColors.text4,
                            fontSize: 13,
                            fontFamily: 'DM Sans',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              if (pasto.descricao.isNotEmpty) ...[
                const SizedBox(height: 14),
                Text(
                  pasto.descricao,
                  style: const TextStyle(
                    color: AppColors.text4,
                    fontSize: 13,
                    fontFamily: 'DM Sans',
                  ),
                ),
              ],

              const SizedBox(height: 20),

              BovSecondaryButton(
                label: 'Editar Pasto',
                icon: Icons.edit_outlined,
                onPressed: () {
                  Navigator.of(context).pop();
                  _showEditarModal(context, ref, pasto);
                },
              ),
              const SizedBox(height: 8),
              BovDangerButton(
                label: 'Apagar Pasto',
                icon: Icons.delete_outline_rounded,
                onPressed: () {
                  Navigator.of(context).pop();
                  _showConfirmarApagar(context, ref, pasto);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // MODAL DE EDIÇÃO
  // ===========================================================================

  void _showEditarModal(
    BuildContext context,
    WidgetRef ref,
    PastoModel pasto,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _EditarPastoModal(
        pasto: pasto,
        onSalvar: (nome, area, descricao) => ref
            .read(pastosViewModelProvider.notifier)
            .editar(
              pastoId: pasto.id,
              nome: nome,
              area: area,
              descricao: descricao,
            ),
      ),
    );
  }

  // ===========================================================================
  // DIÁLOGO DE EXCLUSÃO
  // ===========================================================================

  void _showConfirmarApagar(
    BuildContext context,
    WidgetRef ref,
    PastoModel pasto,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
        title: const Text(
          'Apagar pasto?',
          style: TextStyle(
            color: AppColors.text,
            fontSize: 17,
            fontWeight: FontWeight.w700,
            fontFamily: 'DM Sans',
          ),
        ),
        content: Text(
          'A ação é irreversível. O pasto "${pasto.nome}" será apagado permanentemente.',
          style: const TextStyle(
            color: AppColors.text4,
            fontSize: 14,
            fontFamily: 'DM Sans',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppColors.text4, fontFamily: 'DM Sans'),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref
                  .read(pastosViewModelProvider.notifier)
                  .apagar(pastoId: pasto.id);
            },
            child: const Text(
              'Apagar',
              style: TextStyle(
                color: AppColors.red,
                fontWeight: FontWeight.w600,
                fontFamily: 'DM Sans',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// ITEM DA LISTA
// =============================================================================

class _PastoItem extends StatelessWidget {
  const _PastoItem({
    required this.pasto,
    required this.onTap,
    required this.isFirst,
    required this.isLast,
  });

  final PastoModel pasto;
  final VoidCallback onTap;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final bool vazio = pasto.descricao.isEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.vertical(
            top: isFirst ? const Radius.circular(12) : Radius.zero,
            bottom: isLast ? const Radius.circular(12) : Radius.zero,
          ),
          border: Border(
            left: const BorderSide(color: AppColors.border),
            right: const BorderSide(color: AppColors.border),
            top: isFirst
                ? const BorderSide(color: AppColors.border)
                : BorderSide.none,
            bottom: const BorderSide(color: AppColors.border),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: vazio ? AppColors.border2 : AppColors.accentBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.grass_rounded,
                color: vazio ? AppColors.text4 : AppColors.accent,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pasto.nome,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'DM Sans',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${pasto.area.toStringAsFixed(1)} ha'
                    '${pasto.descricao.isNotEmpty ? ' · ${pasto.descricao}' : ''}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
// EMPTY STATE
// =============================================================================

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.accentBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.grass_rounded,
              color: AppColors.accent,
              size: 34,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Nenhum pasto',
            style: TextStyle(
              color: AppColors.text,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFamily: 'DM Sans',
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Cadastre o primeiro pasto desta\npropriedade para começar.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.text4,
              fontSize: 13,
              fontFamily: 'DM Sans',
            ),
          ),
          const SizedBox(height: 28),
          BovPrimaryButton(
            label: 'Cadastrar Pasto',
            onPressed: () => AppCoordinator.goToNovoPasto(context),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// MODAL DE EDIÇÃO
// =============================================================================

class _EditarPastoModal extends StatefulWidget {
  const _EditarPastoModal({
    required this.pasto,
    required this.onSalvar,
  });

  final PastoModel pasto;
  final Future<void> Function(String nome, double area, String descricao)
      onSalvar;

  @override
  State<_EditarPastoModal> createState() => _EditarPastoModalState();
}

class _EditarPastoModalState extends State<_EditarPastoModal> {
  late final TextEditingController _nomeCtrl;
  late final TextEditingController _areaCtrl;
  late final TextEditingController _descricaoCtrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nomeCtrl = TextEditingController(text: widget.pasto.nome);
    _areaCtrl = TextEditingController(
      text: widget.pasto.area > 0
          ? widget.pasto.area.toStringAsFixed(2)
          : '',
    );
    _descricaoCtrl = TextEditingController(text: widget.pasto.descricao);
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _areaCtrl.dispose();
    _descricaoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
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
          const Text(
            'Editar Pasto',
            style: TextStyle(
              color: AppColors.text,
              fontSize: 17,
              fontWeight: FontWeight.w600,
              fontFamily: 'DM Sans',
            ),
          ),
          const SizedBox(height: 20),
          const BovFieldLabel(label: 'NOME DO PASTO'),
          const SizedBox(height: 6),
          BovTextField(
            controller: _nomeCtrl,
            hintText: 'Ex: Pasto Norte A',
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 14),
          const BovFieldLabel(label: 'TAMANHO (HECTARES)'),
          const SizedBox(height: 6),
          BovTextField(
            controller: _areaCtrl,
            hintText: '0.00',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 14),
          const BovFieldLabel(label: 'DESCRIÇÃO'),
          const SizedBox(height: 6),
          BovTextField(
            controller: _descricaoCtrl,
            hintText: 'Observações sobre o pasto...',
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 20),
          BovPrimaryButton(
            label: 'Salvar Alterações',
            isLoading: _isLoading,
            onPressed: () async {
              setState(() => _isLoading = true);
              final navigator = Navigator.of(context);
              await widget.onSalvar(
                _nomeCtrl.text,
                double.tryParse(_areaCtrl.text) ?? 0.0,
                _descricaoCtrl.text,
              );
              navigator.pop();
            },
          ),
        ],
      ),
    );
  }
}
