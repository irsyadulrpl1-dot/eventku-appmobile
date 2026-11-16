import 'package:eventku/models/transaction_item.dart';

// Empat status sesuai tugas
class TransactionStatus {
  static const pending = 'pending'; // menunggu pembayaran
  static const success = 'success'; // berhasil
  static const expired = 'expired'; // kedaluwarsa
  static const cancelled = 'cancelled'; // dibatalkan
}

class TransactionModel {
  final String id;
  final int eventId;
  final String eventTitle;
  final String paymentMethod;
  final int subtotal;
  final int serviceFee;
  final int tax;
  final int total;
  final String status;
  final DateTime createdAt;
  final DateTime expiresAt;
  final DateTime? paidAt; // kosong sebelum dibayar
  final List<TransactionItem> items;

  const TransactionModel({
    required this.id,
    required this.eventId,
    required this.eventTitle,
    required this.paymentMethod,
    required this.subtotal,
    required this.serviceFee,
    required this.tax,
    required this.total,
    required this.status,
    required this.createdAt,
    required this.expiresAt,
    this.paidAt,
    required this.items,
  });

  // Waktu disimpan dalam UTC (format ISO), ditampilkan sebagai WIB
  Map<String, Object?> toMap() => {
    'id': id,
    'event_id': eventId,
    'event_title': eventTitle,
    'payment_method': paymentMethod,
    'subtotal': subtotal,
    'service_fee': serviceFee,
    'tax': tax,
    'total': total,
    'status': status,
    'created_at': createdAt.toUtc().toIso8601String(),
    'expires_at': expiresAt.toUtc().toIso8601String(),
    'paid_at': paidAt?.toUtc().toIso8601String(),
  };

  factory TransactionModel.fromMap(
    Map<String, Object?> map,
    List<TransactionItem> items,
  ) {
    final paid = map['paid_at'] as String?;
    return TransactionModel(
      id: map['id'] as String,
      eventId: map['event_id'] as int,
      eventTitle: map['event_title'] as String,
      paymentMethod: map['payment_method'] as String,
      subtotal: map['subtotal'] as int,
      serviceFee: map['service_fee'] as int,
      tax: map['tax'] as int,
      total: map['total'] as int,
      status: map['status'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      expiresAt: DateTime.parse(map['expires_at'] as String),
      paidAt: paid == null ? null : DateTime.parse(paid),
      items: items,
    );
  }
}
