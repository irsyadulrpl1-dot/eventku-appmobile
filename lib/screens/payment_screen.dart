import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:eventku/data/transaction_repository.dart';
import 'package:eventku/models/transaction_model.dart';
import 'package:eventku/screens/receipt_screen.dart';
import 'package:eventku/theme/app_colors.dart';
import 'package:eventku/utils/currency_formatter.dart';
import 'package:eventku/utils/date_formatter.dart';
import 'package:eventku/widgets/custom_app_bar.dart';
import 'package:eventku/widgets/label_value_row.dart';
import 'package:eventku/widgets/order_stepper.dart';
import 'package:eventku/widgets/primary_button.dart';
import 'package:eventku/widgets/status_badge.dart';

class PaymentScreen extends StatefulWidget {
  final TransactionModel transaction;

  const PaymentScreen({super.key, required this.transaction});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final TransactionRepository _repository = TransactionRepository();

  late TransactionModel _trx;
  Timer? _timer;
  Duration _sisa = Duration.zero;
  bool _processing = false;

  bool get _isPending => _trx.status == TransactionStatus.pending;

  @override
  void initState() {
    super.initState();
    _trx = widget.transaction;
    _hitungSisa();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _hitungSisa() {
    final sisa = _trx.expiresAt.difference(DateTime.now().toUtc());
    _sisa = sisa.isNegative ? Duration.zero : sisa;
  }

  Future<void> _tick() async {
    if (!_isPending) {
      _timer?.cancel();
      return;
    }
    setState(_hitungSisa);

    if (_sisa == Duration.zero && !_processing) {
      _timer?.cancel();
      await _repository.expireOverdue();
      await _muatUlang();
    }
  }

  Future<void> _muatUlang() async {
    final fresh = await _repository.getById(_trx.id);
    if (!mounted || fresh == null) return;
    setState(() {
      _trx = fresh;
      _hitungSisa();
    });
  }

  Future<void> _bayar() async {
    setState(() => _processing = true);

    await Future.delayed(const Duration(seconds: 2));

    final berhasil = await _repository.markAsPaid(_trx.id);
    await _muatUlang();
    if (!mounted) return;

    setState(() => _processing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          berhasil
              ? 'Pembayaran berhasil!'
              : 'Pembayaran gagal: tagihan sudah tidak berlaku.',
        ),
      ),
    );
  }

  Future<void> _batalkan() async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Batalkan tagihan?'),
        content: const Text('Tagihan yang dibatalkan tidak bisa dibayar lagi.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Tidak'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ya, batalkan'),
          ),
        ],
      ),
    );
    if (yakin != true) return;

    await _repository.cancel(_trx.id);
    await _muatUlang();
  }

  String? get _pesanStatus => switch (_trx.status) {
    TransactionStatus.success =>
      'Pembayaran diterima. E-ticket kamu sudah dibuat.',
    TransactionStatus.expired => 'Batas waktu pembayaran sudah lewat.',
    TransactionStatus.cancelled => 'Tagihan ini telah dibatalkan.',
    _ => null,
  };

  IconData get _methodIcon => switch (_trx.paymentMethod) {
    'E-Wallet' => Icons.account_balance_wallet_rounded,
    'Kartu Kredit' => Icons.credit_card_rounded,
    _ => Icons.account_balance_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final trx = _trx;
    final pesan = _pesanStatus;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Pembayaran'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          const OrderStepper(currentStep: 1),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: appSurfaceDecoration(radius: AppRadius.lg),
            child: Column(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    color: AppColors.lavender,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_methodIcon, color: AppColors.primary),
                ),
                const SizedBox(height: 10),
                Text(
                  trx.paymentMethod,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Total pembayaran',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  formatRupiah(trx.total),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 10),
                StatusBadge(status: trx.status),
              ],
            ),
          ),
          if (pesan != null) ...[
            const SizedBox(height: 12),
            Text(
              pesan,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
          if (_isPending) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: appSurfaceDecoration(),
              child: Column(
                children: [
                  const Text(
                    'Sisa waktu pembayaran',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatSisaWaktu(_sisa),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: _sisa.inMinutes < 10 && _sisa.inHours == 0
                          ? AppColors.danger
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (_processing) ...[
            const SizedBox(height: 16),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 8),
                Text(
                  'Memeriksa pembayaran...',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
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
                  label: 'Dibuat',
                  value: formatWaktuLengkap(trx.createdAt),
                ),
                LabelValueRow(
                  label: 'Bayar sebelum',
                  value: formatWaktuLengkap(trx.expiresAt),
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
                const Divider(height: 16),
                LabelValueRow(
                  label: 'Total',
                  value: formatRupiah(trx.total),
                  bold: true,
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.line)),
        ),
        child: SafeArea(top: false, child: _buildActions()),
      ),
    );
  }

  Widget _buildActions() {
    if (_isPending) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PrimaryButton(
            label: 'Saya Sudah Bayar',
            loading: _processing,
            onPressed: _processing ? null : _bayar,
          ),
          TextButton(
            onPressed: _processing ? null : _batalkan,
            child: const Text('Batalkan Tagihan'),
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_trx.status == TransactionStatus.success)
          PrimaryButton(
            label: 'Lihat E-Ticket',
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ReceiptScreen(transaction: _trx),
              ),
            ),
          ),
        TextButton(
          onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
          child: const Text('Selesai'),
        ),
      ],
    );
  }
}
