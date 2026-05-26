import 'package:bov_manager/core/navigation/app_coordinator.dart';
import 'package:bov_manager/core/theme/app_colors.dart';
import 'package:bov_manager/core/widgets/bov_widgets.dart';
import 'package:bov_manager/repositories/usuario_repository.dart';
import 'package:bov_manager/viewmodels/usuario_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  // Estado local de visibilidade da senha — puramente UI
  bool _obscureSenha = true;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Observa o estado do ViewModel
    final state = ref.watch(usuarioViewModelProvider);
    final isLoading = state.isLoading;

    ref.listen(usuarioViewModelProvider, (_, next) {
      next.whenOrNull(
        error: (e, _) => showBovErrorSnackBar(context, e.toString()),
      );
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 64),

              // ── Logo ──────────────────────────────────────────────────────
              const Center(child: BovLogo()),

              const SizedBox(height: 48),

              // ── Título ────────────────────────────────────────────────────
              const Text(
                'Bem-vindo de volta',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'DM Sans',
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Entre na sua conta',
                style: TextStyle(
                  color: AppColors.text4,
                  fontSize: 14,
                  fontFamily: 'DM Sans',
                ),
              ),

              const SizedBox(height: 28),

              // ── E-mail ────────────────────────────────────────────────────
              const BovFieldLabel(label: 'E-MAIL'),
              const SizedBox(height: 6),
              BovTextField(
                controller: _emailController,
                hintText: 'produtor@fazenda.com',
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),

              const SizedBox(height: 14),

              // ── Senha ─────────────────────────────────────────────────────
              const BovFieldLabel(label: 'SENHA'),
              const SizedBox(height: 6),
              BovTextField(
                controller: _senhaController,
                hintText: 'Mínimo 8 caracteres',
                obscureText: _obscureSenha,
                textInputAction: TextInputAction.done,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureSenha
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.text4,
                    size: 20,
                  ),
                  onPressed: () =>
                      setState(() => _obscureSenha = !_obscureSenha),
                ),
              ),

              const SizedBox(height: 20),

              // ── Botão Entrar ───────────────────────────────────────────────
              BovPrimaryButton(
                label: 'Entrar',
                isLoading: isLoading,
                onPressed: () {
                  ref
                      .read(usuarioViewModelProvider.notifier)
                      .login(
                        email: _emailController.text,
                        senha: _senhaController.text,
                      );
                },
              ),

              const SizedBox(height: 24),

              // ── Link para Cadastro ─────────────────────────────────────────
              Center(
                child: GestureDetector(
                  onTap: () {
                    AppCoordinator.goToCadastro(context);
                  },
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.text4,
                        fontFamily: 'DM Sans',
                      ),
                      children: [
                        TextSpan(text: 'Não tem conta? '),
                        TextSpan(
                          text: 'Cadastrar',
                          style: TextStyle(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
