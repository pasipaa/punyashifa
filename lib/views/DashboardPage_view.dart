import 'package:flutter/material.dart';
import 'package:food_app/constants/app_constanst.dart';
import 'package:food_app/services/Barang_services.dart';
import 'package:food_app/widgets/Carousel_widgets.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  BarangService service = BarangService();

  List barang = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    try {
      barang = await service.getBarang();

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      debugPrint("ERROR GET DATA: $e");

      setState(() {
        isLoading = false;
      });
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

                /// =========================
                /// SEARCH BAR
                /// =========================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),

                  child: Row(
                    children: [

                      Expanded(
                        child: Container(
                          height: 50,

                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                          ),

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

                          child: Row(
                            children: [

                              const Expanded(
                                child: TextField(
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Search",
                                  ),
                                ),
                              ),

                              Icon(
                                Icons.search,
                                color: Colors.grey.shade600,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 15),

                      /// =========================
                      /// CART BUTTON
                      /// =========================
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Cart clicked"),
                            ),
                          );
                        },

                        child: Container(
                          padding: const EdgeInsets.all(10),

                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,

                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 12,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),

                          child: const Icon(
                            Icons.shopping_cart_outlined,
                            size: 25,
                            color: Color(0xff1F5B4D),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                /// =========================
                /// BANNER
                /// =========================
                Container(
                  height: 180,

                  margin: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),

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

                      errorBuilder:
                          (context, error, stackTrace) {

                        return Container(
                          color: Colors.grey.shade300,

                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              size: 50,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                /// =========================
                /// CAROUSEL
                /// =========================
                CarouselWidget(
                  height: 190,

                  images: const [
                    "assets/promo1.png",
                    "assets/promo2.png",
                    "assets/promo3.png",
                  ],
                ),

                const SizedBox(height: 30),

                /// =========================
                /// TOP OFFER
                /// =========================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),

                  child: Container(
                    padding: const EdgeInsets.all(15),

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),

                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 12,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [

                        const Text(
                          "Top Offers for you",

                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 20),

                        Row(
                          children: [

                            Expanded(
                              child: offerItem(
                                "50%\nOFF",
                                "First Order",
                                Colors.yellow.shade200,
                              ),
                            ),

                            const SizedBox(width: 8),

                            Expanded(
                              child: offerItem(
                                "30%\nOFF",
                                "Weekend",
                                Colors.green.shade200,
                              ),
                            ),

                            const SizedBox(width: 8),

                            Expanded(
                              child: offerItem(
                                "10%\nOFF",
                                "Special",
                                Colors.red.shade200,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                /// =========================
                /// PEOPLE TOP PICKS
                /// =========================
                sectionTitle("People Top Picks"),

                const SizedBox(height: 20),

                isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )

                    : SizedBox(
                        height: 220,

                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,

                          itemCount: barang.length,

                          itemBuilder: (context, index) {

                            final item = barang[index];

                            return foodCard(
                              image:
                                  "${AppConstants.baseUrl}${item['image']}",

                              title:
                                  item['nama_barang'] ?? "",

                              price:
                                  "Rp ${item['harga'] ?? 0}",
                            );
                          },
                        ),
                      ),

                const SizedBox(height: 30),

                /// =========================
                /// LAST STOCK
                /// =========================
                sectionTitle("Last Stock"),

                const SizedBox(height: 20),

                isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )

                    : SizedBox(
                        height: 220,

                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,

                          itemCount: barang.length,

                          itemBuilder: (context, index) {

                            final item = barang[index];

                            return foodCard(
                              image:
                                  "${AppConstants.baseUrl}${item['image']}",

                              title:
                                  item['nama_barang'] ?? "",

                              price:
                                  "Rp ${item['harga'] ?? 0}",
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

  /// =========================
  /// SECTION TITLE
  /// =========================
  Widget sectionTitle(String title) {

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),

      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,

        children: [

          Text(
            title,

            style: const TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const Text(
            "See all",

            style: TextStyle(
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  /// =========================
  /// FOOD CARD
  /// =========================
  Widget foodCard({
    required String image,
    required String title,
    required String price,
  }) {

    return Container(
      width: 135,

      margin: const EdgeInsets.only(left: 20),

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
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          SizedBox(
            height: 110,

            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),

              child: Image.network(
                image,
                fit: BoxFit.cover,
                width: double.infinity,

                errorBuilder:
                    (context, error, stackTrace) {

                  return Container(
                    color: Colors.grey.shade300,

                    child: const Center(
                      child: Icon(
                        Icons.broken_image,
                        size: 40,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,

            children: [

              Expanded(
                child: Text(
                  title,

                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,

                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),

              GestureDetector(
                onTap: () {

                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    SnackBar(
                      content: Text("$title added"),
                    ),
                  );
                },

                child: Container(
                  padding: const EdgeInsets.all(4),

                  decoration: BoxDecoration(
                    color: const Color(0xff1F5B4D),
                    borderRadius:
                        BorderRadius.circular(8),
                  ),

                  child: const Icon(
                    Icons.add,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 5),

          Text(
            price,

            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  /// =========================
  /// OFFER ITEM
  /// =========================
  Widget offerItem(
    String title,
    String subtitle,
    Color color,
  ) {

    return Container(
      height: 105,

      padding: const EdgeInsets.all(10),

      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,

        children: [

          Align(
            alignment: Alignment.topRight,

            child: Container(
              padding: const EdgeInsets.all(4),

              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),

              child: const Icon(
                Icons.shopping_bag_outlined,
                size: 12,
                color: Color(0xff1F5B4D),
              ),
            ),
          ),

          Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              Text(
                title,

                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                subtitle,

                maxLines: 1,
                overflow: TextOverflow.ellipsis,

                style: const TextStyle(
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}