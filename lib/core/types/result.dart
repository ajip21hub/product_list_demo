/// Result sederhana: hasil sukses (data) atau gagal (error) tanpa melempar
/// exception ke UI. Pada Pelatihan Lanjutan pola ini diganti dengan
/// `sealed class Failure` + `AsyncValue` (Hari 1, Sesi 5).
library;

class Result<T> {
  final T? data;
  final Exception? error;
  final bool isSuccess;

  const Result._({this.data, this.error, required this.isSuccess});

  factory Result.success(T data) => Result._(data: data, isSuccess: true);
  factory Result.failure(Exception error) => Result._(error: error, isSuccess: false);

  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(Exception error) onFailure,
  }) {
    if (isSuccess) {
      return onSuccess(data!);
    } else {
      return onFailure(error!);
    }
  }

  bool get isFailure => !isSuccess;
}

/// Abstract repository interface for product operations
