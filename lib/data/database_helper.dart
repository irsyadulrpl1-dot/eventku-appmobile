import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static Database? _db;

  Future<Database> get database async {
    _db ??= await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final path = join(await getDatabasesPath(), 'eventku.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE events (
            id INTEGER PRIMARY KEY,
            title TEXT NOT NULL,
            description TEXT NOT NULL,
            location TEXT NOT NULL,
            event_date TEXT NOT NULL,
            poster_url TEXT NOT NULL,
            min_price INTEGER NOT NULL,
            cached_at TEXT
          )''');
        await db.execute('''
          CREATE TABLE event_images (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            event_id INTEGER NOT NULL,
            image_url TEXT NOT NULL,
            sort_order INTEGER NOT NULL DEFAULT 0
          )''');
        await db.execute('''
          CREATE TABLE ticket_categories (
            id INTEGER PRIMARY KEY,
            event_id INTEGER NOT NULL,
            name TEXT NOT NULL,
            price INTEGER NOT NULL
          )''');
        await db.execute('''
          CREATE TABLE transactions (
            id TEXT PRIMARY KEY,
            event_id INTEGER NOT NULL,
            event_title TEXT NOT NULL,
            payment_method TEXT NOT NULL,
            subtotal INTEGER NOT NULL,
            service_fee INTEGER NOT NULL,
            tax INTEGER NOT NULL,
            total INTEGER NOT NULL,
            status TEXT NOT NULL,
            created_at TEXT NOT NULL,
            expires_at TEXT NOT NULL,
            paid_at TEXT
          )''');
        await db.execute('''
          CREATE TABLE transaction_items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            transaction_id TEXT NOT NULL,
            ticket_category_id INTEGER NOT NULL,
            category_name TEXT NOT NULL,
            unit_price INTEGER NOT NULL,
            quantity INTEGER NOT NULL
          )''');
        await db.execute('''
          CREATE TABLE tickets (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            transaction_id TEXT NOT NULL,
            category_name TEXT NOT NULL,
            qr_data TEXT NOT NULL
          )''');
      },
    );
  }
}
