class Product {
  final int id;
  final String name;
  final double price; // Pakai double karena di database tipenya decimal
  final String description;
  final String imageUrl;
  final int stock;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.imageUrl,
    required this.stock,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Tanpa Nama',
      // Mengubah format apapun dari API menjadi double
      price: json['price'] != null ? double.parse(json['price'].toString()) : 0.0,
      description: json['description'] ?? 'Tidak ada deskripsi.',
      imageUrl: json['image'] ?? '', // Sesuai dengan kolom di database
      stock: json['stock'] ?? 0,
    );
  }
}