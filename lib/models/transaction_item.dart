class TransactionItem {
  final int ticketCategoryId;
  final String categoryName; // salinan nama
  final int unitPrice; // salinan harga saat itu
  final int quantity;

  const TransactionItem({
    required this.ticketCategoryId,
    required this.categoryName,
    required this.unitPrice,
    required this.quantity,
  });

  int get subtotal => unitPrice * quantity;

  Map<String, Object?> toMap(String transactionId) => {
    'transaction_id': transactionId,
    'ticket_category_id': ticketCategoryId,
    'category_name': categoryName,
    'unit_price': unitPrice,
    'quantity': quantity,
  };

  factory TransactionItem.fromMap(Map<String, Object?> map) {
    return TransactionItem(
      ticketCategoryId: map['ticket_category_id'] as int,
      categoryName: map['category_name'] as String,
      unitPrice: map['unit_price'] as int,
      quantity: map['quantity'] as int,
    );
  }
}
