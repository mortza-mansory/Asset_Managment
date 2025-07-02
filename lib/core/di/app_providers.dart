import 'package:assetsrfid/feature/auth/domain/usercase/request_reset_code_usecase.dart';
import 'package:assetsrfid/feature/auth/domain/usercase/signup_usecase.dart';
import 'package:assetsrfid/feature/auth/domain/usercase/verify_login_otp_usecase.dart';
import 'package:assetsrfid/feature/auth/domain/usercase/verify_reset_code_usecase.dart';
import 'package:assetsrfid/feature/auth/domain/usercase/verify_signup_otp_usecase.dart';
import 'package:assetsrfid/feature/auth/domain/usercase/verify_token_usecase.dart';
import 'package:assetsrfid/feature/goverment_management/data/datasource/company_remote_datasource.dart';
import 'package:assetsrfid/feature/goverment_management/presentation/bloc/company_bloc.dart';
import 'package:assetsrfid/feature/localization/data/local_data/localization_local_datasource.dart';
import 'package:assetsrfid/feature/localization/data/repository/localization_repository_impl.dart';
import 'package:assetsrfid/feature/localization/domain/repository/localization_repository.dart';
import 'package:assetsrfid/feature/localization/domain/usecase/get_locale_usecase.dart';
import 'package:assetsrfid/feature/localization/domain/usecase/set_locale_usecase.dart';
import 'package:assetsrfid/feature/localization/presentation/bloc/localization_bloc.dart';
import 'package:assetsrfid/feature/localization/presentation/bloc/localization_event.dart';
import 'package:assetsrfid/feature/subscription/data/datasource/subscription_remote_datasource.dart';
import 'package:assetsrfid/feature/subscription/presentation/bloc/subscription_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/single_child_widget.dart';
import 'package:http/http.dart' as http;
import '../../../feature/auth/data/datasource/auth_remote_datasource.dart';
import '../../../feature/auth/data/repository/auth_repository_impl.dart';
import '../../../feature/auth/domain/repository/auth_repository.dart';
import '../../../feature/auth/domain/usercase/login_usercase.dart';
import '../../../feature/auth/presentation/bloc/auth_bloc.dart';
import '../../../feature/auth/utils/token_storage.dart';

class AppProviders {
  static List<SingleChildWidget> providers() {

    final httpClient = http.Client();
    final tokenStorage = TokenStorage();

    final AuthRemoteDataSource authDataSource = AuthRemoteDataSourceImpl(client: httpClient);
    final AuthRepository authRepository = AuthRepositoryImpl(remoteDataSource: authDataSource);
    final subscriptionDataSource = SubscriptionRemoteDataSourceImpl(client: httpClient, tokenStorage: tokenStorage); // TokenStorage به اینجا پاس داده می‌شود
    final companyDataSource = CompanyRemoteDataSourceImpl(client: httpClient, tokenStorage: tokenStorage);

    final signupUseCase = SignupUseCase(authRepository);
    final verifySignUpOtpUseCase = VerifySignUpOtpUseCase(authRepository);
    final loginUseCase = LoginUseCase(authRepository);
    final verifyLoginOtpUseCase = VerifyLoginOtpUseCase(authRepository);
    final verifyTokenUseCase = VerifyTokenUseCase(authRepository);
    final localizationDataSource = LocalizationLocalDataSourceImpl();
    final localizationRepository = LocalizationRepositoryImpl(localDataSource: localizationDataSource);
    final getLocaleUsecase = GetLocaleUsecase(localizationRepository);
    final setLocaleUsecase = SetLocaleUsecase(localizationRepository);
    final requestResetCodeUseCase = RequestResetCodeUseCase(authRepository);
    final verifyResetCodeUseCase = VerifyResetCodeUseCase(authRepository);

    return [
      RepositoryProvider<AuthRepository>.value(value: authRepository),
      RepositoryProvider<TokenStorage>.value(value: tokenStorage),

      BlocProvider<AuthBloc>(
        create: (_) => AuthBloc(
          loginUseCase: loginUseCase,
          signupUseCase: signupUseCase,
          verifyLoginOtpUseCase: verifyLoginOtpUseCase,
          verifyTokenUseCase: verifyTokenUseCase,
          requestResetCodeUseCase: requestResetCodeUseCase,
          verifyResetCodeUseCase: verifyResetCodeUseCase,
          tokenStorage: tokenStorage
        ),
      ),
      RepositoryProvider<LocalizationRepository>.value(
          value: localizationRepository),
      BlocProvider<LocalizationBloc>(
        create: (_) => LocalizationBloc(
          getLocaleUsecase: getLocaleUsecase,
          setLocaleUsecase: setLocaleUsecase,
        )..add(GetInitialLocale()),
      ),
      BlocProvider<CompanyBloc>(
        create: (_) => CompanyBloc(dataSource: companyDataSource),
      ),
      BlocProvider<SubscriptionBloc>(
        create: (_) => SubscriptionBloc(dataSource: subscriptionDataSource),
      ),
    ];
  }
}
