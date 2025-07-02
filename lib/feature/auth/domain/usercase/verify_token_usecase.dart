import 'package:assetsrfid/feature/auth/domain/repository/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:assetsrfid/core/error/failures.dart';

class VerifyTokenUseCase {
  final AuthRepository repository;
  VerifyTokenUseCase(this.repository);

  // این متد فعلا می‌تواند ساده باشد و در آینده کامل شود
  Future<Either<Failure, bool>> call({required String token}) async {
    // در دنیای واقعی اینجا توکن به سرور فرستاده و اعتبارسنجی می‌شود
    // فعلا شبیه‌سازی می‌کنیم که توکن معتبر است
    await Future.delayed(const Duration(seconds: 1));
    if (token.isNotEmpty) {
      return const Right(true);
    } else {
      return const Right(false);
    }
  }
}