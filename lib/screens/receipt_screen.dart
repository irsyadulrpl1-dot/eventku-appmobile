import 'package:material_ui/material_ui.dart';
import 'package:eventku/data/event_repository.dart';
import 'package:eventku/data/transaction_repository.dart';
import 'package:eventku/models/event.dart';
import 'package:eventku/models/ticket.dart';
import 'package:eventku/models/transaction_model.dart';
import 'package:eventku/theme/app_colors.dart';
import 'package:eventku/utils/currency_formatter.dart';
import 'package:eventku/utils/date_formatter.dart';
import 'package:eventku/widgets/custom_app_bar.dart';
import 'package:eventku/widgets/label_value_row.dart';
import 'package:eventku/widgets/loading_widget.dart';
import 'package:eventku/widgets/order_stepper.dart';
import 'package:eventku/widgets/status_badge.dart';
import 'package:eventku/widgets/ticket_card.dart';

class ReceiptScreen extends StatefulWidget {
  final TransactionModel transaction;

  const ReceiptScreen({super.key, required this.transaction});

  @override
  State<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  final TransactionRepository _repository = TransactionRepository();

  List<Ticket> _tickets = [];
  Event? _event;
  bool _loading = true;

  bool get _berhasil => widget.transaction.status == TransactionStatus.success;

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    final data = _berhasil
        ? await _repository.getTickets(widget.transaction.id)
        : <Ticket>[];
    Event? event;
    try {
      final events = await EventRepository().getLocalEvents();
      for (final item in events) {
        if (item.id == widget.transaction.eventId) {
          event = item;
          break;
        }
      }
    } catch (e) {
      debugPrint('GAGAL MEMBACA DATA EVENT UNTUK TIKET: $e');
    }
    if (!mounted) return;
    setState(() {
      _tickets = data;
      _event = event;
      _loading = false;
    });
  }

  String? get _pesan => switch (widget.transaction.status) {
    TransactionStatus.expired =>
      'Batas waktu pembayaran sudah lewat. E-ticket tidak diterbitkan.',
    TransactionStatus.cancelled =>
      'Tagihan dibatalkan. E-ticket tidak diterbitkan.',
    TransactionStatus.pending => 'Pembayaran belum selesai.',
    _ => null,
  };

  @override
  Widget build(BuildContext context) {
    final trx = widget.transaction;
    final pesan = _pesan;
    final event = _event;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: _berhasil ? 'E-Ticket' : 'Bukti Pembayaran'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          if (_berhasil) ...[
            const OrderStepper(currentStep: 2),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
              decoration: appSurfaceDecoration(radius: AppRadius.lg),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: Color(0xFFDCFCE7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: AppColors.success,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Pembayaran Berhasil!',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tiket event kamu sudah siap. Tunjukkan QR saat masuk venue.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                ],
              ),
            ),
          ] else ...[
            Align(
              alignment: Alignment.centerLeft,
              child: StatusBadge(status: trx.status),
            ),
            if (pesan != null) ...[
              const SizedBox(height: 8),
              Text(pesan, style: const TextStyle(color: AppColors.textSecondary)),
            ],
          ],
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: appSurfaceDecoration(),
            child: Column(
              children: [
                LabelValueRow(label: 'ID Transaksi', value: trx.id),
                LabelValueRow(label: 'Acara', value: trx.eventTitle),
                LabelValueRow(label: 'Metode', value: trx.paymentMethod),
                LabelValueRow(
                  label: 'Nominal',
                  value: formatRupiah(trx.total),
                  bold: true,
                ),
                LabelValueRow(
                  label: 'Dibuat',
                  value: formatWaktuLengkap(trx.createdAt),
                ),
                if (trx.paidAt != null)
                  LabelValueRow(
                    label: 'Dibayar',
                    value: formatWaktuLengkap(trx.paidAt!),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('Rincian Tiket', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: appSurfaceDecoration(),
            child: Column(
              children: [
                for (final item in trx.items)
                  LabelValueRow(
                    label: '${item.categoryName} x${item.quantity}',
                    value: formatRupiah(item.subtotal),
                  ),
                const Divider(height: 16),
                LabelValueRow(label: 'Subtotal', value: formatRupiah(trx.subtotal)),
                LabelValueRow(
                  label: 'Biaya layanan',
                  value: formatRupiah(trx.serviceFee),
                ),
                LabelValueRow(label: 'Pajak', value: formatRupiah(trx.tax)),
              ],
            ),
          ),
          if (_berhasil) ...[
            const SizedBox(height: 20),
            Text('E-Ticket', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            const Text(
              'QR dibuat langsung di HP-mu, jadi bisa dibuka tanpa internet.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 12),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: LoadingWidget(message: 'Menyiapkan e-ticket...'),
              )
            else if (_tickets.isEmpty)
              const Text('E-ticket tidak ditemukan.')
            else
              for (var i = 0; i < _tickets.length; i++)
                TicketCard(
                  ticket: _tickets[i],
                  nomor: i + 1,
                  jumlah: _tickets.length,
                  eventTitle: trx.eventTitle,
                  orderId: trx.id,
                  status: trx.status,
                  eventDate: event == null ? null : formatTanggal(event.eventDate),
                  location: event?.location,
                ),
          ],
        ],
      ),
    );
  }
}
