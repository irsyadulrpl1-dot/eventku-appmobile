import 'package:material_ui/material_ui.dart';
import 'package:eventku/models/transaction_model.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      TransactionStatus.success => ('Berhasil', const Color(0xFF16A34A)),
      TransactionStatus.expired => ('Kedaluwarsa', const Color(0xFF6B7280)),
      TransactionStatus.cancelled => ('Dibatalkan', const Color(0xFFDC2626)),
      _ => ('Menunggu', const Color(0xFFD97706)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
