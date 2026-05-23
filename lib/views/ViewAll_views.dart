import 'package:flutter/material.dart';
import 'package:food_app/services/base_url.dart';
import 'package:food_app/controllers/Product_controllers.dart';
import 'package:food_app/models/Product_models.dart';
import 'package:food_app/services/API_services.dart';
import 'package:food_app/views/ProductDetail_view.dart';
import 'package:provider/provider.dart';

class ViewAllPage extends StatelessWidget {
  final String title;
  final List items;

  const ViewAllPage({
    super.key,
    required this.title,
    required this.items,
  });

  String getImageUrl(String? image) {
    if (image == null || image.isEmpty) return "";
    if (image.startsWith('http://') || image.startsWith('https://'))
      return image;
    return "${BaseUrl}$image";
  }

  String formatPrice(dynamic price) {
    final value = int.tryParse(price.toString()) ?? 0;
    final str = value.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
    }
    return "Rp $buffer";
  }

  int discountedPrice(dynamic price, int discountPercent) {
    final value = int.tryParse(price.toString()) ?? 0;
    return value - (value * discountPercent ~/ 100);
  }

  Future<void> addWishlist(BuildContext context, Map item) async {
    try {
      await ApiService.addWishlist({
        "id": item['id'],
        "nama_barang": item['nama_barang'],
        "harga": item['harga'],
        "image": item['image'],
        "category": item['category'],
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("${item['nama_barang']} ditambahkan ke wishlist"),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: const Color(0xFF2D5016),
      ));
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F0),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFEAF5F1), Color(0xFF1F5B4D)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: Offset(0, 3)),
                          ],
                        ),
                        child: const Icon(Icons.arrow_back_ios_new,
                            size: 18, color: Color(0xFF1F5B4D)),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      title,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    Text(
                      '${items.length} items',
                      style:
                          TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final imageUrl = getImageUrl(item['image']);
                    final namaBarang = item['nama_barang'] ?? 'Tanpa Nama';
                    final hargaBarang = item['harga'] ?? 0;
                    final diskon =
                        int.tryParse(item['diskon']?.toString() ?? '0') ?? 0;
                    final hargaAsli = int.tryParse(hargaBarang.toString()) ?? 0;
                    final hargaDiskon = diskon > 0
                        ? discountedPrice(hargaAsli, diskon)
                        : hargaAsli;

                    final productModel = Product(
                      id: item['id'],
                      name: namaBarang,
                      imageUrl: imageUrl,
                      category: item['category'] ?? '',
                      sizes: [],
                      description: item['deskripsi'] ?? '',
                      harga: hargaDiskon,
                      addons: [],
                      type: item['type'] ?? 'food',
                    );

                    return Consumer<ProductController>(
                      builder: (context, controller, _) {
                        return _foodCard(
                          context: context,
                          item: item,
                          image: imageUrl,
                          title: namaBarang,
                          hargaAsli: hargaAsli,
                          hargaDiskon: hargaDiskon,
                          diskon: diskon,
                          onTapCard: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    ProductDetailPage(product: productModel)),
                          ),
                          onAddToCart: () {
                            controller.addToCart(
                              productModel,
                              selectedSize: ProductSize(
                                  label: 'Regular', price: hargaDiskon),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  "$namaBarang berhasil ditambahkan ke keranjang!"),
                              duration: const Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ));
                          },
                          onAddWishlist: () => addWishlist(context, item),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _foodCard({
    required BuildContext context,
    required Map item,
    required String image,
    required String title,
    required int hargaAsli,
    required int hargaDiskon,
    required int diskon,
    required VoidCallback onTapCard,
    required VoidCallback onAddToCart,
    required VoidCallback onAddWishlist,
  }) {
    return GestureDetector(
      onTap: onTapCard,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  SizedBox(
                    height: 130,
                    width: double.infinity,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: image.isNotEmpty
                          ? Image.network(
                              image,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.fastfood,
                                    color: Color(0xFF2D5016)),
                              ),
                            )
                          : Container(
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.fastfood,
                                  color: Color(0xFF2D5016)),
                            ),
                    ),
                  ),
                  if (diskon > 0)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8)),
                        child: Text(
                          '-$diskon%',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: PopupMenuButton(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                          value: "wishlist",
                          child: Row(
                            children: [
                              Icon(Icons.favorite_border, color: Colors.red),
                              SizedBox(width: 10),
                              Text("Tambah Wishlist"),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == "wishlist") onAddWishlist();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.more_vert, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 2),
              Text(
                item['category'] ?? '',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (diskon > 0)
                          Text(
                            formatPrice(hargaAsli),
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 10,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        Text(
                          formatPrice(hargaDiskon),
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF1F5B4D),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: onAddToCart,
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: const BoxDecoration(
                          color: Color(0xFF1F5B4D), shape: BoxShape.circle),
                      child:
                          const Icon(Icons.add, color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
