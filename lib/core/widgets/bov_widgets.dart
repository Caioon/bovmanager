import 'package:bov_manager/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

// =============================================================================
// BOV LOGO
// =============================================================================

/// Logo "BOVmanager" com "BOV" em verde e "MANAGER" em branco.
class BovLogo extends StatelessWidget {
  const BovLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'BOV',
                style: TextStyle(
                  color: AppColors.accent,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.6,
                  fontFamily: 'DM Sans',
                ),
              ),
              TextSpan(
                text: 'MANAGER',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.6,
                  fontFamily: 'DM Sans',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Gestão Pecuária',
          style: TextStyle(
            color: AppColors.text4,
            fontSize: 13,
            fontFamily: 'DM Sans',
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// FIELD LABEL
// =============================================================================

/// Label de campo no estilo uppercase do mockup.
class BovFieldLabel extends StatelessWidget {
  const BovFieldLabel({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.text4,
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.0,
        fontFamily: 'DM Sans',
      ),
    );
  }
}

// =============================================================================
// TEXT FIELD
// =============================================================================

/// Campo de texto padrão do BovManager.
class BovTextField extends StatelessWidget {
  const BovTextField({
    super.key,
    required this.controller,
    this.hintText,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
    this.prefixIcon,    // ← novo
    this.textInputAction,
    this.onChanged,     // ← novo
  });

  final TextEditingController controller;
  final String? hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final Widget? prefixIcon;           // ← novo
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged; // ← novo

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onChanged: onChanged,           // ← novo
      style: const TextStyle(
        color: AppColors.text,
        fontSize: 15,
        fontFamily: 'DM Sans',
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: AppColors.text3,
          fontSize: 15,
          fontFamily: 'DM Sans',
        ),
        filled: true,
        fillColor: AppColors.card,
        prefixIcon: prefixIcon,       // ← novo
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.accent),
        ),
      ),
    );
  }
}

// =============================================================================
// BUTTONS
// =============================================================================

/// Botão primário verde (Entrar, Criar Conta, etc).
class BovPrimaryButton extends StatelessWidget {
  const BovPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: isLoading ? null : onPressed,
        style: TextButton.styleFrom(
          backgroundColor: AppColors.accent,
          disabledBackgroundColor: AppColors.accent.withOpacity(0.5),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.onAccent,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  color: AppColors.onAccent,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'DM Sans',
                ),
              ),
      ),
    );
  }
}

/// Botão secundário (borda escura, fundo card).
class BovSecondaryButton extends StatelessWidget {
  const BovSecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: AppColors.card,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: AppColors.border),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: AppColors.text, size: 18),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 15,
                fontWeight: FontWeight.w500,
                fontFamily: 'DM Sans',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Botão de perigo/destrutivo (vermelho translúcido).
class BovDangerButton extends StatelessWidget {
  const BovDangerButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: isLoading ? null : onPressed,
        style: TextButton.styleFrom(
          backgroundColor: AppColors.redBg,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: AppColors.redBorder),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.red,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: AppColors.red, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.red,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'DM Sans',
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// =============================================================================
// BACK BUTTON
// =============================================================================

/// Botão de voltar no estilo card do mockup.
class BovBackButton extends StatelessWidget {
  const BovBackButton({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => Navigator.of(context).pop(),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: AppColors.text2,
          size: 16,
        ),
      ),
    );
  }
}

// =============================================================================
// ERROR SNACKBAR HELPER
// =============================================================================

void showBovErrorSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: const TextStyle(
          color: AppColors.text,
          fontFamily: 'DM Sans',
        ),
      ),
      backgroundColor: AppColors.card,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.redBorder),
      ),
      margin: const EdgeInsets.all(16),
    ),
  );
}
