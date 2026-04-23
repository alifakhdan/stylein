import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/product_provider.dart';
import 'screens/login_screen.dart';
// Kita akan buat file Home nanti, sementara kita arahkan ke widget sederhana
// import 'screens/home_screen.dart'; 

void main() {
  runApp(
    // Mendaftarkan Provider agar bisa diakses di semua halaman
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Menghilangkan banner debug
      title: 'Stylein Mobile',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const LoginScreen(), // Ganti ke LoginScreen
    );
  }
}