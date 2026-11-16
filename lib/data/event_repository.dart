import 'package:eventku/data/api_service.dart';
import 'package:eventku/data/database_helper.dart';
import 'package:eventku/models/event.dart';
import 'package:eventku/models/ticket_category.dart';
import 'package:sqflite/sqflite.dart';

class EventRepository {
  final ApiService _api = ApiService();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Membaca acara dari database HP
  Future<List<Event>> getLocalEvents() async {
    final db = await _dbHelper.database;
    final eventRows = await db.query('events', orderBy: 'event_date ASC');
    final imageRows = await db.query('event_images', orderBy: 'sort_order ASC');
    final categoryRows = await db.query('ticket_categories');

    return eventRows.map((row) {
      final id = row['id'] as int;
      return Event(
        id: id,
        title: row['title'] as String,
        description: row['description'] as String,
        location: row['location'] as String,
        eventDate: DateTime.parse(row['event_date'] as String),
        posterUrl: row['poster_url'] as String,
        minPrice: row['min_price'] as int,
        images: imageRows
            .where((i) => i['event_id'] == id)
            .map((i) => i['image_url'] as String)
            .toList(),
        ticketCategories: categoryRows
            .where((c) => c['event_id'] == id)
            .map((c) => TicketCategory.fromMap(c))
            .toList(),
      );
    }).toList();
  }

  // Menyimpan acara dari server ke database HP
  Future<void> saveEvents(List<Event> events) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      // Foto dan kategori tiket dibuat ulang dari data server
      await txn.delete('event_images');
      await txn.delete('ticket_categories');

      for (final event in events) {
        await txn.insert('events', {
          'id': event.id,
          'title': event.title,
          'description': event.description,
          'location': event.location,
          'event_date': event.eventDate.toIso8601String(),
          'poster_url': event.posterUrl,
          'min_price': event.minPrice,
          'cached_at': DateTime.now().toIso8601String(),
        }, conflictAlgorithm: ConflictAlgorithm.replace);

        for (var i = 0; i < event.images.length; i++) {
          await txn.insert('event_images', {
            'event_id': event.id,
            'image_url': event.images[i],
            'sort_order': i,
          });
        }

        for (final category in event.ticketCategories) {
          await txn.insert('ticket_categories', category.toMap());
        }
      }

      // Hapus acara yang sudah tidak ada di server
      final ids = events.map((e) => e.id).toList();
      if (ids.isNotEmpty) {
        final tanda = List.filled(ids.length, '?').join(',');
        await txn.delete('events', where: 'id NOT IN ($tanda)', whereArgs: ids);
      }
    });
  }

  // Ambil dari server → simpan → baca dari database
  Future<List<Event>> refreshFromServer() async {
    final events = await _api.fetchEvents();
    await saveEvents(events);
    return getLocalEvents();
  }
}
