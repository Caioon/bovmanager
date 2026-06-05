import 'package:bov_manager/core/theme/app_colors.dart';
import 'package:bov_manager/core/widgets/bov_widgets.dart';
import 'package:bov_manager/viewmodels/usuario_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AlterarSenhaScreen extends ConsumerStatefulWidget {
  final String senhaAtual;

  const AlterarSenhaScreen({super.key, required this.senhaAtual});

  @override
  ConsumerState<AlterarSenhaScreen> createState() => _AlterarSenhaScreenState();
}

class _AlterarSenhaScreenState extends ConsumerState<AlterarSenhaScreen> {
  final _novaSenhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();
  bool _obscureNova = true;
  bool _obscureConfirmar = true;
  bool _isLoading = false;

  bool get _senhaValida => _novaSenhaController.text.length >= 6;
  bool get _senhasIguais =>
      _confirmarSenhaController.text.isNotEmpty &&
      _novaSenhaController.text == _confirmarSenhaController.text;
  bool get _formValido => _senhaValida && _senhasIguais;

  @override
  void initState() {
    super.initState();
    _novaSenhaController.addListener(() => setState(() {}));
    _confirmarSenhaController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _novaSenhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formValido) return;
    setState(() => _isLoading = true);

    try {
      await ref
          .read(usuarioViewModelProvider.notifier)
          .atualizarSenha(widget.senhaAtual, _novaSenhaController.text);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Senha atualizada com sucesso!',
              style: TextStyle(color: AppColors.text, fontFamily: 'DM Sans'),
            ),
            backgroundColor: AppColors.card,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.accent),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        showBovErrorSnackBar(
          context,
          e.toString().replaceAll('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _erroTexto(String mensagem) => Padding(
    padding: const EdgeInsets.only(top: 4, left: 4),
    child: Text(
      mensagem,
      style: const TextStyle(
        color: AppColors.red,
        fontSize: 12,
        fontFamily: 'DM Sans',
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final confirmarDigitado = _confirmarSenhaController.text.isNotEmpty;

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
                        'Alterar Senha',
                        style: TextStyle(
                          color: AppColors.text,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'DM Sans',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // ── Conteúdo ─────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),

                    // ── Nova senha ─────────────────────────────────────────
                    BovTextField(
                      controller: _novaSenhaController,
                      hintText: 'Mínimo 6 caracteres',
                      obscureText: _obscureNova,
                      textInputAction: TextInputAction.next,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureNova
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.text4,
                          size: 20,
                        ),
                        onPressed: () =>
                            setState(() => _obscureNova = !_obscureNova),
                      ),
                    ),
                    if (_novaSenhaController.text.isNotEmpty && !_senhaValida)
                      _erroTexto('A senha deve ter pelo menos 6 caracteres'),

                    const SizedBox(height: 14),

                    // ── Confirmar nova senha ───────────────────────────────
                    BovTextField(
                      controller: _confirmarSenhaController,
                      hintText: 'Repita a nova senha',
                      obscureText: _obscureConfirmar,
                      textInputAction: TextInputAction.done,
                      errorBorder: confirmarDigitado && !_senhasIguais,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmar
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.text4,
                          size: 20,
                        ),
                        onPressed: () => setState(
                          () => _obscureConfirmar = !_obscureConfirmar,
                        ),
                      ),
                    ),
                    if (confirmarDigitado && !_senhasIguais)
                      _erroTexto('As senhas não correspondem'),

                    const SizedBox(height: 24),

                    // ── Botão salvar ───────────────────────────────────────
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: AppColors.onAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: (!_formValido || _isLoading)
                            ? null
                            : _salvar,
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: AppColors.onAccent,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Salvar',
                                style: TextStyle(
                                  color: AppColors.text4,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'DM Sans',
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
