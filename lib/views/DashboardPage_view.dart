import 'package:flutter/material.dart';
import 'package:food_app/services/base_url.dart';
import 'package:food_app/controllers/Product_controllers.dart';
import 'package:food_app/models/Product_models.dart';
import 'package:food_app/services/Barang_services.dart';
import 'package:food_app/services/API_services.dart';
import 'package:food_app/views/Cart_view.dart';
import 'package:food_app/views/ProductDetail_view.dart';
import 'package:food_app/views/ViewAll_views.dart';
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

  final List<Map<String, dynamic>> _offers = [
    {'percent': '50%', 'label': 'On First Order', 'color': Color(0xFFFFD966)},
    {'percent': '30%', 'label': 'This Week', 'color': Color(0xFF90EE90)},
    {'percent': '10%', 'label': 'French Menu', 'color': Color(0xFFFFB3B3)},
  ];

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
      setState(() => isLoading = false);
    }
  }

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

  Future<void> addWishlist(Map item) async {
    try {
      await ApiService.addWishlist({
        "id": item['id'],
        "nama_barang": item['nama_barang'],
        "harga": item['harga'],
        "image": item['image'],
        "category": item['category'],
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("${item['nama_barang']} ditambahkan ke wishlist"),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: const Color(0xFF2D5016),
        ));
      }
    } catch (e) {
      debugPrint(e.toString());
    }
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
            colors: [Colors.white, Color(0xffEAF5F1), Color(0xff1F5B4D)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildSearchBar(),
                const SizedBox(height: 25),
                _buildHollaBanner(),
                const SizedBox(height: 20),
                _buildPromoCarousel(),
                const SizedBox(height: 24),
                _buildTopOffers(),
                const SizedBox(height: 28),
                _buildSectionHeader(
                  'People Top Picks',
                  onSeeAll: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ViewAllPage(
                        title: 'People Top Picks',
                        items: barang,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildHorizontalFoodList(barang),
                const SizedBox(height: 28),
                _buildSectionHeader(
                  'Last Stock',
                  onSeeAll: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ViewAllPage(
                        title: 'Last Stock',
                        items: barang.reversed.toList(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildHorizontalFoodList(barang.reversed.toList()),
                const SizedBox(height: 120),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 5)),
                ],
              ),
              child: const Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Search menu...",
                      ),
                    ),
                  ),
                  Icon(Icons.search),
                ],
              ),
            ),
          ),
          const SizedBox(width: 14),
          Consumer<ProductController>(
            builder: (context, controller, _) {
              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartPage()),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
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
                              "${controller.cartCount}",
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
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHollaBanner() {
    return Container(
      height: 180,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: const LinearGradient(
          colors: [Color(0xFF2D5016), Color(0xFF1F5B4D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
              color: Colors.black26, blurRadius: 12, offset: Offset(0, 5)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              "assets/banner2.png",
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.15),
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoCarousel() {
    return _FullCarousel(
      images: const [
        "assets/promo1.png",
        "assets/promo2.png",
        "assets/promo3.png",
      ],
    );
  }

  Widget _buildTopOffers() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top Offers for you',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: _offers.asMap().entries.map((entry) {
              final offer = entry.value;
              final isLast = entry.key == _offers.length - 1;
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: isLast ? 0 : 10),
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
                  decoration: BoxDecoration(
                    color: offer['color'] as Color,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: (offer['color'] as Color).withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Get',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.black54)),
                      Text(offer['percent'] as String,
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Colors.black87)),
                      const Text('OFF',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87)),
                      const SizedBox(height: 4),
                      Text(offer['label'] as String,
                          style: const TextStyle(
                              fontSize: 10, color: Colors.black54)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, {required VoidCallback onSeeAll}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          GestureDetector(
            onTap: onSeeAll,
            child: const Row(
              children: [
                Text('See all',
                    style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF1F5B4D),
                        fontWeight: FontWeight.w600)),
                SizedBox(width: 2),
                Icon(Icons.chevron_right, size: 18, color: Color(0xFF1F5B4D)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalFoodList(List items) {
    if (isLoading) {
      return const SizedBox(
        height: 240,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return SizedBox(
      height: 240,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 16, right: 8),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final imageUrl = getImageUrl(item['image']);
          final namaBarang = item['nama_barang'] ?? 'Tanpa Nama';
          final hargaBarang = item['harga'] ?? 0;
          final diskon = int.tryParse(item['diskon']?.toString() ?? '0') ?? 0;
          final hargaAsli = int.tryParse(hargaBarang.toString()) ?? 0;
          final hargaDiskon =
              diskon > 0 ? discountedPrice(hargaAsli, diskon) : hargaAsli;

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
                item: item,
                image: imageUrl,
                title: namaBarang,
                hargaAsli: hargaAsli,
                hargaDiskon: hargaDiskon,
                diskon: diskon,
                onTapCard: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ProductDetailPage(product: productModel)),
                ),
                onAddToCart: () {
                  controller.addToCart(
                    productModel,
                    selectedSize:
                        ProductSize(label: 'Regular', price: hargaDiskon),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content:
                        Text("$namaBarang berhasil ditambahkan ke keranjang!"),
                    duration: const Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ));
                },
                onAddWishlist: () async => await addWishlist(item),
              );
            },
          );
        },
      ),
    );
  }

  Widget _foodCard({
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
        width: 155,
        margin: const EdgeInsets.only(right: 12, bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 110,
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
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '-$diskon%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
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
                    itemBuilder: (context) => [
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
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 2),
            Text(
              item['category'] ?? '',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
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
                          color: Color(0xff1F5B4D),
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
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xff1F5B4D),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 16),
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

class _FullCarousel extends StatefulWidget {
  final List<String> images;

  const _FullCarousel({required this.images});

  @override
  State<_FullCarousel> createState() => _FullCarouselState();
}

class _FullCarouselState extends State<_FullCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.images.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    widget.images[index],
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(
                        child: Icon(Icons.image, size: 40, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.images.length, (i) {
            final active = i == _currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: active ? 20 : 7,
              height: 7,
              decoration: BoxDecoration(
                color: active ? const Color(0xFF1F5B4D) : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }
}
