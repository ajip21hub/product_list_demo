class Product {
  final int id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String thumbnail;
  final double rating;
  final int stock;
  final String brand;
  final String? image;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.thumbnail,
    required this.rating,
    required this.stock,
    required this.brand,
    this.image,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Unknown Product',
      price: (json['price'] ?? 0.0).toDouble(),
      description: json['description'] ?? 'No description available',
      category: json['category'] ?? 'Unknown',
      thumbnail: json['thumbnail'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      stock: json['stock'] ?? 0,
      brand: json['brand'] ?? 'Unknown Brand',
      image: json['image'], // Can be null
    );
  }
}
