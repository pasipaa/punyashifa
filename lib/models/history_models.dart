class HistoryItem {
  final int id;
  final int total;
  final String tanggal;

  HistoryItem({
    required this.id,
    required this.total,
    required this.tanggal,
  });

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      id: json['id'] ?? 0,
      total: json['total'] ?? 0,
      tanggal: json['tanggal'] ?? '',
    );
  }
}