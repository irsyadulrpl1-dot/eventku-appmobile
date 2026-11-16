import 'package:eventku/data/database_helper.dart';
import 'package:eventku/models/transaction_item.dart';
import 'package:eventku/models/transaction_model.dart';
import 'package:eventku/models/ticket.dart';

class TransactionRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Menyimpan transaksi baru (dari Tahap 6)
  Future<void> createTransaction(TransactionModel trx) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      await txn.insert('transactions', trx.toMap());
      for (final item in trx.items) {
        await txn.insert('transaction_items', item.toMap(trx.id));
      }
    });
  }

  // Membaca satu transaksi lengkap dengan isinya
  Future<TransactionModel?> getById(String id) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;

    final itemRows = await db.query(
      'transaction_items',
      where: 'transaction_id = ?',
      whereArgs: [id],
      orderBy: 'id ASC',
    );
    final items = itemRows.map((r) => TransactionItem.fromMap(r)).toList();
    return TransactionModel.fromMap(rows.first, items);
  }

  // Pembayaran: ubah status + catat waktu lunas + buat e-ticket.
  // Mengembalikan true kalau berhasil.
  Future<bool> markAsPaid(String id) async {
    final db = await _dbHelper.database;
    return db.transaction<bool>((txn) async {
      final rows = await txn.query(
        'transactions',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (rows.isEmpty) return false;

      final row = rows.first;
      // Hanya tagihan yang masih menunggu yang boleh dibayar
      if (row['status'] != TransactionStatus.pending) return false;

      final now = DateTime.now().toUtc();
      final expiresAt = DateTime.parse(row['expires_at'] as String);

      // Sudah lewat batas waktu → jadikan kedaluwarsa
      if (!expiresAt.isAfter(now)) {
        await txn.update(
          'transactions',
          {'status': TransactionStatus.expired},
          where: 'id = ?',
          whereArgs: [id],
        );
        return false;
      }

      await txn.update(
        'transactions',
        {
          'status': TransactionStatus.success,
          'paid_at': now.toIso8601String(), // waktu pelunasan (UTC)
        },
        where: 'id = ?',
        whereArgs: [id],
      );

      // Buat satu e-ticket untuk setiap tiket yang dibeli
      final items = await txn.query(
        'transaction_items',
        where: 'transaction_id = ?',
        whereArgs: [id],
      );
      for (final item in items) {
        final categoryId = item['ticket_category_id'] as int;
        final nama = item['category_name'] as String;
        final jumlah = item['quantity'] as int;
        for (var n = 1; n <= jumlah; n++) {
          await txn.insert('tickets', {
            'transaction_id': id,
            'category_name': nama,
            'qr_data': 'EVENTKU|$id|$categoryId|$n',
          });
        }
      }
      return true;
    });
  }

  // Pembatalan: hanya untuk tagihan yang masih menunggu
  Future<bool> cancel(String id) async {
    final db = await _dbHelper.database;
    final count = await db.update(
      'transactions',
      {'status': TransactionStatus.cancelled},
      where: 'id = ? AND status = ?',
      whereArgs: [id, TransactionStatus.pending],
    );
    return count > 0;
  }

  // Menandai semua tagihan yang lewat batas waktu sebagai kedaluwarsa
  Future<int> expireOverdue() async {
    final db = await _dbHelper.database;
    final now = DateTime.now().toUtc();

    final rows = await db.query(
      'transactions',
      columns: ['id', 'expires_at'],
      where: 'status = ?',
      whereArgs: [TransactionStatus.pending],
    );

    var jumlah = 0;
    for (final row in rows) {
      final expiresAt = DateTime.parse(row['expires_at'] as String);
      if (!expiresAt.isAfter(now)) {
        await db.update(
          'transactions',
          {'status': TransactionStatus.expired},
          where: 'id = ? AND status = ?',
          whereArgs: [row['id'], TransactionStatus.pending],
        );
        jumlah++;
      }
    }
    return jumlah;
  }

  // Semua transaksi (terbaru di atas), boleh disaring berdasarkan status
  Future<List<TransactionModel>> getAll({String? status}) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'transactions',
      where: status == null ? null : 'status = ?',
      whereArgs: status == null ? null : [status],
      orderBy: 'created_at DESC',
    );
    if (rows.isEmpty) return [];

    final itemRows = await db.query('transaction_items', orderBy: 'id ASC');

    return rows.map((row) {
      final id = row['id'] as String;
      final items = itemRows
          .where((r) => r['transaction_id'] == id)
          .map((r) => TransactionItem.fromMap(r))
          .toList();
      return TransactionModel.fromMap(row, items);
    }).toList();
  }

  // E-ticket milik satu transaksi
  Future<List<Ticket>> getTickets(String transactionId) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'tickets',
      where: 'transaction_id = ?',
      whereArgs: [transactionId],
      orderBy: 'id ASC',
    );
    return rows.map((r) => Ticket.fromMap(r)).toList();
  }
}
