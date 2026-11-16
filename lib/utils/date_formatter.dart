import 'package:intl/intl.dart';

String formatTanggal(DateTime date) {
  return DateFormat('EEEE, d MMMM y', 'id_ID').format(date);
}

String formatJam(DateTime date) {
  return '${DateFormat('HH.mm', 'id_ID').format(date)} WIB';
}

// Mengubah waktu apa pun menjadi jam WIB (UTC+7)
DateTime keWib(DateTime date) {
  return date.toUtc().add(const Duration(hours: 7));
}

// Contoh hasil: Jumat, 13 November 2026, pukul 15:54 WIB
String formatWaktuLengkap(DateTime date) {
  final wib = keWib(date);
  final teks = DateFormat("EEEE, d MMMM y, 'pukul' HH:mm", 'id_ID').format(wib);
  return '$teks WIB';
}

// Contoh: Duration 1 jam 2 menit 3 detik → "01:02:03"
String formatSisaWaktu(Duration d) {
  String dua(int n) => n.toString().padLeft(2, '0');
  return '${dua(d.inHours)}:${dua(d.inMinutes % 60)}:${dua(d.inSeconds % 60)}';
}

// Contoh: 13 Nov 2026, 15:54 WIB
String formatWaktuSingkat(DateTime date) {
  final wib = keWib(date);
  return '${DateFormat('d MMM y, HH:mm', 'id_ID').format(wib)} WIB';
}
