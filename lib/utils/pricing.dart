// Aturan biaya. Ubah sesuai ketentuan dari gurumu.
const int kBiayaLayanan = 5000; // tetap per transaksi
const int kPersenPajak = 10; // persen dari subtotal
const int kMaksTiket = 10; // maksimal per kategori
const Duration kBatasBayar = Duration(hours: 24);

class RincianHarga {
  final int subtotal;
  final int biayaLayanan;
  final int pajak;
  final int total;

  const RincianHarga._(
    this.subtotal,
    this.biayaLayanan,
    this.pajak,
    this.total,
  );

  factory RincianHarga.dari(int subtotal) {
    // Belum ada tiket dipilih → semua nol
    if (subtotal <= 0) return const RincianHarga._(0, 0, 0, 0);

    final pajak = subtotal * kPersenPajak ~/ 100; // ~/ = bagi, hasil bulat
    final total = subtotal + kBiayaLayanan + pajak;
    return RincianHarga._(subtotal, kBiayaLayanan, pajak, total);
  }
}
