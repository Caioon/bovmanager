import 'package:bov_manager/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

// =============================================================================
// BOV LOGO
// =============================================================================

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

class BovTextField extends StatelessWidget {
  const BovTextField({
    super.key,
    required this.controller,
    this.hintText,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
    this.prefixIcon,
    this.textInputAction,
    this.onChanged,
    this.errorBorder = false, // opcional, padrão false — não afeta usos existentes
  });

  final TextEditingController controller;
  final String? hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final bool errorBorder;

  @override
  Widget build(BuildContext context) {
    // Quando errorBorder é true, a borda usa AppColors.red no lugar das cores padrão.
    // Quando false (padrão), o comportamento é idêntico ao original.
    final borderColor = errorBorder ? AppColors.red : AppColors.border;
    final focusedBorderColor = errorBorder ? AppColors.red : AppColors.accent;

    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onChanged: onChanged,
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
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: focusedBorderColor),
        ),
      ),
    );
  }
}

// =============================================================================
// BUTTONS
// =============================================================================

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
          // ignore: deprecated_member_use
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

// =============================================================================
// CONFIRMAÇÃO DE COORDENADA
// =============================================================================

class BovConfirmacaoCoordenadaDialog extends StatelessWidget {
  const BovConfirmacaoCoordenadaDialog({
    super.key,
    required this.lat,
    required this.lng,
    this.cidadeProxima,
  });

