import 'dart:convert';

import 'package:food_app/services/base_url.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static Uri uri(String path) {
    return Uri.parse(
      '${BaseUrl}$path',
    );
  }

  static Future<void> saveToken(
    String token,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      'token',
      token,
    );
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString('token');
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.clear();
  }

  static Future<Map<String, String>> getHeaders() async {
    final token = await getToken();

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  static void logResponse(
    String title,
    http.Response response,
  ) {
    print('====================');

    print('[$title]');

    print(
      'STATUS: ${response.statusCode}',
    );

    print(
      'BODY: ${response.body}',
    );

    print('====================');
  }

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

      logResponse(
        "LOGIN",
        response,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data['token'] != null) {
          await saveToken(
            data['token'],
          );
        }

        return {
          'success': true,
          'data': data,
          'token': data['token'],
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Login gagal',
      };
    } catch (e) {
      print(
        "LOGIN ERROR: $e",
      );

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

      logResponse(
        "REGISTER",
        response,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': data,
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Register gagal',
      };
    } catch (e) {
      print(
        "REGISTER ERROR: $e",
      );

      return {
        'success': false,
        'message': 'Server error',
        'error': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> forgotPassword(
    String email,
  ) async {
    try {
      final response = await http.post(
        uri('/forgot-password'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
        }),
      );

      logResponse(
        "FORGOT PASSWORD",
        response,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Gagal kirim request',
      };
    } catch (e) {
      print(
        "FORGOT PASSWORD ERROR: $e",
      );

      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  static Future<List<dynamic>> getProducts() async {
    try {
      final headers = await getHeaders();

      final response = await http.get(
        uri('/barang'),
        headers: headers,
      );

      logResponse(
        "PRODUCTS",
        response,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is List) {
          return data;
        }

        if (data['data'] != null) {
          return data['data'];
        }
      }

      return [];
    } catch (e) {
      print(
        "PRODUCTS ERROR: $e",
      );

      return [];
    }
  }

  static Future<Map<String, dynamic>> getUser(
    int id,
  ) async {
    try {
      final headers = await getHeaders();

      final response = await http.get(
        uri('/user/$id'),
        headers: headers,
      );

      logResponse(
        "USER",
        response,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['data'] != null) {
          return data['data'];
        }

        return data;
      }

      return {};
    } catch (e) {
      print(
        "USER ERROR: $e",
      );

      return {};
    }
  }

  static Future<bool> addWishlist(
    Map<String, dynamic> item,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final oldWishlist = prefs.getString(
        'wishlist',
      );

      List wishlist = [];

      if (oldWishlist != null) {
        wishlist = jsonDecode(oldWishlist);
      }

      final alreadyExist = wishlist.any(
        (e) => e['id'] == item['id'],
      );

      if (!alreadyExist) {
        wishlist.add(item);

        await prefs.setString(
          'wishlist',
          jsonEncode(wishlist),
        );
      }

      return true;
    } catch (e) {
      print(
        "ADD WISHLIST ERROR: $e",
      );

      return false;
    }
  }

  static Future<List<dynamic>> getWishlist() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final data = prefs.getString(
        'wishlist',
      );

      if (data != null) {
        return jsonDecode(data);
      }

      return [];
    } catch (e) {
      print(
        "GET WISHLIST ERROR: $e",
      );

      return [];
    }
  }

  static Future<bool> removeWishlist(
    int id,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final data = prefs.getString(
        'wishlist',
      );

      if (data == null) {
        return false;
      }

      List wishlist = jsonDecode(data);

      wishlist.removeWhere(
        (e) => e['id'] == id,
      );

      await prefs.setString(
        'wishlist',
        jsonEncode(wishlist),
      );

      return true;
    } catch (e) {
      print(
        "REMOVE WISHLIST ERROR: $e",
      );

      return false;
    }
  }

  static Future<bool> postTransaksi(
    List<Map<String, dynamic>> items,
    int total,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      List history = [];

      for (var item in items) {
        history.add({
          "id": DateTime.now().millisecondsSinceEpoch,
          "user_id": 1,
          "barang_id": item['barang_id'] ?? 0,
          "nama_barang": item['nama_barang'] ?? 'Produk',
          "image": item['image'] ?? '',
          "harga": item['harga'] ?? 0,
          "quantity": item['quantity'] ?? 1,
          "tanggal": DateTime.now().toString().substring(0, 10),
          "status": "success",
        });
      }

      await prefs.setString(
        'history',
        jsonEncode(history),
      );

      return true;
    } catch (e) {
      print(
        "TRANSAKSI ERROR: $e",
      );

      return false;
    }
  }

  static Future<List<dynamic>> getHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final data = prefs.getString(
        'history',
      );

      if (data != null) {
        return jsonDecode(data);
      }

      return [];
    } catch (e) {
      print(
        "HISTORY ERROR: $e",
      );

      return [];
    }
  }

  static Future<bool> clearHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.remove('history');

      return true;
    } catch (e) {
      print(
        "CLEAR HISTORY ERROR: $e",
      );

      return false;
    }
  }

  static Future<bool> clearWishlist() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.remove('wishlist');

      return true;
    } catch (e) {
      print(
        "CLEAR WISHLIST ERROR: $e",
      );

      return false;
    }
  }

  static Future<bool> removeWishlistByIndex(int index) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('wishlist');
      if (data == null) return false;

      List wishlist = jsonDecode(data);
      if (index < 0 || index >= wishlist.length) return false;

      wishlist.removeAt(index);
      await prefs.setString('wishlist', jsonEncode(wishlist));
      return true;
    } catch (e) {
      print('REMOVE WISHLIST BY INDEX ERROR: $e');
      return false;
    }
  }

  static Future<void> removeHistory(int index) async {}
}
