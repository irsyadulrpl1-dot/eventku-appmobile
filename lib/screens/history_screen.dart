import 'package:material_ui/material_ui.dart';
import 'package:eventku/data/transaction_repository.dart';
import 'package:eventku/models/transaction_model.dart';
import 'package:eventku/screens/payment_screen.dart';
import 'package:eventku/screens/receipt_screen.dart';
import 'package:eventku/theme/app_colors.dart';
import 'package:eventku/utils/currency_formatter.dart';
import 'package:eventku/utils/date_formatter.dart';
import 'package:eventku/widgets/empty_state.dart';
import 'package:eventku/widgets/loading_widget.dart';
import 'package:eventku/widgets/status_badge.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  static const List<(String, String?)> _filters = [
    ('Semua', null),
    ('Menunggu', TransactionStatus.pending),
    ('Berhasil', TransactionStatus.success),
    ('Kedaluwarsa', TransactionStatus.expired),
    ('Dibatalkan', TransactionStatus.cancelled),
  ];

  final TransactionRepository _repository = TransactionRepository();

  String? _status;
  List<TransactionModel> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await _repository.expireOverdue();
    final data = await _repository.getAll(status: _status);
    if (!mounted) return;
    setState(() {
      _items = data;
      _loading = false;
    });
  }

  Future<void> _buka(TransactionModel trx) async {
    final Widget layar = trx.status == TransactionStatus.pending
        ? PaymentScreen(transaction: trx)
        : ReceiptScreen(transaction: trx);

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => layar),
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pesanan', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 4),
                const Text(
                  'Riwayat transaksi dan e-ticket kamu.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              children: [
                for (final (label, status) in _filters)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(label),
                      selected: _status == status,
                      showCheckmark: false,
                      labelStyle: TextStyle(
                        color: _status == status
                            ? Colors.white
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.surface,
                      side: BorderSide(
                        color: _status == status
                            ? AppColors.primary
                            : AppColors.line,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      onSelected: (_) {
                        setState(() {
                          _status = status;
                          _loading = true;
                        });
                        _load();
                      },
                    ),
                  ),
              ],
            ),
          ),
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  Widget _buildList() {
    if (_loading) {
      return const LoadingWidget(message: 'Memuat pesanan...');
    }

    if (_items.isEmpty) {
      return EmptyState(
        icon: Icons.receipt_long_outlined,
        title: _status == null ? 'Belum ada pesanan' : 'Tidak ada pesanan',
        message: _status == null
            ? 'Tiket yang kamu beli akan muncul di sini.'
            : 'Tidak ada transaksi dengan status ini.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final trx = _items[index];
        final ticketCount = trx.items.fold<int>(
          0,
          (sum, item) => sum + item.quantity,
        );
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Material(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              onTap: () => _buka(trx),
              child: Ink(
                decoration: appSurfaceDecoration(radius: AppRadius.lg),
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            trx.eventTitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                        const SizedBox(width: 8),
                        StatusBadge(status: trx.status),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      trx.id,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule_rounded,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            formatWaktuSingkat(trx.createdAt),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Text(
                          '$ticketCount tiket',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          formatRupiah(trx.total),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          trx.status == TransactionStatus.success
                              ? 'Lihat tiket'
                              : 'Lihat detail',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.primary,
                          size: 18,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