  final double lat;
  final double lng;
  final String? cidadeProxima;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Confirmar ponto central',
              style: TextStyle(
                color: AppColors.text,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                fontFamily: 'DM Sans',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Deseja salvar o ponto central da propriedade localizado nas coordenadas atuais?',
              style: TextStyle(
                color: AppColors.text4,
                fontSize: 13,
                fontFamily: 'DM Sans',
              ),
            ),
            const SizedBox(height: 20),
            _CoordRow(label: 'Latitude', value: lat.toStringAsFixed(6)),
            const SizedBox(height: 8),
            _CoordRow(label: 'Longitude', value: lng.toStringAsFixed(6)),
            const SizedBox(height: 8),
            _CoordRow(
              label: 'Próximo de',
              value: cidadeProxima ?? 'Não identificado',
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: BovSecondaryButton(
                    label: 'Cancelar',
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: BovPrimaryButton(
                    label: 'Salvar',
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CoordRow extends StatelessWidget {
  const _CoordRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            color: AppColors.text4,
            fontSize: 13,
            fontFamily: 'DM Sans',
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.text,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            fontFamily: 'DM Sans',
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// BOV TIME PICKER — picker de horário customizado com scroll circular
// =============================================================================
//
// Bottom sheet com duas colunas de scroll circular (horas 0–23, minutos 0–59,
// sem segundos). O item central de cada coluna é o selecionado, destacado
// com fundo accentBg. Substitui o showTimePicker nativo em tarefa_screen.dart
// e em _EditarDataHoraTarefaSheet (lista_tarefas_screen.dart).
//
// Uso:
//   final picked = await showBovTimePicker(
//     context: context,
//     initialHour: 8,
//     initialMinute: 30,
//   );
//   if (picked != null) setState(() => _horaExecucao = picked);
//
// Retorna TimeOfDay? — null se o usuário cancelar.

Future<TimeOfDay?> showBovTimePicker({
  required BuildContext context,
  int initialHour = 8,
  int initialMinute = 0,
}) {
  return showModalBottomSheet<TimeOfDay>(
    context: context,
    backgroundColor: AppColors.card,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _BovTimePickerSheet(
      initialHour: initialHour,
      initialMinute: initialMinute,
    ),
  );
}

class _BovTimePickerSheet extends StatefulWidget {
  const _BovTimePickerSheet({
    required this.initialHour,
    required this.initialMinute,
  });

  final int initialHour;
  final int initialMinute;

  @override
  State<_BovTimePickerSheet> createState() => _BovTimePickerSheetState();
}

class _BovTimePickerSheetState extends State<_BovTimePickerSheet> {
  static const _itemHeight = 56.0;
  static const _visibleItems = 3; // quantos itens ficam visíveis por coluna

  late int _selectedHour;
  late int _selectedMinute;

  late final FixedExtentScrollController _hourCtrl;
  late final FixedExtentScrollController _minuteCtrl;

  @override
  void initState() {
    super.initState();
    _selectedHour = widget.initialHour;
    _selectedMinute = widget.initialMinute;

    // Começamos em um offset grande para simular scroll circular
    _hourCtrl = FixedExtentScrollController(
      initialItem: _initialOffset(24) + widget.initialHour,
    );
    _minuteCtrl = FixedExtentScrollController(
      initialItem: _initialOffset(60) + widget.initialMinute,
    );
  }

  @override
  void dispose() {
    _hourCtrl.dispose();
    _minuteCtrl.dispose();
    super.dispose();
  }

  /// Offset inicial suficientemente grande para scroll "infinito" sem chegar ao topo
  int _initialOffset(int total) => total * 500;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Alça
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            const Text(
              'Selecionar horário',
              style: TextStyle(
                color: AppColors.text,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                fontFamily: 'DM Sans',
              ),
            ),

            const SizedBox(height: 24),

            // ── Colunas de hora e minuto ───────────────────────────────────
            SizedBox(
              height: _itemHeight * _visibleItems,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Faixa de destaque do item central
                  Positioned(
                    top: _itemHeight,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: _itemHeight,
                      decoration: BoxDecoration(
                        color: AppColors.accentBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.accent),
                      ),
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Coluna de horas
                      _BovTimePickerColumn(
                        controller: _hourCtrl,
                        total: 24,
                        itemHeight: _itemHeight,
                        onSelected: (v) => setState(() => _selectedHour = v),
                      ),

                      // Separador
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          ':',
                          style: TextStyle(
                            color: AppColors.text,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'DM Sans',
                          ),
                        ),
                      ),

                      // Coluna de minutos
                      _BovTimePickerColumn(
                        controller: _minuteCtrl,
                        total: 60,
                        itemHeight: _itemHeight,
                        onSelected: (v) =>
                            setState(() => _selectedMinute = v),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Labels abaixo das colunas
            const Padding(
              padding: EdgeInsets.only(top: 8, bottom: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 80,
                    child: Center(
                      child: Text(
                        'horas',
                        style: TextStyle(
                          color: AppColors.text4,
                          fontSize: 11,
                          fontFamily: 'DM Sans',
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 32), // espaço do ":"
                  SizedBox(
                    width: 80,
                    child: Center(
                      child: Text(
                        'minutos',
                        style: TextStyle(
                          color: AppColors.text4,
                          fontSize: 11,
                          fontFamily: 'DM Sans',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Botões (reutiliza os componentes do design system) ────────
            BovPrimaryButton(
              label: 'Confirmar',
              onPressed: () {
                Navigator.of(context).pop(
                  TimeOfDay(hour: _selectedHour, minute: _selectedMinute),
                );
              },
            ),
            const SizedBox(height: 10),
            BovSecondaryButton(
              label: 'Cancelar',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// COLUNA DE SCROLL CIRCULAR DO BOV TIME PICKER
// =============================================================================

class _BovTimePickerColumn extends StatefulWidget {
  const _BovTimePickerColumn({
    required this.controller,
    required this.total,
    required this.itemHeight,
    required this.onSelected,
  });

  final FixedExtentScrollController controller;
  final int total;
  final double itemHeight;
  final ValueChanged<int> onSelected;

  @override
  State<_BovTimePickerColumn> createState() => _BovTimePickerColumnState();
}

class _BovTimePickerColumnState extends State<_BovTimePickerColumn> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.controller.initialItem;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      child: ListWheelScrollView.useDelegate(
        controller: widget.controller,
        itemExtent: widget.itemHeight,
        perspective: 0.003,
        diameterRatio: 2.0,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: (index) {
          setState(() => _currentIndex = index);
          widget.onSelected(index % widget.total);
        },
        childDelegate: ListWheelChildBuilderDelegate(
          builder: (context, index) {
            final value = index % widget.total;
            final isSelected = index == _currentIndex;

            return Center(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 150),
                style: TextStyle(
                  color: isSelected ? AppColors.text : AppColors.text4,
                  fontSize: isSelected ? 26 : 20,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                  fontFamily: 'DM Sans',
                ),
                child: Text(value.toString().padLeft(2, '0')),
              ),
            );
          },
        ),
      ),
    );
  }
}
