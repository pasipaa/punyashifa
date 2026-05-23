import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:food_app/services/API_services.dart';
import 'package:food_app/views/Cart_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      debugPrint(e.toString());
      setState(() {
        _user = {'name': 'Nanami Kento', 'address': 'Your Address'};
        _history = [];
        _wishlist = [];
      });
    } finally {
      setState(() => _loading = false);
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

  Future<void> _deleteHistoryItem(int index) async {
    try {
      final updated = List<dynamic>.from(_history);
      updated.removeAt(index);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('history', jsonEncode(updated));

      setState(() => _history = updated);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Riwayat dihapus'),
          backgroundColor: _primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
    } catch (e) {
      debugPrint('DELETE HISTORY ERROR: $e');
    }
  }

  Future<void> _deleteAllHistory() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Semua Riwayat',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Yakin ingin menghapus semua riwayat pesanan?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Hapus Semua', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ApiService.clearHistory();
      setState(() => _history = []);
    }
  }

  Future<void> _deleteWishlistItem(int index) async {
    try {
      final item = _wishlist[index];
      final id = item['id'];

      if (id != null) {
        await ApiService.removeWishlist(int.tryParse(id.toString()) ?? -1);
      } else {
        await ApiService.removeWishlistByIndex(index);
      }

      setState(() => _wishlist.removeAt(index));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Dihapus dari wishlist'),
          backgroundColor: _teal,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
    } catch (e) {
      debugPrint('DELETE WISHLIST ERROR: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _primary))
          : Container(
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

  Widget _buildHeader() {
    final name = _user?['name'] ?? 'Nanami Kento';
    final address = _user?['address'] ?? '-';

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_primary, _primaryLight],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
              ],
            ),
            child: CircleAvatar(
              radius: 44,
              backgroundColor: const Color(0xFFE8F0E0),
              child: ClipOval(
                child: Image.asset(
                  'assets/nanami.jpeg',
                  width: 88,
                  height: 88,
                  fit: BoxFit.cover,
                ),
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
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_on, color: Colors.white60, size: 14),
              const SizedBox(width: 4),
              Text(address, style: const TextStyle(color: Colors.white70, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _showEditProfileDialog,
              icon: const Icon(Icons.edit_outlined, size: 16, color: _primary),
              label: const Text('Edit Profile',
                  style: TextStyle(color: _primary, fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: _primary, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
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
              icon: const Icon(Icons.shopping_cart_outlined, size: 16, color: Colors.white),
              label: const Text('View Cart',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _teal,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
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
          Text(value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _primary)),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _statDivider() =>
      Container(height: 40, width: 1, color: Colors.grey.shade200);

  Widget _buildHistorySection() {
    final preview = _history.take(3).toList();
    final hasMore = _history.length > 3;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Riwayat Pesanan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              if (_history.isNotEmpty)
                TextButton.icon(
                  onPressed: _deleteAllHistory,
                  icon: const Icon(Icons.delete_sweep_outlined, size: 16, color: Colors.red),
                  label: const Text('Hapus Semua',
                      style: TextStyle(color: Colors.red, fontSize: 12)),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (_history.isEmpty)
            _buildEmptyState(
              icon: Icons.receipt_long_outlined,
              message: 'Belum ada transaksi',
            )
          else ...[
            ...preview.asMap().entries.map(
                (e) => _buildHistoryCard(e.value as Map<String, dynamic>, e.key)),
            if (hasMore)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _showAllHistorySheet,
                    icon: const Icon(Icons.history, size: 16, color: _teal),
                    label: Text(
                      'Lihat semua (${_history.length - 3} lainnya)',
                      style: const TextStyle(color: _teal, fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: _teal),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> item, int index) {
    final name = item['nama_barang'] ?? item['name'] ?? 'Produk';
    final price = _formatPrice(item['harga'] ?? item['price'] ?? 0);
    final image = item['image'] ?? item['gambar'] ?? '';
    final tanggal = item['tanggal'] ?? '';
    final qty = item['quantity'] ?? 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: image.toString().isNotEmpty
                ? Image.network(
                    image,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _imageFallback(),
                  )
                : _imageFallback(),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 3),
                Text(price,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600, color: _primary)),
                const SizedBox(height: 2),
                Text('x$qty  •  $tanggal',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
              ],
            ),
          ),
          PopupMenuButton<String>(
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            icon: const Icon(Icons.more_vert, color: Colors.grey),
            onSelected: (value) async {
              if (value == 'delete') await _deleteHistoryItem(index);
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.red, size: 18),
                    SizedBox(width: 8),
                    Text('Hapus', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAllHistorySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (ctx, scrollController) {
          return StatefulBuilder(
            builder: (ctx, setSheetState) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Semua Riwayat (${_history.length})',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          TextButton.icon(
                            onPressed: () async {
                              Navigator.pop(ctx);
                              await _deleteAllHistory();
                            },
                            icon: const Icon(Icons.delete_sweep_outlined,
                                size: 16, color: Colors.red),
                            label: const Text('Hapus Semua',
                                style: TextStyle(color: Colors.red, fontSize: 12)),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: _history.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.receipt_long_outlined,
                                      color: Colors.grey.shade300, size: 48),
                                  const SizedBox(height: 8),
                                  Text('Belum ada transaksi',
                                      style: TextStyle(color: Colors.grey.shade400)),
                                ],
                              ),
                            )
                          : ListView.builder(
                              controller: scrollController,
                              padding: const EdgeInsets.all(16),
                              itemCount: _history.length,
                              itemBuilder: (_, i) {
                                final item = _history[i] as Map<String, dynamic>;
                                final name = item['nama_barang'] ?? 'Produk';
                                final price = _formatPrice(item['harga'] ?? 0);
                                final image = item['image'] ?? '';
                                final tanggal = item['tanggal'] ?? '';
                                final qty = item['quantity'] ?? 1;

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: const [
                                      BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 6,
                                          offset: Offset(0, 3)),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: image.toString().isNotEmpty
                                            ? Image.network(
                                                image,
                                                width: 55,
                                                height: 55,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) =>
                                                    _imageFallback(size: 55),
                                              )
                                            : _imageFallback(size: 55),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(name,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 14)),
                                            const SizedBox(height: 3),
                                            Text(price,
                                                style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                    color: _primary)),
                                            Text('x$qty  •  $tanggal',
                                                style: TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.grey.shade500)),
                                          ],
                                        ),
                                      ),
                                      PopupMenuButton<String>(
                                        color: Colors.white,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(14)),
                                        icon: const Icon(Icons.more_vert,
                                            color: Colors.grey),
                                        onSelected: (value) async {
                                          if (value == 'delete') {
                                            await _deleteHistoryItem(i);
                                            setSheetState(() {});
                                          }
                                        },
                                        itemBuilder: (_) => [
                                          const PopupMenuItem(
                                            value: 'delete',
                                            child: Row(
                                              children: [
                                                Icon(Icons.delete_outline,
                                                    color: Colors.red, size: 18),
                                                SizedBox(width: 8),
                                                Text('Hapus',
                                                    style: TextStyle(
                                                        color: Colors.red)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildWishlistSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Wishlist',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemCount: _wishlist.length,
              itemBuilder: (context, index) {
                return _buildWishlistCard(
                    _wishlist[index] as Map<String, dynamic>, index);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildWishlistCard(Map<String, dynamic> item, int index) {
    final name = item['nama_barang'] ?? item['name'] ?? 'Produk';
    final price = _formatPrice(item['harga'] ?? item['price'] ?? 0);
    final image = item['image'] ?? item['gambar'] ?? '';
    final category = item['category'] ?? '';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
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
                  height: 120,
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: image.toString().isNotEmpty
                        ? Image.network(
                            image,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _imageFallback(size: 120, radius: 18),
                          )
                        : _imageFallback(size: 120, radius: 18),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: PopupMenuButton<String>(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    onSelected: (value) async {
                      if (value == 'delete') await _deleteWishlistItem(index);
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, color: Colors.red, size: 18),
                            SizedBox(width: 8),
                            Text('Hapus', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.more_vert, size: 18),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 3),
            Text(category,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
            const Spacer(),
            Text(price,
                style: const TextStyle(
                    color: _primary, fontWeight: FontWeight.w600, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _imageFallback({double size = 60, double radius = 12}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F0E0),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: const Icon(Icons.fastfood, color: _primary),
    );
  }

  Widget _buildEmptyState({required IconData icon, required String message}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.grey.shade300, size: 40),
          const SizedBox(height: 8),
          Text(message,
              style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
        ],
      ),
    );
  }

  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: _user?['name'] ?? '');
    final addressController = TextEditingController(text: _user?['address'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Edit Profile',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Nama',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: addressController,
              decoration: InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _user = {
                  ...?_user,
                  'name': nameController.text,
                  'address': addressController.text,
                };
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text('Profile berhasil diperbarui'),
                backgroundColor: _primary,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}