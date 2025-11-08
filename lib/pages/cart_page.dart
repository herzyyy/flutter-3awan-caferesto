import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import '../providers/cart_provider.dart';
import '../providers/transaction_provider.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  String _selectedPayment = 'Tunai';
  final currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  void _checkIfCartEmpty(BuildContext context, CartProvider cartProvider) {
    if (cartProvider.items.isEmpty) {
      Navigator.pop(context);
    }
  }

  /// Generate order code berdasarkan timestamp
  String _generateOrderCode() {
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch;
    final random = Random().nextInt(9999).toString().padLeft(4, '0');
    final timestampStr = timestamp.toString();
    final last8Digits = timestampStr.length >= 8
        ? timestampStr.substring(timestampStr.length - 8)
        : timestampStr.padLeft(8, '0');
    return 'ORD-$last8Digits-$random';
  }

  /// Menampilkan popup setelah transaksi berhasil
  void _showSuccessDialog(
    BuildContext context,
    int totalItems,
    double totalPrice,
    String paymentMethod,
    String orderCode,
  ) {
    // Menampilkan dialog langsung tanpa await untuk menghindari delay
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.check_circle_rounded,
                color: Colors.green.shade700,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Pesanan Berhasil!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Code
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.lightBlue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.lightBlue.shade200,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.qr_code_2_rounded,
                      color: Colors.lightBlue.shade700,
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Kode Pesanan',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            orderCode,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.lightBlue.shade900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Detail Pesanan
              const Text(
                'Detail Pesanan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // Total Item
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.shopping_bag_outlined,
                        size: 18,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 8),
                      const Text('Total Item', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                  Text(
                    '$totalItems item',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Total Harga
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.attach_money_rounded,
                        size: 18,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 8),
                      const Text('Total Harga', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                  Text(
                    currencyFormatter.format(totalPrice),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.lightBlue.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Metode Pembayaran
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        paymentMethod == 'Tunai'
                            ? Icons.payments_outlined
                            : Icons.qr_code_2_rounded,
                        size: 18,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Metode Pembayaran',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: paymentMethod == 'Tunai'
                          ? Colors.green.shade50
                          : Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: paymentMethod == 'Tunai'
                            ? Colors.green.shade200
                            : Colors.purple.shade200,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      paymentMethod,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: paymentMethod == 'Tunai'
                            ? Colors.green.shade700
                            : Colors.purple.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Info
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green.shade200, width: 1),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 18,
                      color: Colors.green.shade700,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Terima kasih atas pesanan Anda!',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Tutup dialog
                Navigator.pop(context); // Kembali ke homepage
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue.shade700,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'OK',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final items = cartProvider.items;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          elevation: 4,
          automaticallyImplyLeading: true,
          centerTitle: true,
          backgroundColor: Colors.white,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
          ),
          title: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shopping_bag_rounded, color: Colors.white, size: 26),
              SizedBox(width: 8),
              Text(
                'Keranjang Belanja',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(18),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                'Pastikan pesananmu sudah sesuai 🍽️',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontStyle: FontStyle.italic,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ),
      ),
      body: items.isEmpty
          ? const Center(
              child: Text(
                'Belum ada pesanan 😕',
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
            )
          : Column(
              children: [
                // 🔹 Daftar produk di keranjang
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(14),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final menu = items.keys.elementAt(index);
                      final qty = items[menu]!;

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.07),
                              blurRadius: 8,
                              offset: const Offset(2, 3),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  menu.imageUrl,
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 70,
                                    height: 70,
                                    color: Colors.grey[300],
                                    child: const Icon(
                                      Icons.broken_image,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      menu.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Rp ${menu.price.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.blueGrey.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.remove_circle_outline,
                                        color: Colors.redAccent,
                                      ),
                                      onPressed: () {
                                        cartProvider.removeItem(menu);
                                        _checkIfCartEmpty(
                                          context,
                                          cartProvider,
                                        );
                                      },
                                    ),
                                    Text(
                                      qty.toString(),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.add_circle_outline,
                                        color: Colors.green,
                                      ),
                                      onPressed: () =>
                                          cartProvider.addItem(menu),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // 🔹 Metode Pembayaran
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Metode Pembayaran',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: RadioListTile<String>(
                                  title: const Row(
                                    children: [
                                      Icon(
                                        Icons.payments_outlined,
                                        color: Colors.green,
                                        size: 20,
                                      ),
                                      SizedBox(width: 6),
                                      Text('Tunai'),
                                    ],
                                  ),
                                  value: 'Tunai',
                                  groupValue: _selectedPayment,
                                  activeColor: Colors.lightBlue,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedPayment = value!;
                                    });
                                  },
                                ),
                              ),
                              Expanded(
                                child: RadioListTile<String>(
                                  title: const Row(
                                    children: [
                                      Icon(
                                        Icons.qr_code_2_rounded,
                                        color: Colors.deepPurple,
                                        size: 20,
                                      ),
                                      SizedBox(width: 6),
                                      Text('QRIS'),
                                    ],
                                  ),
                                  value: 'QRIS',
                                  groupValue: _selectedPayment,
                                  activeColor: Colors.lightBlue,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedPayment = value!;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 🔹 Total & tombol selesai
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
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
                        blurRadius: 8,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Belanja:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Rp ${cartProvider.totalPrice.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              final metode = _selectedPayment;
                              final orderCode = _generateOrderCode();
                              final transactionProvider =
                                  Provider.of<TransactionProvider>(
                                    context,
                                    listen: false,
                                  );

                              // Simpan data cart sebelum clear
                              final savedItems = Map<dynamic, int>.from(
                                cartProvider.items,
                              );
                              final savedTotalPrice = cartProvider.totalPrice;
                              final savedTotalItems = savedItems.values.fold(
                                0,
                                (sum, qty) => sum + qty,
                              );

                              // Menampilkan loading indicator
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );

                              try {
                                // Menyimpan transactions ke riwayat dan API
                                await transactionProvider.addTransactions(
                                  items: cartProvider.items,
                                  paymentMethod: metode,
                                );

                                // Menutup loading indicator
                                if (context.mounted) {
                                  Navigator.pop(context);
                                }

                                // Hanya clear cart jika semua transaksi berhasil disimpan
                                cartProvider.clearCart();

                                // Menampilkan popup sukses dengan detail pesanan
                                if (context.mounted) {
                                  _showSuccessDialog(
                                    context,
                                    savedTotalItems,
                                    savedTotalPrice,
                                    metode,
                                    orderCode,
                                  );
                                }
                              } catch (e) {
                                // Menutup loading indicator
                                if (context.mounted) {
                                  Navigator.pop(context);
                                }

                                // Menampilkan pesan error yang lebih informatif
                                if (context.mounted) {
                                  String errorMessage =
                                      'Gagal menyimpan transaksi';
                                  final errorStr = e.toString();

                                  if (errorStr.contains('Gagal terhubung') ||
                                      errorStr.contains('Failed to fetch') ||
                                      errorStr.contains('koneksi internet')) {
                                    errorMessage =
                                        'Tidak dapat terhubung ke server.\nPeriksa koneksi internet Anda dan coba lagi.';
                                  } else if (errorStr.contains('timeout') ||
                                      errorStr.contains('Timeout')) {
                                    errorMessage =
                                        'Server tidak merespons.\nSilakan coba lagi dalam beberapa saat.';
                                  } else if (errorStr.contains(
                                    'tidak ditemukan di database',
                                  )) {
                                    errorMessage =
                                        'Transaksi gagal tersimpan di database.\nSilakan coba lagi.';
                                  } else if (errorStr.contains('Status')) {
                                    errorMessage =
                                        'Server error.\nSilakan coba lagi atau hubungi administrator.';
                                  } else {
                                    // Ambil pesan error yang lebih user-friendly
                                    if (errorStr.contains('Exception:')) {
                                      final parts = errorStr.split(
                                        'Exception:',
                                      );
                                      if (parts.length > 1) {
                                        errorMessage = parts.last.trim();
                                      } else {
                                        errorMessage =
                                            'Terjadi kesalahan saat menyimpan transaksi.\nSilakan coba lagi.';
                                      }
                                    } else {
                                      errorMessage =
                                          'Terjadi kesalahan saat menyimpan transaksi.\nSilakan coba lagi.';
                                    }
                                  }

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        errorMessage,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      backgroundColor: Colors.red,
                                      duration: const Duration(seconds: 6),
                                      action: SnackBarAction(
                                        label: 'OK',
                                        textColor: Colors.white,
                                        onPressed: () {},
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              'Selesai',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1565C0),
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
    );
  }
}
