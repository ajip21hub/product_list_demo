import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:product_list_demo/data/models/product.dart';
import 'package:product_list_demo/presentation/providers/cart_provider_riverpod.dart';

/// Test perilaku keranjang. Pada Lab 1B (Pelatihan Lanjutan), CartNotifier
/// dimigrasikan ke Notifier + codegen; test ini harus tetap lulus.
Product _product(int id, double price) => Product(
  id: id,
  title: 'Produk $id',
  price: price,
  description: '-',
  category: 'test',
  thumbnail: '',
  rating: 4.5,
  stock: 10,
  brand: 'TokoKu',
);

void main() {
  late ProviderContainer container;

  setUp(() => container = ProviderContainer());
  tearDown(() => container.dispose());

  test('addItem menambah jumlah dan total', () {
    final cart = container.read(cartProvider.notifier);
    cart.addItem(_product(1, 10));
    cart.addItem(_product(1, 10));
    cart.addItem(_product(2, 5), quantity: 3);

    final state = container.read(cartProvider);
    expect(state.items, hasLength(2));
    expect(state.itemCount, 5);
    expect(state.totalAmount, 35);
  });

  test('removeSingleItem mengurangi satu, removeItem menghapus produk', () {
    final cart = container.read(cartProvider.notifier);
    final p = _product(1, 10);
    cart.addItem(p, quantity: 2);

    cart.removeSingleItem(p);
    expect(container.read(cartProvider).itemCount, 1);

    cart.removeItem(p);
    expect(container.read(cartProvider).isEmpty, isTrue);
  });

  test('clearCart mengosongkan keranjang', () {
    final cart = container.read(cartProvider.notifier);
    cart.addItem(_product(1, 10));
    cart.clearCart();
    expect(container.read(cartItemCountProvider), 0);
  });
}
