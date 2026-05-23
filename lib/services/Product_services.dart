import 'dart:convert';
import 'package:food_app/models/Product_models.dart';
import 'package:food_app/services/base_url.dart';
import 'package:http/http.dart' as http;

class ProductService {
  static Uri _uri(String path) => Uri.parse('${BaseUrl}$path');

  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Future<List<Product>> getAllProducts() async {
    try {
      final res = await http.get(_uri('/barang'), headers: _headers);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final List list = data is List ? data : data['data'] ?? [];
        return list.map((e) => Product.fromJson(e)).toList();
      }
      throw Exception('Gagal memuat produk: ${res.statusCode}');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<List<Product>> getProductsByCategory(String category) async {
    try {
      final res = await http.get(
        Uri.parse('${BaseUrl}/barang?category=$category'),
        headers: _headers,
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final List list = data is List ? data : data['data'] ?? [];
        return list.map((e) => Product.fromJson(e)).toList();
      }
      throw Exception('Gagal memuat produk');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<Product> getProductById(int id) async {
    try {
      final res = await http.get(_uri('/barang/$id'), headers: _headers);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return Product.fromJson(data is Map ? data : data['data']);
      }
      throw Exception('Produk tidak ditemukan');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<bool> toggleWishlist(int productId, bool currentState) async {
    try {
      final res = await http.post(
        _uri('/wishlist/toggle'),
        headers: _headers,
        body: jsonEncode({'product_id': productId}),
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<Map<String, dynamic>> checkout(
      List<Map<String, dynamic>> items, int total) async {
    try {
      final res = await http.post(
        _uri('/transaksi'),
        headers: _headers,
        body: jsonEncode({
          'items': items,
          'total': total,
          'payment_method': 'online',
        }),
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        return jsonDecode(res.body);
      }
      throw Exception('Checkout gagal: ${res.statusCode}');
    } catch (e) {
      throw Exception('Error checkout: $e');
    }
  }
}
