import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/product_provider.dart';
import 'product_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // FIX 1: Menggunakan nama fungsi loadProducts() milikmu
      Provider.of<ProductProvider>(context, listen: false).loadProducts();
    });
  }

  Future<void> _deleteProduct(int productId) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Produk", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Apakah Anda yakin ingin menghapus produk ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("BATAL", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("HAPUS", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    ) ?? false;

    if (!confirm) return;

    // 1. AMBIL TOKEN DAN PASANG "CCTV"
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    // PERHATIKAN BARIS INI: Coba pastikan kunci yang kamu pakai di Login itu 'token', 'auth_token', atau 'api_token'?
    // Ubah tulisan 'token' di bawah ini jika di file login-mu namanya berbeda.
    String token = prefs.getString('jwt_token') ?? ''; 
    
    // Ini akan mencetak isi token di terminal VS Code biar kita tahu dia kosong atau tidak
    print("====== CEK TOKEN DELETE: $token ======");

    try {
      var response = await http.delete(
        Uri.parse('http://192.168.18.12:8000/api/products/$productId'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token', // Langsung paksa masuk tokennya
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Produk berhasil dihapus! 🗑️")),
        );
        if (mounted) {
          Provider.of<ProductProvider>(context, listen: false).loadProducts();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal menghapus! Status: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Kesalahan jaringan: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final products = productProvider.products;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Collections', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.grey[50],
      
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProductFormScreen()),
          ).then((value) {
            // FIX 3: Menggunakan nama fungsi loadProducts() milikmu
            Provider.of<ProductProvider>(context, listen: false).loadProducts();
          });
        },
        backgroundColor: Colors.black,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add New Product', style: TextStyle(color: Colors.white)),
      ),

      // Gunakan Three-State UI dari provider milikmu
      body: productProvider.state == ProductState.loading
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.black),
                SizedBox(height: 15),
                Text("Memuat data...", style: TextStyle(color: Colors.grey)),
              ],
            ),
          )
        : productProvider.state == ProductState.error
        ? Center(child: Text("Error: ${productProvider.errorMessage}", style: const TextStyle(color: Colors.red)))
        : products.isEmpty 
        ? const Center(child: Text("Produk masih kosong...", style: TextStyle(color: Colors.grey)))
        : Padding(
            padding: const EdgeInsets.all(10.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                
                // FIX 4: Menggunakan imageUrl sesuai dengan modelmu
                String imageLink = product.imageUrl; 
                if (imageLink.isNotEmpty && !imageLink.startsWith('http')) {
                  imageLink = 'http://192.168.18.12:8000/storage/$imageLink'; 
                }
                
                return Card(
                  color: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          color: Colors.grey[300],
                          child: Image.network(
                            imageLink,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => 
                              const Icon(Icons.image_not_supported, color: Colors.grey, size: 50),
                          ),
                        ),
                      ),
                      
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name, 
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Rp ${product.price}', 
                              style: TextStyle(color: Colors.grey[700], fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Row(
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductFormScreen(product: {
                                      'id': product.id,
                                      'name': product.name,
                                      'price': product.price,
                                      'description': product.description, // Sesuaikan dengan model
                                    }),
                                  ),
                                ).then((_) {
                                  // FIX 5: Menggunakan nama fungsi loadProducts() milikmu
                                  Provider.of<ProductProvider>(context, listen: false).loadProducts();
                                });
                              },
                              child: const Text('EDIT', style: TextStyle(color: Colors.blue, fontSize: 12)),
                            ),
                            TextButton(
                              onPressed: () {
                                _deleteProduct(product.id); 
                              },
                              child: const Text('DELETE', style: TextStyle(color: Colors.red, fontSize: 12)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),
                );
              },
            ),
          ),
    );
  }
}