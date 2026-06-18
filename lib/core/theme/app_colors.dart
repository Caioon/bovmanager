import 'package:flutter/material.dart';

/// Paleta de cores do BovManager.
/// Derivada diretamente do design system do mockup.
abstract class AppColors {
  // Fundos
  static const Color background = Color(0xFF0C0C11);
  static const Color card = Color(0xFF141420);

  // Bordas
  static const Color border = Color(0xFF1E1E2A);
  static const Color border2 = Color(0xFF1A1A26);

  // Accent (verde)
  static const Color accent = Color(0xFF2DC88A);
  static const Color accentBg = Color(0xFF1B3D2E);
  static const Color onAccent = Color(0xFF061A10);

  // Texto
  static const Color text = Color(0xFFE8E8F0);
  static const Color text2 = Color(0xFFD0D0E0);
  static const Color text3 = Color(0xFF4A4A60);
  static const Color text4 = Color(0xFF6B6B85);

  // Erro / alerta
  static const Color red = Color(0xFFE85050);
  static const Color redBg = Color(0x1FE85050);
  static const Color redBorder = Color(0x33E85050);

  // Lotação de pastos — usadas no mapa
  static const Color pastoVerde = accent;           // ≤ 50%
  static const Color pastoAmarelo = Color(0xFFE8C930); // 51–75%
  static const Color pastoLaranja = Color(0xFFE88A30); // 76–95%
  static const Color pastoVermelho = red;           // > 95%
  static const Color pastoCinza = Color(0xFF6B6B85); // sem limite definido
}
