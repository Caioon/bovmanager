import 'package:bov_manager/core/theme/app_colors.dart';
import 'package:bov_manager/models/tarefa_model.dart';
import 'package:bov_manager/services/notification_service.dart';
import 'package:bov_manager/view/dashboard_screen.dart';
import 'package:bov_manager/view/lista_animais_screen.dart';
import 'package:bov_manager/view/perfil_screen.dart';
import 'package:bov_manager/view/propriedade_screen.dart';
import 'package:bov_manager/viewmodels/propriedade_viewmodel.dart';
import 'package:bov_manager/viewmodels/tarefa_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// =============================================================================
// SHELL
// =============================================================================

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _index = 0;

  /// Evita reagendar notificações mais de uma vez por sessão por propriedade.
  /// É resetado sempre que a propriedade selecionada muda, garantindo que
  /// tarefas de uma nova propriedade também sejam sincronizadas.
  String? _propriedadeSincronizada;

  final List<Widget> _telas = const [
    DashboardScreen(),
    PropriedadesScreen(),
    ListaAnimaisScreen(),
    PerfilScreen(),
  ];

  @override
  void initState() {
    super.initState();
  }

  // ---------------------------------------------------------------------------
  // Sincronização de notificações (item 5)
  // ---------------------------------------------------------------------------
  //
  // Lógica:
  //   1. Observa tarefasListaProvider via ref.listen
  //   2. Na primeira emissão de dados após abertura do app (ou troca de prop.):
  //      a. Busca os IDs de notificações pendentes no AlarmManager
  //      b. Para cada tarefa pendente com data futura, verifica se algum dos
  //         6 slots já está agendado
  //      c. Se nenhum slot estiver pendente, agenda as notificações da tarefa
  //   3. Marca a propriedade como sincronizada para não repetir na mesma sessão
  //
  // Não cancela notificações existentes — apenas adiciona as que faltam.

  Future<void> _sincronizarNotificacoes() async {
    final tarefas = ref.read(tarefasListaProvider).asData?.value;
    if (tarefas == null) return;

    final notificationService = ref.read(notificationServiceProvider);
    await notificationService.init();

    // Busca todos os IDs de notificações pendentes no AlarmManager
    final pendingRequests =
        await notificationService.buscarIdsPendentes();
    final pendingIds = pendingRequests.toSet();

    final agora = DateTime.now();

    for (final tarefa in tarefas) {
      if (tarefa.status != StatusTarefa.pendente) continue;
      if (!tarefa.dataExecucao.isAfter(agora)) continue;

      // Calcula o baseId usando a mesma fórmula do NotificationService
      final baseId = notificationService.calcularBaseId(tarefa.id);

      // Verifica se algum dos 6 slots já está agendado
      final jaAgendada = List.generate(6, (i) => baseId + i)
          .any((id) => pendingIds.contains(id));

      if (!jaAgendada) {
        await notificationService.agendarNotificacaoTarefa(tarefa);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Observa mudança de propriedade para resetar o flag de sincronização
    final propriedadeId = ref
        .watch(propriedadeSelecionadaProvider)
        .asData
        ?.value
        ?.id;

    // Observa a lista de tarefas e sincroniza notificações na primeira emissão
    // de dados por propriedade
    ref.listen(tarefasListaProvider, (previous, next) {
      if (next is AsyncData) {
        // Reseta o flag se a propriedade mudou
        if (propriedadeId != _propriedadeSincronizada) {
          _propriedadeSincronizada = null;
        }

        if (_propriedadeSincronizada == null && propriedadeId != null) {
          _propriedadeSincronizada = propriedadeId;
          _sincronizarNotificacoes();
        }
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(index: _index, children: _telas),
      bottomNavigationBar: _BovBottomNav(
        indexAtual: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}

// =============================================================================
// BOTTOM NAV BAR
// =============================================================================

class _BovBottomNav extends StatelessWidget {
  const _BovBottomNav({required this.indexAtual, required this.onTap});

  final int indexAtual;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              _BovNavItem(
                icon: Icons.dashboard_rounded,
                label: 'Dashboard',
                selecionado: indexAtual == 0,
                onTap: () => onTap(0),
              ),
              _BovNavItem(
                icon: Icons.home_work_rounded,
                label: 'Propriedades',
                selecionado: indexAtual == 1,
                onTap: () => onTap(1),
              ),
              _BovNavItem(
                icon: Icons.pets,
                label: 'Animais',
                selecionado: indexAtual == 2,
                onTap: () => onTap(2),
              ),
              _BovNavItem(
                icon: Icons.person_rounded,
                label: 'Perfil',
                selecionado: indexAtual == 3,
                onTap: () => onTap(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// ITEM DA NAV BAR
// =============================================================================

class _BovNavItem extends StatelessWidget {
  const _BovNavItem({
    required this.icon,
    required this.label,
    required this.selecionado,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selecionado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: selecionado ? AppColors.accentBg : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: selecionado ? AppColors.accent : AppColors.text4,
                ),
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  color: selecionado ? AppColors.accent : AppColors.text4,
                  fontSize: 10,
                  fontWeight: selecionado ? FontWeight.w600 : FontWeight.w400,
                  fontFamily: 'DM Sans',
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
