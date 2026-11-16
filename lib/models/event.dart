import 'package:eventku/models/ticket_category.dart';

class Event {
  final int id;
  final String title;
  final String description;
  final String location;
  final DateTime eventDate;
  final String posterUrl;
  final int minPrice;
  final List<String> images;
  final List<TicketCategory> ticketCategories;

  const Event({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.eventDate,
    required this.posterUrl,
    required this.minPrice,
    required this.images,
    required this.ticketCategories,
  });

  // Menerjemahkan JSON dari server menjadi objek Event
  factory Event.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as int;
    return Event(
      id: id,
      title: json['title'] as String,
      description: json['description'] as String,
      location: json['location'] as String,
      eventDate: DateTime.parse(json['event_date'] as String),
      posterUrl: json['poster_url'] as String,
      minPrice: json['min_price'] as int,
      images: List<String>.from(json['images'] as List),
      ticketCategories: (json['ticket_categories'] as List)
          .map(
            (c) =>
                TicketCategory.fromJson(c as Map<String, dynamic>, eventId: id),
          )
          .toList(),
    );
  }
}
