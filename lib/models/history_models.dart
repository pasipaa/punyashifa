class HistoryItem {
  final int id;
  final int userId;
  final int barangId;
  final String namaBarang;
  final String image;
  final int harga;
  final int quantity;
  final String tanggal;
  final String status;

  HistoryItem({
    required this.id,
    required this.userId,
    required this.barangId,
    required this.namaBarang,
    required this.image,
    required this.harga,
    required this.quantity,
    required this.tanggal,
    required this.status,
  });

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      barangId: json['barang_id'] ?? 0,
      namaBarang: json['nama_barang'] ?? '',
      image: json['image'] ?? '',
      harga: json['harga'] ?? 0,
      quantity: json['quantity'] ?? 0,
      tanggal: json['tanggal'] ?? '',
      status: json['status'] ?? '',
    );
  }

  int get total => harga * quantity;
}
