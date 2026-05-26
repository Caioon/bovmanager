import 'package:bov_manager/core/theme/app_colors.dart';
import 'package:bov_manager/view/dashboard_screen.dart';
import 'package:bov_manager/view/home_screen.dart';
import 'package:bov_manager/view/lista_animais_screen.dart';
import 'package:bov_manager/view/propriedade_screen.dart';
import 'package:flutter/material.dart';

// =============================================================================
// SHELL
// =============================================================================

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  final List<Widget> _telas = const [
    DashboardScreen(),
    PropriedadesScreen(),
    ListaAnimaisScreen(),
    HomeScreen(),
  ];

  @override
  Widget build(BuildContext context) {
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
                // onTap: () => {},
              ),
              _BovNavItem(
                icon: Icons.person_rounded,
                label: 'Perfil',
                selecionado: indexAtual == 3,
                onTap: () => onTap(3),
                // onTap: () => {},
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
