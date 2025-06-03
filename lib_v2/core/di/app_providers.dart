import 'package:assetsrfid/feature/auth/domain/usercase/verify_token_usercase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/single_child_widget.dart';
import 'package:http/http.dart' as http;

import '../../../feature/auth/data/datasource/auth_remote_datasource.dart';
import '../../../feature/auth/data/repository/auth_repository_impl.dart';
import '../../../feature/auth/domain/usercase/login_usercase.dart';
import '../../../feature/auth/domain/usercase/sign_up_usercase.dart';
import '../../../feature/auth/domain/usercase/verify_otp_usercase.dart';
import '../../../feature/auth/presentation/bloc/auth_bloc.dart';
import '../../../feature/auth/utils/token_storage.dart';

class AppProviders {
  static List<SingleChildWidget> providers() {
    final authDataSource = AuthRemoteDataSourceImpl(http.Client());
    final authRepository = AuthRepositoryImpl(authDataSource);
    final tokenStorage = TokenStorage();

    return [
      RepositoryProvider.value(value: authRepository),
      RepositoryProvider.value(value: tokenStorage),
      BlocProvider<AuthBloc>(
        create: (_) => AuthBloc(
          loginUseCase: LoginUseCase(authRepository),
          signUpUseCase: SignUpUseCase(authRepository),
          verifyOtpUseCase: VerifyOtpUseCase(authRepository),
          verifyTokenUseCase: VerifyTokenUseCase(authRepository),
          tokenStorage: tokenStorage,
        ),
      ),
    ];
  }
}
