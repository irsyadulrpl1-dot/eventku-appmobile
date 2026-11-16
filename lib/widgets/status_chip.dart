import 'package:material_ui/material_ui.dart';
import 'package:eventku/widgets/status_badge.dart';

/// Nama lama yang masih dipakai layar transaksi. Tampilannya mengikuti StatusBadge.
class StatusChip extends StatelessWidget {
  final String status;

  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return StatusBadge(status: status);
  }
}
