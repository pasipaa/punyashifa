import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:food_app/models/CartItems_models.dart';
import 'package:food_app/models/History_models.dart';
import 'package:food_app/models/Product_models.dart';
import 'package:food_app/services/API_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductController extends ChangeNotifier {
  List<Product> _allProducts = [];

  List<Product> _filteredProducts = [];

  List<Product> get filteredProducts => _filteredProducts;

  final List<CartItem> _cartItems = [];

  List<CartItem> get cartItems => _cartItems;

  int get cartCount => _cartItems.fold(
        0,
        (sum, item) => sum + item.quantity,
      );

  int get cartTotal => _cartItems.fold(
        0,
        (sum, item) => sum + item.totalPrice,
      );

  List<HistoryItem> _histories = [];

  List<HistoryItem> get histories => _histories;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  ProductController() {
    loadCart();
    loadHistory();
  }

  Future<void> loadProducts() async {
    _isLoading = true;

    notifyListeners();

    try {
      final raw = await ApiService.getProducts();

      _allProducts = raw
          .map<Product>(
            (e) => Product.fromJson(e),
          )
          .toList();

      _filteredProducts = List.from(_allProducts);
    } catch (e) {
      debugPrint(
        "LOAD PRODUCT ERROR: $e",
      );

      _allProducts = [];

      _filteredProducts = [];
    }

    _isLoading = false;

    notifyListeners();
  }

  Future<void> loadByCategory(
    String category,
  ) async {
    _isLoading = true;

    notifyListeners();

    try {
      final raw = await ApiService.getProducts();

      _allProducts = raw
          .map<Product>(
            (e) => Product.fromJson(e),
          )
          .toList();

      _filteredProducts = _allProducts.where((p) {
        return p.category.toLowerCase().contains(
              category.toLowerCase(),
            );
      }).toList();
    } catch (e) {
      debugPrint(
        "CATEGORY ERROR: $e",
      );

      _filteredProducts = [];
    }

    _isLoading = false;

    notifyListeners();
  }

  void searchProduct(
    String query,
  ) {
    if (query.isEmpty) {
      _filteredProducts = List.from(_allProducts);
    } else {
      _filteredProducts = _allProducts.where((p) {
        return p.name.toLowerCase().contains(
              query.toLowerCase(),
            );
      }).toList();
    }

    notifyListeners();
  }

  void addToCart(
    Product product, {
    ProductSize? selectedSize,
    int quantity = 1,
    List<Addon> selectedAddons = const [],
  }) {
    final finalSize = selectedSize ??
        (product.sizes != null && product.sizes!.isNotEmpty
            ? product.sizes!.first
            : ProductSize(
                label: "Regular",
                price: 0,
              ));

    final existingIndex = _cartItems.indexWhere(
      (item) {
        return item.product.id == product.id &&
            item.selectedSize.label == finalSize.label &&
            _sameAddons(
              item.selectedAddons,
              selectedAddons,
            );
      },
    );

    if (existingIndex != -1) {
      _cartItems[existingIndex].quantity += quantity;
    } else {
      _cartItems.add(
        CartItem(
          product: product,
          selectedSize: finalSize,
          quantity: quantity,
          selectedAddons: selectedAddons,
        ),
      );
    }

    saveCart();

    notifyListeners();
  }

  bool _sameAddons(
    List<Addon> a,
    List<Addon> b,
  ) {
    if (a.length != b.length) {
      return false;
    }

    final sortedA = a.map((e) => e.name).toList()..sort();

    final sortedB = b.map((e) => e.name).toList()..sort();

    for (int i = 0; i < sortedA.length; i++) {
      if (sortedA[i] != sortedB[i]) {
        return false;
      }
    }

    return true;
  }

  void updateQuantity(
    int index,
    int change,
  ) {
    if (index < 0 || index >= _cartItems.length) {
      return;
    }

    _cartItems[index].quantity += change;

    if (_cartItems[index].quantity <= 0) {
      _cartItems.removeAt(index);
    }

    saveCart();

    notifyListeners();
  }

  void removeFromCart(int index) {
    if (index < 0 || index >= _cartItems.length) {
      return;
    }

    _cartItems.removeAt(index);

    saveCart();

    notifyListeners();
  }

  Future<bool> checkout() async {
    try {
      final items = _cartItems.map((item) {
        return {
          "user_id": 1,
          "barang_id": item.product.id,
          "nama_barang": item.product.name,
          "image": item.product.imageUrl,
          "harga": item.product.harga,
          "quantity": item.quantity,
          "tanggal": DateTime.now().toString(),
          "status": "success",
        };
      }).toList();

      final success = await ApiService.postTransaksi(
        items,
        cartTotal,
      );

      if (success) {
        await loadHistory();

        clearCart();

        return true;
      }

      return false;
    } catch (e) {
      debugPrint(
        "CHECKOUT ERROR: $e",
      );

      return false;
    }
  }

  Future<void> loadHistory() async {
    try {
      final data = await ApiService.getHistory();

      _histories = data
          .map<HistoryItem>(
            (e) => HistoryItem.fromJson(e),
          )
          .toList();

      notifyListeners();
    } catch (e) {
      debugPrint(
        "LOAD HISTORY ERROR: $e",
      );
    }
  }

  Future<void> saveCart() async {
    final prefs = await SharedPreferences.getInstance();

    final data = _cartItems.map((item) {
      return {
        "product": item.product.toJson(),
        "selectedSize": {
          "label": item.selectedSize.label,
          "price": item.selectedSize.price,
        },
        "quantity": item.quantity,
        "selectedAddons": item.selectedAddons.map((e) => e.toJson()).toList(),
      };
    }).toList();

    await prefs.setString(
      "cart_items",
      jsonEncode(data),
    );
  }

  Future<void> loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final raw = prefs.getString("cart_items");

      if (raw == null) return;

      final List decoded = jsonDecode(raw);

      _cartItems.clear();

      for (var item in decoded) {
        _cartItems.add(
          CartItem(
            product: Product.fromJson(
              item["product"],
            ),
            selectedSize: ProductSize(
              label: item["selectedSize"]["label"],
              price: item["selectedSize"]["price"],
            ),
            quantity: item["quantity"],
            selectedAddons: (item["selectedAddons"] as List)
                .map(
                  (e) => Addon.fromJson(
                    e,
                  ),
                )
                .toList(),
          ),
        );
      }

      notifyListeners();
    } catch (e) {
      debugPrint(
        "LOAD CART ERROR: $e",
      );
    }
  }

  Future<void> clearCart() async {
    _cartItems.clear();

    final prefs = await SharedPreferences.getInstance();

    await prefs.remove("cart_items");

    notifyListeners();
  }

  void toggleAddon(
    int index,
    Addon addon,
  ) {}
}
