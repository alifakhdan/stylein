import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // PENTING: Ganti dengan IP laptopmu (hasil ipconfig) misal: 'http://192.168.1.15:8000/api'
  // Jika kamu pakai Emulator bawaan Android Studio, gunakan 'http://10.0.2.2:8000/api'
  static const String baseUrl = 'http://192.168.18.12:8000/api'; 

  Future<bool> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');
    
    try {
      final response = await http.post(
        url,
        body: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        print('Balasan dari Laravel: ${response.body}');
        final data = json.decode(response.body);
        
        // PERBAIKAN: Masuk ke 'authorisation' dulu, baru ambil 'token'
        final token = data['authorisation']['token']; 

        // Menyimpan token secara aman menggunakan SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);
        return true;
      }
      return false;
    } catch (e) {
      print('Error Login: $e');
      return false;
    }
  }

  // Fungsi untuk mengambil token yang tersimpan saat dibutuhkan
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  // Fungsi untuk menghapus token saat logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }
}