import 'dart:convert';

import 'package:food_app/constants/app_constanst.dart';
import 'package:http/http.dart' as http;

Uri _uri(String path) {
  return Uri.parse('${AppConstants.baseUrl}$path');
}

const headers = {
  'Content-Type': 'application/json',
  'Accept': 'application/json',
};


// ================= PRODUCTS =================

Future<List<dynamic>> getProducts() async {
  try {
    final response = await http.get(
      _uri('/barang'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    return [];
  } catch (e) {
    return [];
  }
}


// ================= USER =================

Future<Map<String, dynamic>> getUser(int id) async {
  try {
    final response = await http.get(
      _uri('/user/$id'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    return {};
  } catch (e) {
    return {};
  }
}


// ================= HISTORY =================

Future<List<dynamic>> getHistory() async {
  final response = await http.get(
    Uri.parse('${AppConstants.baseUrl}/transaksi'),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  }

  return [];
}


// ================= WISHLIST =================

Future<List<dynamic>> getWishlist() async {
  try {
    final response = await http.get(
      _uri('/wishlist'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    return [];
  } catch (e) {
    return [];
  }
}

Future<bool> addWishlist(int barangId) async {
  try {
    final response = await http.post(
      _uri('/wishlist'),
      headers: headers,
      body: jsonEncode({
        "barang_id": barangId,
      }),
    );

    return response.statusCode == 200 ||
        response.statusCode == 201;
  } catch (e) {
    return false;
  }
}

Future<bool> deleteWishlist(int id) async {
  try {
    final response = await http.delete(
      _uri('/wishlist/$id'),
      headers: headers,
    );

    return response.statusCode == 200 ||
        response.statusCode == 204;
  } catch (e) {
    return false;
  }
}


// ================= TRANSAKSI =================

Future<bool> postTransaksi(
  List<Map<String, dynamic>> items,
  int total,
) async {
  try {
    final response = await http.post(
      _uri('/transaksi'),
      headers: headers,
      body: jsonEncode({
        "items": items,
        "total": total,
      }),
    );

    print(response.body);

    return response.statusCode == 200 ||
        response.statusCode == 201;
  } catch (e) {
    print(e.toString());

    return false;
  }
}


// ================= AUTH =================

Future<Map<String, dynamic>> login(
  String email,
  String password,
) async {
  try {
    final response = await http.post(
      _uri('/login'),
      headers: headers,
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    return {};
  } catch (e) {
    return {};
  }
}

Future<Map<String, dynamic>> register(
  String name,
  String email,
  String password,
) async {
  try {
    final response = await http.post(
      _uri('/register'),
      headers: headers,
      body: jsonEncode({
        "name": name,
        "email": email,
        "password": password,
      }),
    );

    if (response.statusCode == 200 ||
        response.statusCode == 201) {
      return jsonDecode(response.body);
    }

    return {};
  } catch (e) {
    return {};
  }
}