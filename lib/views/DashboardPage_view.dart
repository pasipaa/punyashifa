import 'package:flutter/material.dart';
import 'package:food_app/constants/app_constanst.dart';
import 'package:food_app/models/Product_models.dart';
import 'package:food_app/services/Barang_services.dart';
import 'package:food_app/views/ProductDetail_view.dart';
import 'package:food_app/widgets/Carousel_widgets.dart';
import 'package:food_app/controllers/Product_controllers.dart';
import 'package:food_app/views/Cart_view.dart'; // Aktifkan jika file detail page-mu di sini
import 'package:provider/provider.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final BarangService service = BarangService();
  List barang = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    try {
      final data = await service.getBarang();
      setState(() {
        barang = data;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("ERROR GET DATA: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  /// Memastikan URL gambar aman, baik dari link internet langsung (https://)
  /// maupun dari storage backend lokal yang membutuhkan baseUrl
  String getImageUrl(String? image) {
    if (image == null || image.isEmpty) return "";
    if (image.startsWith('http://') || image.startsWith('https://')) {
      return image;
    }
    return "${AppConstants.baseUrl}$image";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Color(0xffEAF5F1),
              Color(0xff1F5B4D),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),

                /// ==========================================
                /// SEARCH BAR & BADGE CART (REALTIME)
                /// ==========================================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 50,
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 12,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: const Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Search",
                                  ),
                                ),
                              ),
                              Icon(Icons.search),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      
                      // Bagian Keranjang yang Sudah Diperbaiki & Terintegrasi ke CartPage
                      Consumer<ProductController>(
                        builder: (context, controller, _) => GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CartPage(),
                              ),
                            );
                          },
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.shopping_cart_outlined,
                                  color: Color(0xff1F5B4D),
                                ),
                              ),
                              if (controller.cartCount > 0)
                                Positioned(
                                  top: -2,
                                  right: -2,
                                  child: Container(
                                    width: 18,
                                    height: 18,
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${controller.cartCount}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                /// ==========================================
                /// BANNER
                /// ==========================================
                Container(
                  height: 180,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 12,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: Image.asset(
                      "assets/banner2.png",
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.image_not_supported),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                /// ==========================================
                /// CAROUSEL PROMO
                /// ==========================================
                CarouselWidget(
                  height: 190,
                  images: const [
                    "assets/promo1.png",
                    "assets/promo2.png",
                    "assets/promo3.png",
                  ],
                ),

                const SizedBox(height: 30),

                /// ==========================================
                /// SECTION TITLE
                /// ==========================================
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Menu Makanan",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                /// ==========================================
                /// LIST MENU (HORIZONTAL LIST)
                /// ==========================================
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SizedBox(
                        height: 255,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: barang.length,
                          itemBuilder: (context, index) {
                            final item = barang[index];
                            final imageUrl = getImageUrl(item['image']);
                            final namaBarang = item['nama_barang'] ?? 'Tanpa Nama';
                            final hargaBarang = item['harga'] ?? 0;

                            // Memetakan struktur map API ke Object Model Product kamu
                            final productModel = Product(
                              id: item['id'],
                              name: namaBarang,
                              imageUrl: imageUrl,
                              category: item['category'] ?? '',
                              sizes: [],
                              description: item['deskripsi'] ?? 'Tidak ada deskripsi',
                              harga: hargaBarang,
                              addons: [],
                              type: item['type'] ?? 'food',
                            );

                            return Consumer<ProductController>(
                              builder: (context, controller, _) {
                                return _foodCard(
                                  image: imageUrl,
                                  title: namaBarang,
                                  price: "Rp $hargaBarang",
                                  onTapCard: () {
                                    // Navigasi ke halaman detail dengan membawa object model data API
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ProductDetailPage(product: productModel),
                                      ),
                                    );
                                  },
                                  onAddToCart: () {
                                    controller.addToCart(
                                      productModel,
                                      selectedSize: ProductSize(label: 'Regular', price: hargaBarang),
                                    );

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("$namaBarang berhasil ditambahkan ke keranjang!"),
                                        duration: const Duration(seconds: 1),
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ),

                const SizedBox(height: 120),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ==========================================
  /// WIDGET COMPONENT: FOOD CARD
  /// ==========================================
  Widget _foodCard({
    required String image,
    required String title,
    required String price,
    required VoidCallback onTapCard,
    required VoidCallback onAddToCart,
  }) {
    return GestureDetector(
      onTap: onTapCard,
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(left: 16, bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 110,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: image.isNotEmpty
                    ? Image.network(
                        image,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return Container(
                            color: Colors.grey.shade300,
                            child: const Icon(Icons.broken_image),
                          );
                        },
                      )
                    : Container(
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.image),
                      ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    price,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onAddToCart,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xff1F5B4D),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}