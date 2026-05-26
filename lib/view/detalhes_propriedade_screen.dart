import 'package:bov_manager/core/navigation/app_coordinator.dart';
import 'package:bov_manager/core/theme/app_colors.dart';
import 'package:bov_manager/core/widgets/bov_widgets.dart';
import 'package:bov_manager/models/propriedade_model.dart';
import 'package:bov_manager/viewmodels/propriedade_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class DetalhesPropriedadeScreen extends ConsumerStatefulWidget {
  const DetalhesPropriedadeScreen({super.key});

  @override
  ConsumerState<DetalhesPropriedadeScreen> createState() =>
      _DetalhesPropriedadeScreenState();
}

class _DetalhesPropriedadeScreenState
    extends ConsumerState<DetalhesPropriedadeScreen> {
  @override
  void initState() {
    super.initState();

    ref.listenManual(propriedadesViewModelProvider, (_, next) {
      next.whenOrNull(
        error: (e, _) {
          showBovErrorSnackBar(context, e.toString());
        },
      );
    });
  }

  @override
  void dispose() {
    ref.read(propriedadeEmVisualizacaoProvider.notifier).fechar();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final propriedadeAtual = ref.watch(propriedadeEmVisualizacaoProvider);

    if (propriedadeAtual == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final dataCadastro = DateFormat(
      'dd/MM/yyyy',
    ).format(propriedadeAtual.dataCadastro);

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
                        propriedadeAtual.nome,
                        style: const TextStyle(
                          color: AppColors.text,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'DM Sans',
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () =>
                        _showActionsMenu(context, ref, propriedadeAtual),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(
                        Icons.more_horiz_rounded,
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card de info principal
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: AppColors.accentBg,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.home_work_rounded,
                              color: AppColors.accent,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                propriedadeAtual.nome,
                                style: const TextStyle(
                                  color: AppColors.text,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'DM Sans',
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Cadastrada em $dataCadastro',
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

                    // Métricas — dependem de subcoleções futuras
                    const _SectionTitle(title: 'RESUMO'),
                    Row(
                      children: [
                        _MetricTile(
                          // TODO: buscar totalPastos da subcoleção pastos
                          value: '-',
                          label: 'Pastos',
                        ),
                        const SizedBox(width: 10),
                        _MetricTile(
                          // TODO: buscar totalRebanhos da subcoleção rebanhos
                          value: '-',
                          label: 'Rebanhos',
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _MetricTile(
                          // TODO: buscar totalAnimais da subcoleção animais
                          value: '-',
                          label: 'Animais',
                        ),
                        const SizedBox(width: 10),
                        _MetricTile(
                          // TODO: calcular alertas (ex: superlotação de pastos)
                          value: '-',
                          label: 'Alertas',
                        ),
                      ],
                    ),

                    // Atalhos rápidos
                    const _SectionTitle(title: 'ATALHOS RÁPIDOS'),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 2.8,
                      children: [
                        _ShortcutCard(
                          icon: Icons.map_outlined,
                          label: 'Mapa',
                          iconBgColor: AppColors.accentBg,
                          iconColor: AppColors.accent,
                          onTap: () {
                            // TODO: AppCoordinator.goToMapa(context, propriedadeAtual);
                          },
                        ),
                        _ShortcutCard(
                          icon: Icons.grass_rounded,
                          label: 'Pastos',
                          iconBgColor: AppColors.accentBg,
                          iconColor: AppColors.accent,
                          onTap: () => AppCoordinator.goToListaPastos(context),
                        ),
                        _ShortcutCard(
                          icon: Icons.groups_outlined,
                          label: 'Rebanhos',
                          onTap: () {
                            AppCoordinator.goToListaRebanhos(context);
                          },
                        ),
                        _ShortcutCard(
                          icon: Icons.upload_file_rounded,
                          label: 'Relatório',
                          onTap: () {
                            // TODO: AppCoordinator.goToRelatorio(context, propriedadeAtual);
                          },
                        ),
                      ],
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

  // ===========================================================================
  // MENU DE AÇÕES (···)
  // ===========================================================================

  void _showActionsMenu(
    BuildContext context,
    WidgetRef ref,
    PropriedadeModel propriedadeAtual,
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
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              BovSecondaryButton(
                label: 'Editar Propriedade',
                icon: Icons.edit_outlined,
                onPressed: () {
                  Navigator.of(context).pop();
                  _showEditarModal(context, ref, propriedadeAtual);
                },
              ),

              const SizedBox(height: 10),

              BovDangerButton(
                label: 'Apagar Propriedade',
                icon: Icons.delete_outline_rounded,
                onPressed: () {
                  Navigator.of(context).pop();
                  _showConfirmarApagar(context, ref, propriedadeAtual);
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
    PropriedadeModel propriedadeAtual,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _EditarPropriedadeModal(
        nomeInicial: propriedadeAtual.nome,
        onSalvar: (nome) => ref
            .read(propriedadesViewModelProvider.notifier)
            .editar(propriedadeId: propriedadeAtual.id, nome: nome),
      ),
    );
  }
  // ===========================================================================
  // DIÁLOGO DE EXCLUSÃO
  // ===========================================================================

  void _showConfirmarApagar(
    BuildContext context,
    WidgetRef ref,
    PropriedadeModel propriedadeAtual,
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
          'Apagar propriedade?',
          style: TextStyle(
            color: AppColors.text,
            fontSize: 17,
            fontWeight: FontWeight.w700,
            fontFamily: 'DM Sans',
          ),
        ),
        content: Text(
          'Essa ação é irreversível. Todos os dados de "${propriedadeAtual.nome}" serão apagados permanentemente.',
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

              if (context.mounted) {
                Navigator.of(context).pop();

                await ref
                    .read(propriedadesViewModelProvider.notifier)
                    .apagar(propriedadeId: propriedadeAtual.id);
              }
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
// WIDGETS INTERNOS
// =============================================================================

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.value,
    required this.label,
    this.valueColor,
  });

  final String value;
  final String label;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: valueColor ?? AppColors.text,
                fontSize: 26,
                fontWeight: FontWeight.w700,
                fontFamily: 'DM Sans',
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.text4,
                fontSize: 11,
                fontFamily: 'DM Sans',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShortcutCard extends StatelessWidget {
  const _ShortcutCard({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconBgColor = AppColors.border2,
    this.iconColor = AppColors.text4,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color iconBgColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 16),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                fontFamily: 'DM Sans',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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

class _EditarPropriedadeModal extends StatefulWidget {
  const _EditarPropriedadeModal({
    required this.nomeInicial,
    required this.onSalvar,
  });

  final String nomeInicial;
  final Future<void> Function(String nome) onSalvar;

  @override
  State<_EditarPropriedadeModal> createState() =>
      _EditarPropriedadeModalState();
}

class _EditarPropriedadeModalState extends State<_EditarPropriedadeModal> {
  late final TextEditingController _nomeCtrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nomeCtrl = TextEditingController(text: widget.nomeInicial);
  }

  @override
  void dispose() {
    _nomeCtrl.dispose(); // Flutter chama isso no momento certo
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
            'Editar Propriedade',
            style: TextStyle(
              color: AppColors.text,
              fontSize: 17,
              fontWeight: FontWeight.w600,
              fontFamily: 'DM Sans',
            ),
          ),
          const SizedBox(height: 20),
          const BovFieldLabel(label: 'NOME DA FAZENDA'),
          const SizedBox(height: 6),
          BovTextField(
            controller: _nomeCtrl,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 20),
          BovPrimaryButton(
            label: 'Salvar Alterações',
            isLoading: _isLoading,
            onPressed: () async {
              setState(() => _isLoading = true);
              final navigator = Navigator.of(context);
              await widget.onSalvar(_nomeCtrl.text);
              navigator.pop();
            },
          ),
        ],
      ),
    );
  }
}
