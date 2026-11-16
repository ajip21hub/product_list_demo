import 'package:flutter_test/flutter_test.dart';
import 'package:product_list_demo/core/types/result.dart';

void main() {
  test('success membawa data dan fold memanggil onSuccess', () {
    final result = Result.success(42);
    expect(result.isSuccess, isTrue);
    expect(result.isFailure, isFalse);
    expect(
      result.fold(onSuccess: (d) => 'data $d', onFailure: (e) => 'error'),
      'data 42',
    );
  });

  test('failure membawa error dan fold memanggil onFailure', () {
    final result = Result<int>.failure(Exception('gagal'));
    expect(result.isFailure, isTrue);
    expect(
      result.fold(onSuccess: (d) => 'data', onFailure: (e) => '$e'),
      'Exception: gagal',
    );
  });
}
