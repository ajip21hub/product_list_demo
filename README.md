# Product List Demo

Aplikasi Flutter sederhana untuk menampilkan daftar produk dari Fake Store API dengan tampilan yang modern dan responsif.

## 📱 Screenshots

Aplikasi ini menampilkan:
- Grid layout produk dengan gambar
- Filter berdasarkan kategori
- Rating dan harga produk
- Loading state dan error handling
- Pull-to-refresh functionality

## 🚀 Cara Menjalankan

### Prerequisites
- Flutter SDK (versi 3.0 atau lebih tinggi)
- Android Studio / VS Code dengan Flutter extension

### Step-by-step:

1. **Clone repository**
   ```bash
   git clone <repository-url>
   cd product_list_demo
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run aplikasi**
   ```bash
   # Untuk development
   flutter run
   
   # Atau spesifik ke device
   flutter run -d chrome  # Web
   flutter run -d android # Android
   flutter run -d ios     # iOS
   ```

## 📁 Struktur Project

```
lib/
├── main.dart                    # Entry point aplikasi
├── models/
│   └── product.dart            # Model data produk
├── services/
│   └── api_service.dart        # API service untuk fetch data
└── screens/
    └── product_list_screen.dart # UI tampilan daftar produk
```

## 🔧 Dependencies

- **http**: Package untuk HTTP requests ke API
- **flutter**: Core framework Flutter

## 📡 API yang Digunakan

Aplikasi menggunakan [Fake Store API](https://fakestoreapi.com/) sebagai data source:

- `GET https://fakestoreapi.com/products` - Mendapatkan semua produk
- `GET https://fakestoreapi.com/products/categories` - Mendapatkan kategori
- `GET https://fakestoreapi.com/products/category/{category}` - Filter by kategori

## 💻 Kode Penggunaan

### 1. Model Product

```dart
class Product {
  final int id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String image;
  final Rating rating;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['title'],
      price: json['price'].toDouble(),
      description: json['description'],
      category: json['category'],
      image: json['image'],
      rating: Rating.fromJson(json['rating']),
    );
  }
}
```

### 2. API Service

```dart
class ApiService {
  static const String baseUrl = 'https://fakestoreapi.com';

  Future<List<Product>> getProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/products'));
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }
}
```

### 3. Widget Product Card

```dart
class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Column(
        children: [
          // Product image
          Expanded(
            child: Image.network(
              product.image,
              fit: BoxFit.contain,
            ),
          ),
          // Product info
          Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              children: [
                Text(product.title, maxLines: 2),
                Text('\$${product.price}'),
                Row(
                  children: [
                    Icon(Icons.star, size: 16),
                    Text(product.rating.rate.toString()),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

### 4. Menggunakan di StatefulWidget

```dart
class ProductListScreen extends StatefulWidget {
  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final ApiService _apiService = ApiService();
  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    
    try {
      final products = await _apiService.getProducts();
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    
    if (_error != null) {
      return Center(child: Text('Error: $_error'));
    }

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        return ProductCard(product: _products[index]);
      },
    );
  }
}
```

## 🎨 Fitur UI

- **Grid Layout**: 2 columns responsive grid
- **Category Filter**: Horizontal scrollable filter chips
- **Product Cards**: Image, title, price, rating
- **Loading States**: CircularProgressIndicator dengan pesan
- **Error Handling**: User-friendly error display dengan retry button
- **Pull to Refresh**: Refresh data dengan swipe down
- **Image Error Handling**: Placeholder jika gagal load image

## 🛠️ Tambahan Fitur

### Search Functionality (Contoh)

```dart
// Tambahkan field search di State
TextEditingController _searchController = TextEditingController();
List<Product> _filteredProducts = [];

// Filter logic
void _filterProducts(String query) {
  setState(() {
    _filteredProducts = _products.where((product) {
      return product.title.toLowerCase().contains(query.toLowerCase());
    }).toList();
  });
}
```

### Sort Functionality (Contoh)

```dart
enum SortOption { priceAsc, priceDesc, rating }

void _sortProducts(SortOption option) {
  setState(() {
    switch (option) {
      case SortOption.priceAsc:
        _products.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortOption.priceDesc:
        _products.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortOption.rating:
        _products.sort((a, b) => b.rating.rate.compareTo(a.rating.rate));
        break;
    }
  });
}
```

## 🐛 Troubleshooting

### Common Issues:

1. **CORS Error**: 
   - Gunakan emulator/device, tidak bisa langsung di web browser
   - Atau gunakan CORS proxy

2. **Image Loading Error**:
   - Pastikan koneksi internet stabil
   - Cek apakah URL image valid

3. **Slow Loading**:
   - Tambahkan loading indicator
   - Implement pagination untuk data yang besar

## 📄 License

MIT License