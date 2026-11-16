import 'package:material_ui/material_ui.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:eventku/models/ticket.dart';
import 'package:eventku/theme/app_colors.dart';
import 'package:eventku/widgets/status_badge.dart';

class TicketCard extends StatelessWidget {
  final Ticket ticket;
  final int nomor;
  final int jumlah;
  final String eventTitle;
  final String orderId;
  final String status;
  final String? eventDate;
  final String? location;

  const TicketCard({
    super.key,
    required this.ticket,
    required this.nomor,
    required this.jumlah,
    required this.eventTitle,
    required this.orderId,
    required this.status,
    this.eventDate,
    this.location,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: appSurfaceDecoration(radius: AppRadius.lg),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.confirmation_number_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'EventKu',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    const Spacer(),
                    StatusBadge(status: status),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  eventTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  '${ticket.categoryName}  •  Tiket $nomor dari $jumlah',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 14),
                if (eventDate != null)
                  _TicketRow(label: 'Tanggal', value: eventDate!),
                if (location != null)
                  _TicketRow(label: 'Lokasi', value: location!),
                _TicketRow(label: 'Kode pesanan', value: orderId),
              ],
            ),
          ),
          const _Perforation(),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: QrImageView(
                    data: ticket.qrData,
                    version: QrVersions.auto,
                    size: 180,
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.all(8),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  ticket.qrData,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TicketRow extends StatelessWidget {
  final String label;
  final String value;

  const _TicketRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Perforation extends StatelessWidget {
  const _Perforation();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24,
      child: Row(
        children: [
          _Notch(left: true),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final count = (constraints.maxWidth / 10).floor();
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    count,
                    (_) => Container(
                      width: 5,
                      height: 1.5,
                      color: AppColors.secondary.withValues(alpha: 0.7),
                    ),
                  ),
                );
              },
            ),
          ),
          _Notch(left: false),
        ],
      ),
    );
  }
}

class _Notch extends StatelessWidget {
  final bool left;

  const _Notch({required this.left});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 24,
      alignment: left ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        width: 16,
        height: 16,
        decoration: const BoxDecoration(
          color: AppColors.background,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
