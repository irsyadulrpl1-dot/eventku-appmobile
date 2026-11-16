import 'package:material_ui/material_ui.dart';
import 'package:eventku/theme/app_colors.dart';

/// Indikator tiga langkah pada alur yang sudah ada: pesanan, bayar, selesai.
class OrderStepper extends StatelessWidget {
  final int currentStep;

  const OrderStepper({super.key, required this.currentStep});

  static const _labels = ['Pesanan', 'Pembayaran', 'Selesai'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < _labels.length; i++) ...[
          if (i > 0)
            Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.only(bottom: 18),
                color: i <= currentStep ? AppColors.primary : AppColors.line,
              ),
            ),
          _StepDot(
            label: _labels[i],
            index: i,
            active: i <= currentStep,
            current: i == currentStep,
          ),
        ],
      ],
    );
  }
}

class _StepDot extends StatelessWidget {
  final String label;
  final int index;
  final bool active;
  final bool current;

  const _StepDot({
    required this.label,
    required this.index,
    required this.active,
    required this.current,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? AppColors.primary : AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(
              color: active ? AppColors.primary : AppColors.line,
            ),
          ),
          child: active && !current
              ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
              : Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: active ? Colors.white : AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: current ? FontWeight.w700 : FontWeight.w500,
            color: active ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
