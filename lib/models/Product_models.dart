class Addon {
  final String name;
  final int price;

  Addon({
    required this.name,
    required this.price,
  });

  factory Addon.fromJson(dynamic json) {
    if (json is String) {
      return Addon(name: json, price: 2000);
    }
    return Addon(
      name: json['name'] ?? '',
      price: json['price'] ?? 2000,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "price": price,
    };
  }
}

class Product {
  final int id;
  final String name;
  final String category;
  final String description;
  final String imageUrl;
  final int harga;
  final int? diskon;
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
    this.diskon,
    this.isWishlisted = false,
  });

  // Harga setelah diskon (gunakan ini di UI)
  int get hargaDiskon {
    if (diskon == null || diskon! <= 0) return harga;
    return harga - (harga * diskon! ~/ 100);
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    final int baseHarga = json['harga'] ?? 0;

    final rawSizes = json['sizes'] as List<dynamic>? ?? [];
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
      diskon: json['diskon'] != null
          ? int.tryParse(json['diskon'].toString())
          : null,
      sizes: sizes,
      addons: rawAddons.map((e) => Addon.fromJson(e)).toList(),
      type: json['type'] ?? '',
      isWishlisted: json['isWishlisted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "nama_barang": name,
      "category": category,
      "deskripsi": description,
      "image": imageUrl,
      "harga": harga,
      "diskon": diskon,
      "type": type,
      "sizes": sizes.map((e) => {"label": e.label, "price": e.price}).toList(),
      "addons": addons.map((e) => e.toJson()).toList(),
      "isWishlisted": isWishlisted,
    };
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
