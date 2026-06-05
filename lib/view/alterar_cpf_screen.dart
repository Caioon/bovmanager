import 'package:bov_manager/core/theme/app_colors.dart';
import 'package:bov_manager/core/widgets/bov_widgets.dart';
import 'package:bov_manager/utils/cpf_input_formatter.dart';
import 'package:bov_manager/viewmodels/usuario_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AlterarCpfScreen extends ConsumerStatefulWidget {
  final String cpfAtual;

  const AlterarCpfScreen({super.key, required this.cpfAtual});

  @override
  ConsumerState<AlterarCpfScreen> createState() => _AlterarCpfScreenState();
}

class _AlterarCpfScreenState extends ConsumerState<AlterarCpfScreen> {
  late final TextEditingController _controller;
  bool _isLoading = false;

  bool get _cpfValido => cpfValido(_controller.text);

  @override
  void initState() {
    super.initState();
    // Formata o CPF atual ao exibir (independente de como foi salvo)
    _controller = TextEditingController(text: formatarCpf(widget.cpfAtual));
    _controller.selection = TextSelection.collapsed(
      offset: _controller.text.length,
    );
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_cpfValido) return;

    setState(() => _isLoading = true);

    try {
      // Salva apenas os dígitos no Firestore
      final cpfDigitos = _controller.text.replaceAll(RegExp(r'\D'), '');
      await ref.read(usuarioViewModelProvider.notifier).atualizarCpf(cpfDigitos);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'CPF atualizado com sucesso!',
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

  @override
  Widget build(BuildContext context) {
    final digitados = _controller.text.replaceAll(RegExp(r'\D'), '').length;
    final mostraErro = digitados > 0 && digitados < 11;

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
                        'Alterar CPF',
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

                    // Campo CPF pré-preenchido e formatado
                    TextField(
                      controller: _controller,
                      autofocus: true,
                      keyboardType: TextInputType.number,
                      inputFormatters: [CpfInputFormatter()],
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 16,
                        fontFamily: 'DM Sans',
                      ),
                      decoration: InputDecoration(
                        labelText: 'CPF',
                        labelStyle: const TextStyle(color: AppColors.text4),
                        hintText: '000.000.000-00',
                        hintStyle: const TextStyle(color: AppColors.text4),
                        filled: true,
                        fillColor: AppColors.card,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: mostraErro
                                ? AppColors.red
                                : AppColors.border,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: mostraErro
                                ? AppColors.red
                                : AppColors.accent,
                          ),
                        ),
                      ),
                    ),

                    if (mostraErro)
                      Padding(
                        padding: const EdgeInsets.only(top: 4, left: 4),
                        child: Text(
                          'CPF inválido — insira 11 dígitos',
                          style: const TextStyle(
                            color: AppColors.red,
                            fontSize: 12,
                            fontFamily: 'DM Sans',
                          ),
                        ),
                      ),

                    const SizedBox(height: 24),

                    // Botão salvar — desabilitado se CPF inválido
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
                        onPressed:
                            (!_cpfValido || _isLoading) ? null : _salvar,
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
