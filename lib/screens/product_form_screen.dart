import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProductFormScreen extends StatefulWidget {
  final Map? product; // Jika null = Tambah, Jika ada isi = Edit

  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Jika dalam mode EDIT, isi field dengan data lama
    if (widget.product != null) {
      _nameController.text = widget.product!['name'];
      _priceController.text = widget.product!['price'].toString();
      _descController.text = widget.product!['description'] ?? '';
    }
  }

  // ========================================================
  // 1. FUNGSI MENGAMBIL GAMBAR DARI GALERI (Yang tadi hilang)
  // ========================================================
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // ========================================================
  // 2. FUNGSI MENYIMPAN KE LARAVEL
  // ========================================================
  Future<void> _saveProduct() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Menyimpan data ke server...")),
    );

    try {
      // 1. Ambil Token dari penyimpanan HP
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('jwt_token'); // Pastikan 'token' adalah nama key yang kamu pakai saat login

      String url = widget.product == null 
          ? 'http://192.168.18.12:8000/api/products' 
          : 'http://192.168.18.12:8000/api/products/${widget.product!['id']}'; 
      
      var request = http.MultipartRequest('POST', Uri.parse(url));

      // 2. MASUKKAN HEADER TOKEN (INI KUNCINYA)
      request.headers['Accept'] = 'application/json';
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // 2. MASUKKAN DATA TEKS
      request.fields['name'] = _nameController.text;
      
      String generatedSlug = _nameController.text.toLowerCase().replaceAll(' ', '-');
      request.fields['slug'] = generatedSlug; 
      
      request.fields['price'] = _priceController.text;
      request.fields['description'] = _descController.text;

      if (widget.product != null) {
        request.fields['_method'] = 'PUT';
      }

      // 4. MASUKKAN FILE GAMBAR
      if (_imageFile != null) {
        var pic = await http.MultipartFile.fromPath('image', _imageFile!.path);
        request.files.add(pic);
      }

      // 5. KIRIM KE LARAVEL
      var response = await request.send();

      // 6. CEK HASILNYA
      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Berhasil menyimpan produk! ✅")),
        );
        Navigator.pop(context); 
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal menyimpan! Status: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan jaringan: $e")),
      );
    }
  }

  // ========================================================
  // 3. TAMPILAN LAYAR (UI)
  // ========================================================
  @override
  Widget build(BuildContext context) {
    bool isEdit = widget.product != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Product' : 'Add New Product', 
          style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // AREA UPLOAD GAMBAR
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: _imageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(_imageFile!, fit: BoxFit.cover))
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt, size: 50, color: Colors.grey),
                            Text("Click to upload product image", 
                              style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 25),

              // INPUT NAMA
              const Text("Product Name", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: "e.g. Kaos Polos Premium",
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? "Nama tidak boleh kosong" : null,
              ),
              const SizedBox(height: 20),

              // INPUT HARGA
              const Text("Price (Rp)", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: "e.g. 150000",
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? "Harga tidak boleh kosong" : null,
              ),
              const SizedBox(height: 20),

              // INPUT DESKRIPSI
              const Text("Description", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: "Tulis deskripsi produk di sini...",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30),

              // TOMBOL SIMPAN
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                        _saveProduct(); 
                    }
                },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                  child: const Text("SAVE PRODUCT", 
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    }
}