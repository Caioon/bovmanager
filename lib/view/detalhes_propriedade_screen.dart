import 'package:bov_manager/core/navigation/app_coordinator.dart';
import 'package:bov_manager/core/theme/app_colors.dart';
import 'package:bov_manager/core/widgets/bov_widgets.dart';
import 'package:bov_manager/models/propriedade_model.dart';
import 'package:bov_manager/view/relatorio_screen.dart';
import 'package:bov_manager/viewmodels/animal_viewmodel.dart';
import 'package:bov_manager/viewmodels/pasto_viewmodel.dart';
import 'package:bov_manager/viewmodels/propriedade_viewmodel.dart';
import 'package:bov_manager/viewmodels/rebanho_viewmodel.dart';
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
  late final PropriedadeEmVisualizacao _propriedadeEmVisualizacaoNotifier;

  @override
  void initState() {
    super.initState();

    _propriedadeEmVisualizacaoNotifier = ref.read(
      propriedadeEmVisualizacaoProvider.notifier,
    );

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
    // Não altera o provider de forma síncrona aqui: esta tela observa
    // propriedadeEmVisualizacaoProvider (e providers derivados dele), então
    // mudar o estado durante o dispose notifica o próprio elemento, que já
    // está "defunct" mas ainda tem as assinaturas abertas. Adiar para o fim do
    // microtask garante que o Riverpod já fechou essas assinaturas.
    final notifier = _propriedadeEmVisualizacaoNotifier;
    Future.microtask(notifier.fechar);
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

    final animaisAsync = ref.watch(animaisListaPropEmVisProvider);
    final pastosAsync = ref.watch(pastosListaPropEmVisualizacaoProvider);
    final rebanhoAsync = ref.watch(rebanhoListaProvider);

    final totalAnimais = animaisAsync.value?.length ?? 0;
    final totalPastos = pastosAsync.value?.length ?? 0;
    final totalRebanhos = rebanhoAsync.value?.length ?? 0;
    // TODO: calcular alertas (atividades cuja data para finalizar é anterior a data de hoje)
    const totalAlertas = 0;

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
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          propriedadeAtual.nome,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.text,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'DM Sans',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () =>
                        _showActionsMenu(context, ref, propriedadeAtual),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(
                        Icons.edit_outlined,
                        color: AppColors.text,
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
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cadastrada em $dataCadastro',
                      style: const TextStyle(
                        color: AppColors.text4,
                        fontSize: 13,
                        fontFamily: 'DM Sans',
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Botões de mapa ────────────────────────────────────
                    if (!propriedadeAtual.temCentroDefinido)
                      _MapButton(
                        label: 'Adicionar mapa para propriedade',
                        icon: Icons.add_location_alt_outlined,
                        destacado: true,
                        onTap: () => AppCoordinator.goToConfigurarMapa(
                          context,
                          emVisualizacao: true,
                        ),
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: _MapButton(
                              label: 'Ajustar mapa',
                              icon: Icons.settings_outlined,
                              onTap: () => AppCoordinator.goToConfigurarMapa(
                                context,
                                emVisualizacao: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _MapButton(
                              label: 'Ver mapa',
                              icon: Icons.map_outlined,
                              destacado: true,
                              onTap: () =>
                                  AppCoordinator.goToMapa(context, emVisualizacao: true),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        _MetricItem(
                          value: animaisAsync.isLoading
                              ? '—'
                              : totalAnimais.toString(),
                          label: 'Animais',
                          onTap: () {},
                        ),
                        const SizedBox(width: 10),
                        _MetricItem(
                          value: rebanhoAsync.isLoading
                              ? '—'
                              : totalRebanhos.toString(),
                          label: 'Rebanhos',
                          onTap: () =>
                              AppCoordinator.goToListaRebanhos(context),
                        ),
                        const SizedBox(width: 10),
                        _MetricItem(
                          value: pastosAsync.isLoading
                              ? '—'
                              : totalPastos.toString(),
                          label: 'Pastos',
                          onTap: () => AppCoordinator.goToListaPastos(context),
                        ),
                        const SizedBox(width: 10),
                        _MetricItem(
                          value: totalAlertas.toString(),
                          label: 'Alertas',
                          onTap: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── Criar relatório ───────────────────────────────────
                    _ReportButton(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => RelatorioScreen(
                              propriedade: propriedadeAtual,
                            ),
                          ),
                        );
                      },
                    ),

                    // ── Alertas importantes ───────────────────────────────
                    const _SectionTitle(title: 'Alertas importantes'),
                    const Text(
                      'Nenhum alerta no momento',
                      style: TextStyle(
                        color: AppColors.text4,
                        fontSize: 14,
                        fontFamily: 'DM Sans',
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

/// Botão largo dos mapas. [destacado] usa o tom de acento preenchido.
class _MapButton extends StatelessWidget {
  const _MapButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.destacado = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool destacado;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: destacado ? AppColors.accentBg : AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: destacado ? AppColors.accentBg : AppColors.accent.withAlpha(110),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.accent, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.accent,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'DM Sans',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  const _MetricItem({
    required this.value,
    required this.label,
    required this.onTap,
  });

  final String value;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                  fontFamily: 'DM Sans',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.text4,
                  fontSize: 12,
                  fontFamily: 'DM Sans',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Card largo "Criar relatório" com chevron à direita.
class _ReportButton extends StatelessWidget {
  const _ReportButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.accentBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.upload_file_rounded,
                color: AppColors.accent,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Text(
                'Criar relatório',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'DM Sans',
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.text2,
              size: 22,
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
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.text,
          fontSize: 18,
          fontWeight: FontWeight.w700,
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
