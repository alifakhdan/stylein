import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Memanggil data produk saat halaman pertama kali dibuka
    Future.microtask(() =>
        Provider.of<ProductProvider>(context, listen: false).loadProducts());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stylein Store', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.shopping_bag_outlined)),
        ],
      ),
      body: Consumer<ProductProvider>(
        builder: (context, provider, child) {
          // 1. Status LOADING
          if (provider.state == ProductState.loading) {
            return const Center(child: CircularProgressIndicator(color: Colors.black));
          }

          // 2. Status ERROR
          if (provider.state == ProductState.error) {
            return Center(
              child: Text('Gagal memuat data: ${provider.errorMessage}'),
            );
          }

          // 3. Status DATA BERHASIL DIMUAT
          return GridView.builder(
            padding: const EdgeInsets.all(15),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2 kolom seperti di web
              childAspectRatio: 0.7,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
            ),
            itemCount: provider.products.length,
            itemBuilder: (context, index) {
              final product = provider.products[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(15),
                        image: DecorationImage(
                          // Pastikan IP dan path storage benar
                          image: NetworkImage('http://192.168.18.12:8000/storage/${product.imageUrl}'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('Rp ${product.price}', style: TextStyle(color: Colors.grey[600])),
                ],
              );
            },
          );
        },
      ),
    );
  }
}