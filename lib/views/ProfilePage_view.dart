import 'package:flutter/material.dart';
import 'package:food_app/services/API_services.dart';
import 'package:food_app/views/Cart_view.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? _user;
  List<dynamic> _history = [];
  List<dynamic> _wishlist = [];
  bool _loading = true;

  static const int _userId = 1;

  // Warna konsisten dengan Dashboard
  static const Color _primary = Color(0xFF2D5016);
  static const Color _primaryLight = Color(0xFF4A7C2F);
  static const Color _bg = Color(0xFFF4F7F0);
  static const Color _teal = Color(0xFF1F5B4D);

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    try {
      final user = await ApiService.getUser(_userId);
final history = await ApiService.getHistory();
final wishlist = await ApiService.getWishlist();
      setState(() {
        _user = user;
        _history = history;
        _wishlist = wishlist;
      });
    } catch (e) {
      setState(() {
        _user = {'name': 'Nanami Kento', 'address': 'Your Address'};
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _deleteWishlist(int id, int index) async {
    final ok = await ApiService.deleteWishlist(id);
    if (ok) {
      setState(() => _wishlist.removeAt(index));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Dihapus dari wishlist'),
          backgroundColor: _primary,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  String _formatPrice(dynamic price) {
    if (price == null) return 'Rp0';
    final p = int.tryParse(price.toString()) ?? 0;
    if (p == 0) return 'Rp0';
    final str = p.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
    }
    return 'Rp${buffer.toString()}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: _primary),
            )
          : Container(
              // Gradient background serasi dengan Dashboard
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white, Color(0xFFEAF5F1), Color(0xFF1F5B4D)],
                ),
              ),
              child: RefreshIndicator(
                onRefresh: _loadAll,
                color: _primary,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      _buildHeader(),
                      _buildActionButtons(context),
                      const SizedBox(height: 24),
                      _buildStatsRow(),
                      const SizedBox(height: 24),
                      _buildHistorySection(),
                      const SizedBox(height: 24),
                      _buildWishlistSection(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  // ───────────────────────── HEADER ─────────────────────────
 Widget _buildHeader() {
  final name = _user?['name'] ?? 'Guest';
  final address = _user?['address'] ?? '-';
  final avatar = _user?['avatar'] ?? '';

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_primary, _primaryLight],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, 5)),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
      child: Stack(
        children: [
          // Dekorasi lingkaran (serasi dengan banner dashboard)
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            right: 40,
            bottom: -30,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          Column(
            children: [
              // Avatar
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white38, width: 2),
                ),
                child: CircleAvatar(
                  radius: 44,
                  backgroundColor: Colors.white24,
                  child: ClipOval(
                    child: avatar.isNotEmpty
                        ? Image.network(
                            avatar,
                            width: 88,
                            height: 88,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _avatarPlaceholder(name),
                          )
                        : _avatarPlaceholder(name),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_on,
                      color: Colors.white60, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    address,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _avatarPlaceholder(String name) {
    return Container(
      width: 88,
      height: 88,
      color: const Color(0xFF3A6B1C),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'N',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 36,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ───────────────────────── ACTION BUTTONS ─────────────────────────
  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Edit Profile (coming soon)')),
                );
              },
              icon: const Icon(Icons.edit_outlined,
                  size: 16, color: _primary),
              label: const Text(
                'Edit Profile',
                style: TextStyle(
                    color: _primary, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: _primary, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartPage()),
              ),
              icon: const Icon(Icons.shopping_cart_outlined,
                  size: 16, color: Colors.white),
              label: const Text(
                'View Cart',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _teal,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22)),
                elevation: 4,
                shadowColor: _teal.withOpacity(0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── STATS ROW ─────────────────────────
  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            _statItem(_history.length.toString(), 'Order', Icons.receipt_long),
            _statDivider(),
            _statItem(_wishlist.length.toString(), 'Wishlist', Icons.favorite),
            _statDivider(),
            _statItem('4.9', 'Rating', Icons.star),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String value, String label, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: _primary, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: _primary),
          ),
          Text(label,
              style:
                  const TextStyle(fontSize: 11, color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _statDivider() {
    return Container(height: 40, width: 1, color: Colors.grey.shade200);
  }

  // ───────────────────────── HISTORY SECTION ─────────────────────────
  Widget _buildHistorySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header serasi dengan "People Top Picks" di dashboard
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Riwayat Pesanan',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
              Text('${_history.length} transaksi',
                  style: const TextStyle(
                      fontSize: 12, color: Colors.black45)),
            ],
          ),
          const SizedBox(height: 12),

          if (_history.isEmpty)
            _buildEmptyState(
              icon: Icons.receipt_long_outlined,
              message: 'Belum ada transaksi',
            )
          else
            ..._history.map((item) =>
                _buildHistoryCard(item as Map<String, dynamic>)),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> item) {
    final name = item['nama_barang'] ??
        item['name'] ??
        item['product_name'] ??
        'Produk';
    final price =
        _formatPrice(item['harga'] ?? item['price'] ?? item['total'] ?? 0);
    final date =
        item['tanggal'] ?? item['date'] ?? item['created_at'] ?? '';
    final image =
        item['gambar'] ?? item['image'] ?? item['image_url'] ?? '';

    String formattedDate = date;
    try {
      if (date.isNotEmpty) {
        final dt = DateTime.parse(date);
        formattedDate =
            '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
      }
    } catch (_) {}

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
              color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: image.isNotEmpty
                ? Image.network(
                    image,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _imagePlaceholder(),
                  )
                : _imagePlaceholder(),
          ),
          const SizedBox(width: 14),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  price,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _primary),
                ),
              ],
            ),
          ),
          // Date + status badge
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formattedDate,
                style:
                    TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Selesai',
                  style: TextStyle(
                      fontSize: 10,
                      color: Colors.green,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ───────────────────────── WISHLIST SECTION ─────────────────────────
  Widget _buildWishlistSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Wishlist',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
              Text('${_wishlist.length} item',
                  style: const TextStyle(
                      fontSize: 12, color: Colors.black45)),
            ],
          ),
          const SizedBox(height: 12),

          if (_wishlist.isEmpty)
            _buildEmptyState(
              icon: Icons.favorite_border,
              message: 'Wishlist masih kosong',
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.82,
              ),
              itemCount: _wishlist.length,
              itemBuilder: (context, index) {
                final item = _wishlist[index] as Map<String, dynamic>;
                return _buildWishlistCard(item, index);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildWishlistCard(Map<String, dynamic> item, int index) {
    final name = item['nama_barang'] ??
        item['name'] ??
        item['product_name'] ??
        'Produk';
    final price =
        _formatPrice(item['harga'] ?? item['price'] ?? 0);
    final image =
        item['gambar'] ?? item['image'] ?? item['image_url'] ?? '';
    final id = item['id'] ?? item['wishlist_id'] ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
              color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image area
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(18)),
                child: image.isNotEmpty
                    ? Image.network(
                        image,
                        height: 115,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _cardImagePlaceholder(),
                      )
                    : _cardImagePlaceholder(),
              ),

              // Delete button (serasi: pakai warna merah rounded)
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => _showDeleteConfirm(id, index),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.red.shade400,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.red.withOpacity(0.3),
                            blurRadius: 4)
                      ],
                    ),
                    child: const Icon(Icons.favorite,
                        size: 15, color: Colors.white),
                  ),
                ),
              ),

              // Add to cart button (serasi dengan arrow button di dashboard)
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: _teal,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                          color: _teal.withOpacity(0.35),
                          blurRadius: 4)
                    ],
                  ),
                  child: const Icon(Icons.add,
                      size: 16, color: Colors.white),
                ),
              ),
            ],
          ),

          // Name & price
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  price,
                  style: const TextStyle(
                      fontSize: 12,
                      color: _primary,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── HELPERS ─────────────────────────
  Widget _buildEmptyState(
      {required IconData icon, required String message}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
              color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.grey.shade300, size: 40),
          const SizedBox(height: 8),
          Text(message,
              style: TextStyle(
                  color: Colors.grey.shade400, fontSize: 13)),
        ],
      ),
    );
  }

  void _showDeleteConfirm(int id, int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Wishlist',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content:
            const Text('Yakin ingin menghapus item ini dari wishlist?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal',
                style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteWishlist(id, index);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))),
            child: const Text('Hapus',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F0E0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.fastfood, color: _primary, size: 24),
    );
  }

  Widget _cardImagePlaceholder() {
    return Container(
      height: 115,
      color: const Color(0xFFE8F0E0),
      child: const Center(
        child: Icon(Icons.fastfood, color: _primary, size: 32),
      ),
    );
  }
}