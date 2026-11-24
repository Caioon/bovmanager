import 'package:bov_manager/core/theme/app_colors.dart';
import 'package:bov_manager/core/widgets/bov_widgets.dart';
import 'package:bov_manager/utils/cpf_input_formatter.dart';
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
  final _confirmarEmailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();

  bool _obscureSenha = true;
  bool _obscureConfirmarSenha = true;
  bool _tentouEnviar = false;

  // ── Getters de validação ───────────────────────────────────────────────────

  bool get _nomeValido => _nomeController.text.trim().isNotEmpty;

  bool get _cpfValido => cpfValido(_cpfController.text);

  bool get _emailValido {
    final email = _emailController.text.trim();

    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

    return regex.hasMatch(email);
  }

  bool get _emailsIguais =>
      _confirmarEmailController.text.trim().isNotEmpty &&
      _emailController.text.trim() == _confirmarEmailController.text.trim();

  bool get _senhaValida => _senhaController.text.length >= 8;

  bool get _senhasIguais =>
      _confirmarSenhaController.text.isNotEmpty &&
      _senhaController.text == _confirmarSenhaController.text;

  bool get _formValido =>
      _nomeValido &&
      _cpfValido &&
      _emailValido &&
      _emailsIguais &&
      _senhaValida &&
      _senhasIguais;

  void _rebuild() => setState(() {});

  // ── Erros (só aparecem após tentar enviar) ─────────────────────────────────

  bool get _erroNome => _tentouEnviar && !_nomeValido;
  bool get _erroCpf => _tentouEnviar && !_cpfValido;
  bool get _erroEmail => _tentouEnviar && !_emailValido;
  bool get _erroConfirmarEmail => _tentouEnviar && !_emailsIguais;
  bool get _erroSenha => _tentouEnviar && !_senhaValida;
  bool get _erroConfirmarSenha => _tentouEnviar && !_senhasIguais;

  void _enviar() {
    FocusScope.of(context).unfocus();
    setState(() => _tentouEnviar = true);
    if (!_formValido) return;

    ref
        .read(usuarioViewModelProvider.notifier)
        .criarUsuario(
          nome: _nomeController.text.trim(),
          email: _emailController.text.trim(),
          cpf: _cpfController.text.replaceAll(RegExp(r'\D'), ''),
          senha: _senhaController.text,
        );
  }

  @override
  void initState() {
    super.initState();
    _nomeController.addListener(_rebuild);
    _cpfController.addListener(_rebuild);
    _emailController.addListener(_rebuild);
    _confirmarEmailController.addListener(_rebuild);
    _senhaController.addListener(_rebuild);
    _confirmarSenhaController.addListener(_rebuild);
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cpfController.dispose();
    _emailController.dispose();
    _confirmarEmailController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  // ── Helpers de UI ─────────────────────────────────────────────────────────

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

  // Campo de CPF com formatter — usa TextField puro pois BovTextField
  // não expõe inputFormatters. Estilizado para combinar com BovTextField.
  Widget _campoCpf() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _cpfController,
          keyboardType: TextInputType.number,
          inputFormatters: [CpfInputFormatter()],
          style: const TextStyle(
            color: AppColors.text,
            fontSize: 15,
            fontFamily: 'DM Sans',
          ),
          decoration: InputDecoration(
            hintText: '000.000.000-00',
            hintStyle: const TextStyle(color: AppColors.text4, fontSize: 15),
            filled: true,
            fillColor: AppColors.card,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: _erroCpf ? AppColors.red : AppColors.border,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: _erroCpf ? AppColors.red : AppColors.accent,
              ),
            ),
          ),
        ),
        if (_erroCpf)
          _erroTexto(
            _cpfController.text.isEmpty ? 'Informe o CPF' : 'CPF inválido',
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(usuarioViewModelProvider);
    final isLoading = state.isLoading;

    ref.listen(usuarioViewModelProvider, (_, next) {
      next.whenOrNull(
        error: (e, _) => showBovErrorSnackBar(context, e.toString()),
        data: (usuario) {
          if (usuario != null) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        },
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
                    const Text(
                      'Preencha seus dados para acessar o sistema',
                      style: TextStyle(
                        color: AppColors.text4,
                        fontSize: 13,
                        fontFamily: 'DM Sans',
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Nome ──────────────────────────────────────────────
                    const BovFieldLabel(label: 'NOME COMPLETO'),
                    const SizedBox(height: 6),
                    BovTextField(
                      controller: _nomeController,
                      hintText: 'João da Silva',
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      errorBorder: _erroNome,
                    ),
                    if (_erroNome) _erroTexto('Informe seu nome'),

                    const SizedBox(height: 14),

                    // ── CPF ───────────────────────────────────────────────
                    const BovFieldLabel(label: 'CPF'),
                    const SizedBox(height: 6),
                    _campoCpf(),

                    const SizedBox(height: 14),

                    // ── E-mail ────────────────────────────────────────────
                    const BovFieldLabel(label: 'E-MAIL'),
                    const SizedBox(height: 6),
                    BovTextField(
                      controller: _emailController,
                      hintText: 'seu@email.com',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      errorBorder: _erroEmail,
                    ),
                    if (_erroEmail)
                      _erroTexto(
                        _emailController.text.trim().isEmpty
                            ? 'Informe seu e-mail'
                            : 'Email não é válido',
                      ),
                    const SizedBox(height: 14),

                    // ── Confirmar E-mail ───────────────────────────────────
                    const BovFieldLabel(label: 'CONFIRMAR E-MAIL'),
                    const SizedBox(height: 6),
                    BovTextField(
                      controller: _confirmarEmailController,
                      hintText: 'Repita o e-mail',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      errorBorder: _erroConfirmarEmail,
                    ),
                    if (_erroConfirmarEmail)
                      _erroTexto(
                        _confirmarEmailController.text.isEmpty
                            ? 'Confirme seu e-mail'
                            : 'Os e-mails não correspondem',
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
                      errorBorder: _erroSenha,
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

                    if (_erroSenha)
                      _erroTexto('A senha deve ter pelo menos 8 caracteres'),
                    const SizedBox(height: 14),

                    // ── Confirmar Senha ───────────────────────────────────
                    const BovFieldLabel(label: 'CONFIRMAR SENHA'),
                    const SizedBox(height: 6),
                    BovTextField(
                      controller: _confirmarSenhaController,
                      hintText: 'Repita a senha',
                      obscureText: _obscureConfirmarSenha,
                      textInputAction: TextInputAction.done,
                      errorBorder: _erroConfirmarSenha,
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
                    if (_erroConfirmarSenha)
                      _erroTexto(
                        _confirmarSenhaController.text.isEmpty
                            ? 'Confirme sua senha'
                            : 'As senhas não correspondem',
                      ),

                    const SizedBox(height: 20),

                    // ── Botão Criar Conta ──────────────────────────────────
                    BovPrimaryButton(
                      label: 'Criar Conta',
                      isLoading: isLoading,
                      onPressed: isLoading ? null : _enviar,
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
