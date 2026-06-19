import 'package:bov_manager/core/theme/app_colors.dart';
import 'package:bov_manager/core/widgets/bov_widgets.dart';
import 'package:bov_manager/repositories/usuario_repository.dart';
import 'package:bov_manager/viewmodels/usuario_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(usuarioViewModelProvider);
    final usuario = ref.watch(usuarioAtualProvider).value;
    if (usuario == null) {
      return Center(child: CircularProgressIndicator(color: AppColors.accent));
    }

    final nomeUsuario = usuario.nome;
    final isLoadingLogout = state.isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(),

              // ── Logo central ───────────────────────────────────────────
              const BovLogo(),

              const SizedBox(height: 40),

              // ── Boas-vindas ────────────────────────────────────────────
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'DM Sans',
                  ),
                  children: [
                    const TextSpan(
                      text: 'Bem-vindo, ',
                      style: TextStyle(color: AppColors.text),
                    ),
                    TextSpan(
                      text: '$nomeUsuario!',
                      style: const TextStyle(color: AppColors.accent),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Você está conectado ao BovManager.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.text4,
                  fontSize: 14,
                  fontFamily: 'DM Sans',
                ),
              ),

              const Spacer(),

              // ── Botão Logout ───────────────────────────────────────────
              BovDangerButton(
                label: 'Sair da conta',
                icon: Icons.logout_rounded,
                isLoading: isLoadingLogout,
                onPressed: () {
                  ref.read(usuarioViewModelProvider.notifier).logout();
                },
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
