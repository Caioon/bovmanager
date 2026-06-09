import 'package:bov_manager/core/navigation/app_coordinator.dart';
import 'package:bov_manager/core/theme/app_colors.dart';
import 'package:bov_manager/core/widgets/bov_widgets.dart';
import 'package:bov_manager/models/animal_model.dart';
import 'package:bov_manager/view/atualizar_historico_screen.dart';
import 'package:bov_manager/viewmodels/animal_viewmodel.dart';
import 'package:bov_manager/viewmodels/historico_animal_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class DetalhesAnimalScreen extends ConsumerStatefulWidget {
  const DetalhesAnimalScreen({super.key});

  @override
  ConsumerState<DetalhesAnimalScreen> createState() =>
      _DetalhesAnimalScreenState();
}

class _DetalhesAnimalScreenState extends ConsumerState<DetalhesAnimalScreen> {
  @override
  void initState() {
    super.initState();
    ref.listenManual(animaisViewModelProvider, (_, next) {
      next.whenOrNull(
        error: (e, _) => showBovErrorSnackBar(context, e.toString()),
      );
    });
  }

  @override
  void dispose() {
    ref.read(animalEmVisualizacaoProvider.notifier).fechar();
    super.dispose();
  }

  int _idadeAnos(DateTime dataNascimento) {
    final hoje = DateTime.now();
    int anos = hoje.year - dataNascimento.year;
    if (hoje.month < dataNascimento.month ||
        (hoje.month == dataNascimento.month && hoje.day < dataNascimento.day)) {
      anos--;
    }
    return anos;
  }

  @override
  Widget build(BuildContext context) {
    final animal = ref.watch(animalEmVisualizacaoProvider);

    if (animal == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final dataCadastro = DateFormat('MMM yyyy').format(animal.dataNascimento);

    final historicos = ref.watch(historicoAnimalListaProvider).value;

    String? rebanhoId;

    if (historicos != null) {
      for (final registro in historicos) {
        if (registro.tipo != 'Pesagem') {
          rebanhoId = registro.rebanhoDestinoId;
          break;
        }
      }
    }
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
                        'Detalhes do Animal',
                        style: TextStyle(
                          color: AppColors.text,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'DM Sans',
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _showActionsMenu(context, ref, animal),
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
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                child: Column(
                  children: [
                    // ── Avatar ────────────────────────────────────────────
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: AppColors.accentBg,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(
                        Icons.pets_rounded,
                        color: AppColors.accent,
                        size: 40,
                      ),
                    ),

                    const SizedBox(height: 14),

                    Text(
                      animal.nome.isNotEmpty
                          ? animal.nome
                          : 'Brinco #${animal.brinco}',
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'DM Sans',
                      ),
                    ),

                    const SizedBox(height: 6),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accentBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        animal.raca,
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'DM Sans',
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Métricas ──────────────────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: _MetricCard(
                            value: '${animal.pesoAtual.toStringAsFixed(0)}kg',
                            label: 'Peso Atual',
                            valueColor: AppColors.accent,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _MetricCard(
                            value: '${_idadeAnos(animal.dataNascimento)}a',
                            label: 'Idade',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // ── Infos ─────────────────────────────────────────────
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          _InfoRow(
                            icon: Icons.tag_rounded,
                            label: 'Brinco',
                            value: '#${animal.brinco}',
                            isFirst: true,
                          ),

                          _InfoRow(
                            icon: Icons.groups_outlined,
                            label: 'Rebanho',
                            value: rebanhoId ?? 'Sem rebanho',
                          ),
                          _InfoRow(
                            icon: Icons.calendar_today_rounded,
                            label: 'Nascimento',
                            value: dataCadastro,
                            isLast: true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Ações ─────────────────────────────────────────────
                    BovSecondaryButton(
                      label: 'Ver Histórico',
                      icon: Icons.history_rounded,
                      onPressed: () =>
                          AppCoordinator.goToHistoricoAnimal(context),
                    ),

                    const SizedBox(height: 10),

                    BovSecondaryButton(
                      label: 'Atualizar Histórico',
                      icon: Icons.edit_note_rounded,
                      onPressed: () => showAtualizarHistoricoModal(
                        context,
                        rebanhoId != null,
                      ),
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
  // MENU DE AÇÕES
  // ===========================================================================

  void _showActionsMenu(
    BuildContext context,
    WidgetRef ref,
    AnimalModel animal,
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
              BovDangerButton(
                label: 'Apagar Animal',
                icon: Icons.delete_outline_rounded,
                onPressed: () {
                  Navigator.of(context).pop();
                  _showConfirmarApagar(context, ref, animal);
                },
              ),
            ],
          ),
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
    AnimalModel animal,
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
          'Apagar animal?',
          style: TextStyle(
            color: AppColors.text,
            fontSize: 17,
            fontWeight: FontWeight.w700,
            fontFamily: 'DM Sans',
          ),
        ),
        content: Text(
          'Essa ação é irreversível. Todos os dados de "${animal.nome.isNotEmpty ? animal.nome : '#${animal.brinco}'}" serão apagados permanentemente.',
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
                    .read(animaisViewModelProvider.notifier)
                    .apagar(animalId: animal.id);
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

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.value,
    required this.label,
    this.valueColor,
  });

  final String value;
  final String label;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
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
              fontSize: 24,
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
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isFirst = false,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
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
            child: Icon(icon, color: AppColors.text4, size: 14),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.text4,
              fontSize: 13,
              fontFamily: 'DM Sans',
            ),
          ),
          const Spacer(),
          Text(
            value,
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
