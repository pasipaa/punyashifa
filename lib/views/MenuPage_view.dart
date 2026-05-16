import 'package:flutter/material.dart';
import 'package:food_app/controllers/Product_controllers.dart';
import 'package:food_app/views/Cart_view.dart';
import 'package:food_app/views/CategoryPage_view.dart';
import 'package:provider/provider.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  // Hanya kategori yang ada di data backend, gambar dari produk nyata
  final List<Map<String, String>> categories = const [
    {
      'name': 'Indonesian Food',
      'label': 'Nusantara',
      'image': 'https://assets.unileversolutions.com/recipes-v2/258055.jpg',
      // gambar Nasi Goreng
    },
    {
      'name': 'Japanese Food',
      'label': 'Japanese',
      'image': 'https://images.unsplash.com/photo-1569050467447-ce54b3bbc37d?w=400',
      // gambar Ramen
    },
    {
      'name': 'Korean Food',
      'label': 'Korean',
      'image':
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTgCyyIqFMA5cMHZ-WbQaCUJu4Rpy5ffPXMPA&s',
      // gambar Kimchi
    },
    {
      'name': 'Western Food',
      'label': 'Western',
      'image':
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS3zMTDS9A6-HsL80yeSTjqOzslVO9ioyAxcA&s',
      // gambar Steak
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4EC),
      body: Stack(
        children: [
          Container(
            height: 160,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2D5016), Color(0xFF4A7C2F)],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: Colors.white24,
                                child: ClipOval(
                                  child: Image.network(
                                    'https://api.dicebear.com/7.x/adventurer/png?seed=Nanami',
                                    errorBuilder: (_, __, ___) => const Icon(
                                        Icons.person,
                                        color: Colors.white,
                                        size: 16),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Nanami Kento',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13)),
                                  Text('Your Address',
                                      style: TextStyle(
                                          color: Colors.white70, fontSize: 11)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Consumer<ProductController>(
                        builder: (context, controller, _) => GestureDetector(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const CartPage())),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.shopping_cart_outlined,
                                    color: Colors.white, size: 22),
                              ),
                              if (controller.cartCount > 0)
                                Positioned(
                                  top: -4,
                                  right: -4,
                                  child: Container(
                                    width: 16,
                                    height: 16,
                                    decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle),
                                    child: Center(
                                      child: Text('${controller.cartCount}',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold)),
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

                // Content
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF0F4EC),
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.06),
                                    blurRadius: 8)
                              ],
                            ),
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search menu...',
                                hintStyle:
                                    TextStyle(color: Colors.grey.shade400),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                suffixIcon: Icon(Icons.search,
                                    color: Colors.grey.shade400),
                              ),
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 20, 16, 12),
                          child: Text('Categories',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87)),
                        ),
                        Expanded(
                          child: GridView.builder(
                            padding:
                                const EdgeInsets.fromLTRB(16, 0, 16, 24),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 1.3,
                            ),
                            itemCount: categories.length,
                            itemBuilder: (context, index) {
                              final cat = categories[index];
                              return _buildCategoryCard(
                                cat['name']!,
                                cat['label']!,
                                cat['image']!,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
      String categoryName, String label, String imageUrl) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CategoryDetailPage(categoryName: categoryName),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 8,
                offset: const Offset(0, 3))
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Gambar dari produk di kategori itu
              Image.network(
                imageUrl,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFFE8F0E0),
                  child: const Center(
                      child: Icon(Icons.restaurant,
                          color: Color(0xFF2D5016), size: 40)),
                ),
              ),
              // Overlay gradient bawah
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.65),
                    ],
                  ),
                ),
              ),
              // Label
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(color: Colors.black45, blurRadius: 4)
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}