class TicketCategory {
  final int id;
  final int eventId;
  final String name;
  final int price;

  const TicketCategory({
    required this.id,
    required this.eventId,
    required this.name,
    required this.price,
  });

  // Dari JSON server
  factory TicketCategory.fromJson(
    Map<String, dynamic> json, {
    required int eventId,
  }) {
    return TicketCategory(
      id: json['id'] as int,
      eventId: eventId,
      name: json['name'] as String,
      price: json['price'] as int,
    );
  }

  // Dari baris database
  factory TicketCategory.fromMap(Map<String, Object?> map) {
    return TicketCategory(
      id: map['id'] as int,
      eventId: map['event_id'] as int,
      name: map['name'] as String,
      price: map['price'] as int,
    );
  }

  // Ke baris database
  Map<String, Object?> toMap() => {
    'id': id,
    'event_id': eventId,
    'name': name,
    'price': price,
  };
}
