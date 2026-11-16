import 'package:material_ui/material_ui.dart';
import 'package:intl/intl.dart';
import 'package:eventku/data/transaction_repository.dart';
import 'package:eventku/models/event.dart';
import 'package:eventku/models/transaction_item.dart';
import 'package:eventku/models/transaction_model.dart';
import 'package:eventku/screens/payment_screen.dart';
import 'package:eventku/theme/app_colors.dart';
import 'package:eventku/utils/currency_formatter.dart';
import 'package:eventku/utils/date_formatter.dart';
import 'package:eventku/utils/pricing.dart';
import 'package:eventku/widgets/custom_app_bar.dart';
import 'package:eventku/widgets/label_value_row.dart';
import 'package:eventku/widgets/order_stepper.dart';
import 'package:eventku/widgets/payment_method_card.dart';
import 'package:eventku/widgets/primary_button.dart';

class CheckoutScreen extends StatefulWidget {
  final Event event;

  const CheckoutScreen({super.key, required this.event});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  static const List<(String, String, IconData)> _metodeBayar = [
    ('Virtual Account', 'Transfer bank', Icons.account_balance_rounded),
    ('E-Wallet', 'GoPay, OVO, DANA', Icons.account_balance_wallet_rounded),
    ('Kartu Kredit', 'Visa, Mastercard', Icons.credit_card_rounded),
  ];

  final TransactionRepository _repository = TransactionRepository();
  final Map<int, int> _qty = {};
  String? _metode;
  bool _saving = false;

  int get _subtotal => widget.event.ticketCategories.fold(
    0,
    (sum, c) => sum + c.price * (_qty[c.id] ?? 0),
  );

  void _ubahJumlah(int categoryId, int delta) {
    final next = (_qty[categoryId] ?? 0) + delta;
    if (next < 0 || next > kMaksTiket) return;
    setState(() => _qty[categoryId] = next);
  }

  Future<void> _buatTagihan() async {
    setState(() => _saving = true);

    final event = widget.event;
    final now = DateTime.now().toUtc();
    final rincian = RincianHarga.dari(_subtotal);

    final items = [
      for (final c in event.ticketCategories)
        if ((_qty[c.id] ?? 0) > 0)
          TransactionItem(
            ticketCategoryId: c.id,
            categoryName: c.name,
            unitPrice: c.price,
            quantity: _qty[c.id]!,
          ),
    ];

    final stempel = DateFormat('yyyyMMdd-HHmmss', 'id_ID').format(keWib(now));

    final trx = TransactionModel(
      id: 'TRX-$stempel',
      eventId: event.id,
      eventTitle: event.title,
      paymentMethod: _metode!,
      subtotal: rincian.subtotal,
      serviceFee: rincian.biayaLayanan,
      tax: rincian.pajak,
      total: rincian.total,
      status: TransactionStatus.pending,
      createdAt: now,
      expiresAt: now.add(kBatasBayar),
      items: items,
    );

    try {
      await _repository.createTransaction(trx);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentScreen(transaction: trx),
        ),
      );
    } catch (e) {
      debugPrint('GAGAL MEMBUAT TAGIHAN: $e');
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal membuat tagihan. Coba lagi.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final rincian = RincianHarga.dari(_subtotal);
    final bisaLanjut = _subtotal > 0 && _metode != null && !_saving;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Checkout'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          const OrderStepper(currentStep: 0),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: appSurfaceDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Detail Pesanan',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(event.title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  '${formatTanggal(event.eventDate)}  •  ${formatJam(event.eventDate)}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  event.location,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('Pilih Kategori Tiket', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Maksimal $kMaksTiket tiket per kategori',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 10),
          if (event.ticketCategories.isEmpty)
            const Text('Tiket untuk acara ini belum tersedia.'),
          for (final c in event.ticketCategories)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: appSurfaceDecoration(),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c.name,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          formatRupiah(c.price),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _QtyButton(
                    icon: Icons.remove_rounded,
                    onPressed: (_qty[c.id] ?? 0) > 0
                        ? () => _ubahJumlah(c.id, -1)
                        : null,
                  ),
                  SizedBox(
                    width: 32,
                    child: Text(
                      '${_qty[c.id] ?? 0}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  _QtyButton(
                    icon: Icons.add_rounded,
                    onPressed: (_qty[c.id] ?? 0) >= kMaksTiket
                        ? null
                        : () => _ubahJumlah(c.id, 1),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          Text('Rincian Biaya', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: appSurfaceDecoration(),
            child: Column(
              children: [
                LabelValueRow(label: 'Subtotal', value: formatRupiah(rincian.subtotal)),
                LabelValueRow(
                  label: 'Biaya layanan',
                  value: formatRupiah(rincian.biayaLayanan),
                ),
                LabelValueRow(
                  label: 'Pajak ($kPersenPajak%)',
                  value: formatRupiah(rincian.pajak),
                ),
                const Divider(height: 16),
                LabelValueRow(
                  label: 'Total',
                  value: formatRupiah(rincian.total),
                  bold: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Metode Pembayaran',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          for (final (label, subtitle, icon) in _metodeBayar)
            PaymentMethodCard(
              label: label,
              subtitle: subtitle,
              icon: icon,
              selected: _metode == label,
              onTap: () => setState(() => _metode = label),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.line)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!bisaLanjut && !_saving)
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Pilih minimal 1 tiket dan metode pembayaran',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ),
              PrimaryButton(
                label: 'Lanjut ke Pembayaran',
                loading: _saving,
                onPressed: bisaLanjut ? _buatTagihan : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _QtyButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Material(
      color: enabled ? AppColors.lavender : AppColors.background,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: SizedBox(
          width: 34,
          height: 34,
          child: Icon(
            icon,
            size: 18,
            color: enabled ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
