import 'dart:convert';
import 'package:food_app/services/base_url.dart';
import 'package:http/http.dart' as http;

class BarangService {
  Future<List<dynamic>> getBarang() async {
    try {
      final res = await http.get(
        Uri.parse('${BaseUrl}/barang'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      if (res.statusCode == 200) return jsonDecode(res.body);
      return [];
    } catch (e) {
      throw Exception('Koneksi gagal: $e');
    }
  }
}
