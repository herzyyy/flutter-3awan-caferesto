import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/menu_model.dart';
import '../providers/cart_provider.dart';
import '../providers/menu_provider.dart';
import 'cart_page.dart';
import 'history_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Memuat menu di background tanpa blocking UI
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final menuProvider = Provider.of<MenuProvider>(context, listen: false);
      // Selalu refresh di background, tidak perlu blocking UI
      menuProvider.loadMenusInBackground();
    });
  }

  final currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  Widget _buildBannerImage(List<Menu> data) {
    try {
      return Image.asset(
        'assets/images/banner.jpg',
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Error loading banner asset: $error');
          // Fallback ke gambar dari API jika asset tidak ada
          if (data.isNotEmpty) {
            return Image.network(
              data[0].imageUrl,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.grey[300],
                child: const Center(
                  child: Icon(
                    Icons.restaurant_menu,
                    color: Colors.grey,
                    size: 48,
                  ),
                ),
              ),
            );
          }
          return Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.grey[300],
            child: const Center(
              child: Icon(Icons.restaurant_menu, color: Colors.grey, size: 48),
            ),
          );
        },
      );
    } catch (e) {
      debugPrint('Exception loading banner: $e');
      // Fallback ke gambar dari API jika asset tidak ada
      if (data.isNotEmpty) {
        return Image.network(
          data[0].imageUrl,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.grey[300],
            child: const Center(
              child: Icon(Icons.restaurant_menu, color: Colors.grey, size: 48),
            ),
          ),
        );
      }
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.grey[300],
        child: const Center(
          child: Icon(Icons.restaurant_menu, color: Colors.grey, size: 48),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final menuProvider = Provider.of<MenuProvider>(context);
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(isTablet ? 110 : 95),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.local_cafe_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '3awan Café & Resto',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: isTablet ? 24 : 20,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Selamat menikmati suasana nyaman & rasa nikmat',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: isTablet ? 13 : 11,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Tombol riwayat di pojok kanan
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const HistoryPage()),
                      );
                    },
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.history_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    tooltip: 'Riwayat Pesanan',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: menuProvider.menus.isEmpty && menuProvider.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.lightBlue),
            )
          : menuProvider.menus.isEmpty && menuProvider.error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Terjadi kesalahan: ${menuProvider.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => menuProvider.loadMenus(),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            )
          : menuProvider.menus.isEmpty
          ? const Center(child: Text('Menu belum tersedia.'))
          : _buildMenuList(menuProvider.menus, cart, size, isTablet),
    );
  }

  Widget _buildMenuList(
    List<Menu> data,
    CartProvider cart,
    Size size,
    bool isTablet,
  ) {
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: size.height * 0.09),
          child: Column(
            children: [
              // Banner gambar makanan
              Container(
                margin: const EdgeInsets.all(14),
                height: isTablet ? 200 : 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: _buildBannerImage(data),
                ),
              ),
              // GridView menu - Data berasal dari table menus via API
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isTablet ? 3 : 2,
                    childAspectRatio: isTablet ? 0.8 : 0.74,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                  ),
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    // Menu berasal dari table menus via MenuProvider
                    final menu = data[index];
                    final qty = cart.items[menu] ?? 0;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(2, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(18),
                              topRight: Radius.circular(18),
                            ),
                            child: Image.network(
                              menu.imageUrl,
                              height: isTablet ? 180 : 120,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    height: isTablet ? 180 : 120,
                                    color: Colors.grey[300],
                                    child: const Center(
                                      child: Icon(
                                        Icons.broken_image,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        menu.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: isTablet ? 18 : 15.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        currencyFormatter.format(menu.price),
                                        style: TextStyle(
                                          color: Colors.blueAccent[700],
                                          fontWeight: FontWeight.bold,
                                          fontSize: isTablet ? 16 : 13.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  // 🔹 Tombol + - di posisi tengah card
                                  Align(
                                    alignment: Alignment.center,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                        vertical: 2,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.remove,
                                              color: Colors.redAccent,
                                            ),
                                            iconSize: isTablet ? 24 : 22,
                                            constraints: const BoxConstraints(),
                                            padding: const EdgeInsets.all(6),
                                            onPressed: qty > 0
                                                ? () => cart.removeItem(menu)
                                                : null,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                            ),
                                            child: Text(
                                              qty.toString(),
                                              style: TextStyle(
                                                fontSize: isTablet ? 18 : 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.add,
                                              color: Colors.green,
                                            ),
                                            iconSize: isTablet ? 24 : 22,
                                            constraints: const BoxConstraints(),
                                            padding: const EdgeInsets.all(6),
                                            onPressed: () => cart.addItem(menu),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // 🔹 Tombol keranjang di bawah
        if (cart.items.isNotEmpty)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: size.height * 0.085,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(0, -2),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: InkWell(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartPage()),
                  );
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.shopping_cart_outlined,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'Keranjang (${cart.items.length} Item)',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: isTablet ? 18 : 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        currencyFormatter.format(cart.totalPrice),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: isTablet ? 18 : 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
