import 'dart:convert';
import 'package:food_app/constants/app_constanst.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // ================= BASE URL =================

  static Uri uri(String path) {
    return Uri.parse('${AppConstants.baseUrl}$path');
  }

  // ================= TOKEN =================

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<Map<String, String>> getHeaders() async {
    final token = await getToken();

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty)
        'Authorization': 'Bearer $token',
    };
  }

  // ================= DEBUG HELPER =================

  static void logResponse(String title, http.Response res) {
    print('====================');
    print('[$title]');
    print('STATUS: ${res.statusCode}');
    print('BODY: ${res.body}');
    print('====================');
  }

  // ================= AUTH =================

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        uri('/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      logResponse("LOGIN", response);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return data;
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Login gagal',
        'status': response.statusCode,
      };
    } catch (e) {
      print("LOGIN ERROR: $e");
      return {
        'success': false,
        'message': 'Tidak bisa connect ke server',
        'error': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? username,
  }) async {
    try {
      final response = await http.post(
        uri('/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          if (phone != null) 'phone': phone,
          if (username != null) 'username': username,
        }),
      );

      logResponse("REGISTER", response);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return data;
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Register gagal',
      };
    } catch (e) {
      print("REGISTER ERROR: $e");
      return {
        'success': false,
        'message': 'Server error',
        'error': e.toString(),
      };
    }
  }

  // ================= PRODUCTS =================

  static Future<List<dynamic>> getProducts() async {
    try {
      final headers = await getHeaders();

      final response = await http.get(
        uri('/barang'),
        headers: headers,
      );

      logResponse("PRODUCTS", response);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return [];
    } catch (e) {
      print("PRODUCTS ERROR: $e");
      return [];
    }
  }

  static Future<Map<String, dynamic>> addBarang(
    Map<String, dynamic> data,
  ) async {
    try {
      final headers = await getHeaders();

      final response = await http.post(
        uri('/barang'),
        headers: headers,
        body: jsonEncode(data),
      );

      logResponse("ADD BARANG", response);

      return jsonDecode(response.body);
    } catch (e) {
      print("ADD BARANG ERROR: $e");
      return {'success': false, 'message': e.toString()};
    }
  }

  // ================= USER =================

  static Future<Map<String, dynamic>> getUser(int id) async {
    try {
      final headers = await getHeaders();

      final response = await http.get(
        uri('/user/$id'),
        headers: headers,
      );

      logResponse("USER", response);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return {};
    } catch (e) {
      print("USER ERROR: $e");
      return {};
    }
  }

  // ================= WISHLIST =================

  static Future<List<dynamic>> getWishlist() async {
    try {
      final headers = await getHeaders();

      final response = await http.get(
        uri('/wishlist'),
        headers: headers,
      );

      logResponse("WISHLIST", response);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return [];
    } catch (e) {
      print("WISHLIST ERROR: $e");
      return [];
    }
  }

  static Future<bool> addWishlist(int barangId) async {
    try {
      final headers = await getHeaders();

      final response = await http.post(
        uri('/wishlist'),
        headers: headers,
        body: jsonEncode({'barang_id': barangId}),
      );

      logResponse("ADD WISHLIST", response);

      return response.statusCode == 200 ||
          response.statusCode == 201;
    } catch (e) {
      print("ADD WISHLIST ERROR: $e");
      return false;
    }
  }

  static Future<bool> deleteWishlist(int id) async {
    try {
      final headers = await getHeaders();

      final response = await http.delete(
        uri('/wishlist/$id'),
        headers: headers,
      );

      logResponse("DELETE WISHLIST", response);

      return response.statusCode == 200 ||
          response.statusCode == 204;
    } catch (e) {
      print("DELETE WISHLIST ERROR: $e");
      return false;
    }
  }

  // ================= TRANSAKSI =================

  static Future<bool> postTransaksi(
    List<Map<String, dynamic>> items,
    int total,
  ) async {
    try {
      final headers = await getHeaders();

      final response = await http.post(
        uri('/transaksi'),
        headers: headers,
        body: jsonEncode({
          'items': items,
          'total': total,
        }),
      );

      logResponse("TRANSAKSI", response);

      return response.statusCode == 200 ||
          response.statusCode == 201;
    } catch (e) {
      print("TRANSAKSI ERROR: $e");
      return false;
    }
  }

  static Future<List<dynamic>> getHistory() async {
    try {
      final headers = await getHeaders();

      final response = await http.get(
        uri('/transaksi'),
        headers: headers,
      );

      logResponse("HISTORY", response);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return [];
    } catch (e) {
      print("HISTORY ERROR: $e");
      return [];
    }
  }

  // ================= FORGOT PASSWORD =================

  static Future<Map<String, dynamic>> forgotPassword(
    String emailOrPhone,
  ) async {
    try {
      final response = await http.post(
        uri('/forgot-password'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': emailOrPhone}),
      );

      logResponse("FORGOT PASSWORD", response);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return {
        'success': false,
        'message': 'Gagal kirim request'
      };
    } catch (e) {
      print("FORGOT PASSWORD ERROR: $e");
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
}