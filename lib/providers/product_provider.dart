import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';

// Enum untuk status UI (Memenuhi syarat Three-State UI di ketentuan tugas)
enum ProductState { loading, data, error }

class ProductProvider with ChangeNotifier {
  final ProductService _service = ProductService();
  
  List<Product> _products = [];
  ProductState _state = ProductState.loading;
  String _errorMessage = '';

  // Getter agar data bisa dibaca oleh UI
  List<Product> get products => _products;
  ProductState get state => _state;
  String get errorMessage => _errorMessage;

  // Fungsi untuk mengambil data dari API
  Future<void> loadProducts() async {
    _state = ProductState.loading;
    notifyListeners(); // Memberitahu UI untuk menampilkan loading

    try {
      _products = await _service.fetchProducts();
      _state = ProductState.data;
    } catch (e) {
      _state = ProductState.error;
      _errorMessage = e.toString();
    }
    
    notifyListeners(); // Memberitahu UI bahwa data sudah siap atau error
  }
}