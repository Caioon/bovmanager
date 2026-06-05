import 'package:flutter/services.dart';

class CpfInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 11) return oldValue;

    final formatted = formatarCpf(digits);

    // Conta quantos dígitos existiam antes do cursor no texto novo.
    // Isso permite mapear a posição do cursor para a string formatada,
    // preservando a posição mesmo quando o usuário edita no meio do CPF.
    final cursorOffset = newValue.selection.end.clamp(0, newValue.text.length);
    final digitsBeforeCursor = newValue.text
        .substring(0, cursorOffset)
        .replaceAll(RegExp(r'\D'), '')
        .length;

    // Encontra a posição na string formatada correspondente ao mesmo
    // número de dígitos antes do cursor.
    int newCursor = formatted.length;
    int digitsSeen = 0;
    for (int i = 0; i < formatted.length; i++) {
      if (digitsSeen == digitsBeforeCursor) {
        newCursor = i;
        break;
      }
      if (RegExp(r'\d').hasMatch(formatted[i])) digitsSeen++;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: newCursor),
    );
  }
}

/// Formata uma string de dígitos como CPF (xxx.xxx.xxx-xx).
String formatarCpf(String digits) {
  final d = digits.replaceAll(RegExp(r'\D'), '');
  if (d.length <= 3) return d;
  if (d.length <= 6) return '${d.substring(0, 3)}.${d.substring(3)}';
  if (d.length <= 9) {
    return '${d.substring(0, 3)}.${d.substring(3, 6)}.${d.substring(6)}';
  }
  return '${d.substring(0, 3)}.${d.substring(3, 6)}.${d.substring(6, 9)}-${d.substring(9)}';
}

/// Retorna true se o CPF tiver 11 dígitos numéricos.
bool cpfValido(String cpf) => cpf.replaceAll(RegExp(r'\D'), '').length == 11;
