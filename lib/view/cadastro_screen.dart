import 'package:bov_manager/core/theme/app_colors.dart';
import 'package:bov_manager/core/widgets/bov_widgets.dart';
import 'package:bov_manager/viewmodels/usuario_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CadastroScreen extends ConsumerStatefulWidget {
  const CadastroScreen({super.key});

  @override
  ConsumerState<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends ConsumerState<CadastroScreen> {
  final _nomeController = TextEditingController();
  final _cpfController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();

  // Estados locais de visibilidade — puramente UI
  bool _obscureSenha = true;
  bool _obscureConfirmarSenha = true;

  @override
  void dispose() {
    _nomeController.dispose();
    _cpfController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Observa o estado do ViewModel pra determinar se ja houve trigger da criação
    final state = ref.watch(usuarioViewModelProvider);
    final isLoading = state.isLoading;

    // Se houver erro, da trigger na snackbar
    // Se a criação for bem sucedida, o authGate já atualiza e volta pra loginScreen, evitando uso de navigator
    ref.listen(usuarioViewModelProvider, (_, next) {
      next.whenOrNull(
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
                  BovBackButton(onTap: () => Navigator.of(context).pop()),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Criar Conta',
                        style: TextStyle(
                          color: AppColors.text,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'DM Sans',
                        ),
                      ),
                    ),
                  ),
                  // Espaçamento para centralizar o título
                  const SizedBox(width: 36),
                ],
              ),
            ),

            // ── Corpo ─────────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Subtítulo
                    const Text(
                      'Preencha seus dados para acessar o sistema',
                      style: TextStyle(
                        color: AppColors.text4,
                        fontSize: 13,
                        fontFamily: 'DM Sans',
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Nome Completo ──────────────────────────────────────
                    const BovFieldLabel(label: 'NOME COMPLETO'),
                    const SizedBox(height: 6),
                    BovTextField(
                      controller: _nomeController,
                      hintText: 'João da Silva',
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                    ),

                    const SizedBox(height: 14),

                    // ── CPF ───────────────────────────────────────────────
                    const BovFieldLabel(label: 'CPF'),
                    const SizedBox(height: 6),
                    BovTextField(
                      controller: _cpfController,
                      hintText: '000.000.000-00',
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                    ),

                    const SizedBox(height: 14),

                    // ── E-mail ────────────────────────────────────────────
                    const BovFieldLabel(label: 'E-MAIL'),
                    const SizedBox(height: 6),
                    BovTextField(
                      controller: _emailController,
                      hintText: 'seu@email.com',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                    ),

                    const SizedBox(height: 14),

                    // ── Senha ─────────────────────────────────────────────
                    const BovFieldLabel(label: 'SENHA'),
                    const SizedBox(height: 6),
                    BovTextField(
                      controller: _senhaController,
                      hintText: 'Mínimo 8 caracteres',
                      obscureText: _obscureSenha,
                      textInputAction: TextInputAction.next,
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

                    const SizedBox(height: 14),

                    // ── Confirmar Senha ───────────────────────────────────
                    const BovFieldLabel(label: 'CONFIRMAR SENHA'),
                    const SizedBox(height: 6),
                    BovTextField(
                      controller: _confirmarSenhaController,
                      hintText: 'Repita a senha',
                      obscureText: _obscureConfirmarSenha,
                      textInputAction: TextInputAction.done,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmarSenha
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.text4,
                          size: 20,
                        ),
                        onPressed: () => setState(
                          () =>
                              _obscureConfirmarSenha = !_obscureConfirmarSenha,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Botão Criar Conta ──────────────────────────────────
                    BovPrimaryButton(
                      label: 'Criar Conta',
                      isLoading: isLoading,
                      onPressed: () {
                        ref
                            .read(usuarioViewModelProvider.notifier)
                            .criarUsuario(
                              nome: _nomeController.text,
                              email: _emailController.text,
                              cpf: _cpfController.text,
                              senha: _senhaController.text,
                            );
                      },
                    ),

                    const SizedBox(height: 20),

                    // ── Link para Login ────────────────────────────────────
                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: RichText(
                          text: const TextSpan(
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.text4,
                              fontFamily: 'DM Sans',
                            ),
                            children: [
                              TextSpan(text: 'Já tem conta? '),
                              TextSpan(
                                text: 'Entrar',
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
