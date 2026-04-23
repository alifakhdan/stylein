import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';
import 'auth_service.dart';

class ProductService {
  Future<List<Product>> fetchProducts() async {
    final authService = AuthService();
    // Mengambil token JWT yang sudah disimpan saat login
    final token = await authService.getToken();

    if (token == null) {
      throw Exception('Token tidak ditemukan. Silakan login kembali.');
    }

    final url = Uri.parse('${AuthService.baseUrl}/products');
    
    // Mengirim token JWT ke dalam Header API sesuai ketentuan tugas
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      
      // Jika hasil API Laravelmu di dalam objek "data", kita ambil isinya
      // Jika langsung berupa list, pakai data saja
      final List productsData = data['data'] ?? data; 
      
      // Menerjemahkan list JSON menjadi List<Product> menggunakan model yang tadi dibuat
      return productsData.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Gagal mengambil data produk. Status: ${response.statusCode}');
    }
  }
}