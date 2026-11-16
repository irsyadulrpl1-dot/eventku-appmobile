import 'package:material_ui/material_ui.dart';
import 'package:eventku/theme/app_colors.dart';

class LabelValueRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const LabelValueRow({
    super.key,
    required this.label,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
      color: bold ? AppColors.textPrimary : AppColors.textSecondary,
      fontSize: bold ? 15 : 13,
    );
    final valueStyle = TextStyle(
      fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
      color: bold ? AppColors.primary : AppColors.textPrimary,
      fontSize: bold ? 15 : 13,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label, style: style)),
          const SizedBox(width: 12),
          Flexible(
            child: Text(value, textAlign: TextAlign.end, style: valueStyle),
          ),
        ],
      ),
    );
  }
}
