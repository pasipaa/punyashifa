class Addon {
  final String name;
  final int price;

  Addon({
    required this.name,
    required this.price,
  });

  factory Addon.fromJson(dynamic json) {
    // kalau backend cuma kirim string
    if (json is String) {
      return Addon(
        name: json,
        price: 2000,
      );
    }

    // kalau backend kirim object
    return Addon(
      name: json['name'] ?? '',
      price: json['price'] ?? 2000,
    );
  }
}

class Product {
  final int id;
  final String name;
  final String category;
  final String description;
  final String imageUrl;
  final int harga;
  final List<ProductSize> sizes;
  final List<Addon> addons;
  final String type;

  bool isWishlisted;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.imageUrl,
    required this.harga,
    required this.sizes,
    required this.addons,
    required this.type,
    this.isWishlisted = false,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final rawSizes = json['sizes'] as List<dynamic>? ?? [];
    final int baseHarga = json['harga'] ?? 0;

    final sizes = rawSizes.asMap().entries.map((entry) {
      return ProductSize(
        label: entry.value.toString(),
        price: baseHarga + (entry.key * 2000),
      );
    }).toList();

    final rawAddons = json['addons'] as List<dynamic>? ?? [];

    return Product(
      id: json['id'] ?? 0,
      name: json['nama_barang'] ?? '',
      category: json['category'] ?? '',
      description: json['deskripsi'] ?? '',
      imageUrl: json['image'] ?? '',
      harga: baseHarga,
      sizes: sizes,
      addons: rawAddons.map((e) => Addon.fromJson(e)).toList(),
      type: json['type'] ?? '',
      isWishlisted: json['isWishlisted'] ?? false,
    );
  }
}

class ProductSize {
  final String label;
  final int price;

  ProductSize({
    required this.label,
    required this.price,
  });
}