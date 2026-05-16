import 'package:flutter/material.dart';
import 'package:food_app/models/CartItems_models.dart';
import 'package:food_app/models/History_models.dart';
import 'package:food_app/models/Product_models.dart';
import 'package:food_app/services/API_services.dart';

class ProductController extends ChangeNotifier {
  // ================= PRODUCT =================

  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];

  List<Product> get filteredProducts => _filteredProducts;

  // ================= CART =================

  final List<CartItem> _cartItems = [];

  List<CartItem> get cartItems => _cartItems;

  int get cartCount =>
      _cartItems.fold(0, (sum, item) => sum + item.quantity);

  int get cartTotal =>
      _cartItems.fold(0, (sum, item) => sum + item.totalPrice);

  // ================= HISTORY =================

  List<HistoryItem> _histories = [];

  List<HistoryItem> get histories => _histories;

  // ================= LOADING =================

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  // ================= LOAD PRODUCTS =================

  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      final raw = await ApiService.getProducts();

      _allProducts =
          raw.map((e) => Product.fromJson(e)).toList();

      _filteredProducts = List.from(_allProducts);
    } catch (e) {
      debugPrint("Load Product Error: $e");
      _allProducts = [];
      _filteredProducts = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  // ================= CATEGORY =================

  Future<void> loadByCategory(String category) async {
    _isLoading = true;
    notifyListeners();

    try {
      final raw = await ApiService.getProducts();

      _allProducts =
          raw.map((e) => Product.fromJson(e)).toList();

      _filteredProducts = _allProducts.where((p) {
        return p.category
            .toLowerCase()
            .contains(category.toLowerCase());
      }).toList();
    } catch (e) {
      debugPrint("Category Error: $e");
      _filteredProducts = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  // ================= SEARCH =================

  void searchProduct(String query) {
    if (query.isEmpty) {
      _filteredProducts = List.from(_allProducts);
    } else {
      _filteredProducts = _allProducts.where((p) {
        return p.name.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }

    notifyListeners();
  }

  // ================= ADD TO CART (FIXED) =================

  /// Menambahkan produk ke keranjang belanja.
  /// [product] wajib diletakkan di argumen pertama.
  /// [selectedSize], [quantity], dan [selectedAddons] bersifat opsional di dalam `{}`.
  void addToCart(
    Product product, {
    ProductSize? selectedSize,
    int quantity = 1,
    List<Addon> selectedAddons = const [],
  }) {
    // Menentukan size yang digunakan. Jika user tidak memilih, 
    // sistem mengambil size pertama dari list produk. Jika list kosong, dibuatkan default "Regular".
    final finalSize = selectedSize ?? 
        (product.sizes != null && product.sizes!.isNotEmpty 
            ? product.sizes!.first 
            : ProductSize(label: "Regular", price: 0));

    // Mencari apakah item dengan spesifikasi produk, size, dan addon yang sama sudah ada di keranjang
    final existingIndex = _cartItems.indexWhere(
      (item) =>
          item.product.id == product.id &&
          item.selectedSize.label == finalSize.label &&
          _sameAddons(item.selectedAddons, selectedAddons),
    );

    if (existingIndex != -1) {
      // Jika produk sudah ada, tinggal tambahkan quantity-nya
      _cartItems[existingIndex].quantity += quantity;
    } else {
      // Jika produk belum ada, buat item baru di dalam list keranjang
      _cartItems.add(
        CartItem(
          product: product,
          selectedSize: finalSize,
          quantity: quantity,
          selectedAddons: selectedAddons,
        ),
      );
    }

    notifyListeners();
  }

  bool _sameAddons(List<Addon> a, List<Addon> b) {
    if (a.length != b.length) return false;

    final sortedA = a.map((e) => e.name).toList()..sort();
    final sortedB = b.map((e) => e.name).toList()..sort();

    for (int i = 0; i < sortedA.length; i++) {
      if (sortedA[i] != sortedB[i]) return false;
    }

    return true;
  }

  // ================= QUANTITY =================

  void updateQuantity(int index, int change) {
    if (index < 0 || index >= _cartItems.length) return;

    _cartItems[index].quantity += change;

    if (_cartItems[index].quantity <= 0) {
      _cartItems.removeAt(index);
    }

    notifyListeners();
  }

  // ================= REMOVE =================

  void removeFromCart(int index) {
    if (index < 0 || index >= _cartItems.length) return;

    _cartItems.removeAt(index);
    notifyListeners();
  }

  // ================= CHECKOUT =================

  Future<bool> checkout() async {
    try {
      bool success = true;

      for (var item in _cartItems) {
        final result = await ApiService.postTransaksi([
          {
            "user_id": 1,
            "barang_id": item.product.id,
            "nama_barang": item.product.name,
            "image": item.product.imageUrl,
            "size": item.selectedSize.label,
            "addons": item.selectedAddons.map((e) => e.name).toList(),
            "quantity": item.quantity,
            "harga": item.totalPrice,
            "tanggal": DateTime.now().toIso8601String(),
            "status": "success",
          }
        ], item.totalPrice);

        if (!result) success = false;
      }

      if (success) {
        _cartItems.clear();
        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      debugPrint("CHECKOUT ERROR: $e");
      return false;
    }
  }

  // ================= WISHLIST =================

  Future<void> toggleWishlist(Product product) async {
    try {
      bool success;

      if (product.isWishlisted) {
        success = await ApiService.deleteWishlist(product.id);
      } else {
        success = await ApiService.addWishlist(product.id);
      }

      if (success) {
        product.isWishlisted = !product.isWishlisted;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("WISHLIST ERROR: $e");
    }
  }

  void toggleAddon(int index, Addon addon) {}
}