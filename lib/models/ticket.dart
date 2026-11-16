class Ticket {
  final int id;
  final String transactionId;
  final String categoryName;
  final String qrData;

  const Ticket({
    required this.id,
    required this.transactionId,
    required this.categoryName,
    required this.qrData,
  });

  factory Ticket.fromMap(Map<String, Object?> map) {
    return Ticket(
      id: map['id'] as int,
      transactionId: map['transaction_id'] as String,
      categoryName: map['category_name'] as String,
      qrData: map['qr_data'] as String,
    );
  }
}
