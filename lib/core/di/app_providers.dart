import 'package:assetsrfid/core/services/permission_service.dart';
import 'package:assetsrfid/core/services/session_service.dart';
import 'package:assetsrfid/feature/goverment_management/data/repository/company_settings_repository_impl.dart';
import 'package:assetsrfid/feature/goverment_management/domain/repository/company_settings_repository.dart';
import 'package:assetsrfid/feature/goverment_management/domain/usecase/get_company_overview_usecase.dart';
import 'package:assetsrfid/feature/goverment_management/presentation/bloc/company_settings/company_settings_bloc.dart';
import 'package:assetsrfid/feature/profile/persantation/bloc/profile_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:provider/single_child_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:assetsrfid/feature/auth/data/datasource/auth_remote_datasource.dart';
import 'package:assetsrfid/feature/auth/data/repository/auth_repository_impl.dart';
import 'package:assetsrfid/feature/auth/domain/repository/auth_repository.dart';
import 'package:assetsrfid/feature/auth/domain/usercase/login_usercase.dart';
import 'package:assetsrfid/feature/auth/domain/usercase/request_reset_code_usecase.dart';
import 'package:assetsrfid/feature/auth/domain/usercase/signup_usecase.dart';
import 'package:assetsrfid/feature/auth/domain/usercase/verify_login_otp_usecase.dart';
import 'package:assetsrfid/feature/auth/domain/usercase/verify_reset_code_usecase.dart';
import 'package:assetsrfid/feature/auth/domain/usercase/verify_signup_otp_usecase.dart';
import 'package:assetsrfid/feature/auth/domain/usercase/verify_token_usecase.dart';
import 'package:assetsrfid/feature/auth/presentation/bloc/auth_bloc.dart';
import 'package:assetsrfid/feature/auth/utils/token_storage.dart';

import 'package:assetsrfid/feature/goverment_management/data/datasource/company_remote_datasource.dart';
import 'package:assetsrfid/feature/goverment_management/presentation/bloc/company/company_bloc.dart';
import 'package:assetsrfid/feature/goverment_management/domain/usecase/get_company_overview_usecase.dart';
import 'package:assetsrfid/feature/goverment_management/presentation/bloc/company/company_bloc.dart';
import 'package:assetsrfid/feature/goverment_management/presentation/bloc/company_settings/company_settings_bloc.dart';

import 'package:assetsrfid/feature/profile/data/datasource/profile_remote_datasource.dart';
import 'package:assetsrfid/feature/profile/data/repository/profile_repository_impl.dart';
import 'package:assetsrfid/feature/profile/domain/repository/profile_repository.dart';
import 'package:assetsrfid/feature/profile/domain/usecase/get_user_profile_usecase.dart';

import 'package:assetsrfid/feature/localization/data/local_data/localization_local_datasource.dart';
import 'package:assetsrfid/feature/localization/data/repository/localization_repository_impl.dart';
import 'package:assetsrfid/feature/localization/domain/repository/localization_repository.dart';
import 'package:assetsrfid/feature/localization/domain/usecase/get_locale_usecase.dart';
import 'package:assetsrfid/feature/localization/domain/usecase/set_locale_usecase.dart';
import 'package:assetsrfid/feature/localization/presentation/bloc/localization_bloc.dart';
import 'package:assetsrfid/feature/localization/presentation/bloc/localization_event.dart';
import 'package:assetsrfid/feature/navbar/presentation/bloc/nav_bar_bloc.dart';
import 'package:assetsrfid/feature/subscription/data/datasource/subscription_remote_datasource.dart';
import 'package:assetsrfid/feature/subscription/presentation/bloc/subscription_bloc.dart';
import 'package:assetsrfid/feature/theme/bloc/theme_bloc.dart';


final getIt = GetIt.instance;

void setupDependencies() {
  // SERVICES
  getIt.registerLazySingleton<SessionService>(() => SessionService());
  getIt.registerLazySingleton<PermissionService>(() => PermissionService());
  getIt.registerLazySingleton<TokenStorage>(() => TokenStorage());
  getIt.registerLazySingleton<http.Client>(() => http.Client());

  // DATA SOURCES
  getIt.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(client: getIt<http.Client>()));
  getIt.registerLazySingleton<CompanyRemoteDataSource>(() => CompanyRemoteDataSourceImpl(client: getIt<http.Client>(), tokenStorage: getIt<TokenStorage>()));
  getIt.registerLazySingleton<SubscriptionRemoteDataSource>(() => SubscriptionRemoteDataSourceImpl(client: getIt<http.Client>(), tokenStorage: getIt<TokenStorage>()));
  getIt.registerLazySingleton<LocalizationLocalDataSource>(() => LocalizationLocalDataSourceImpl());
  getIt.registerLazySingleton<ProfileRemoteDataSource>(() => ProfileRemoteDataSourceImpl(client: getIt<http.Client>()));

  // REPOSITORIES
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(remoteDataSource: getIt<AuthRemoteDataSource>()));
  getIt.registerLazySingleton<LocalizationRepository>(() => LocalizationRepositoryImpl(localDataSource: getIt<LocalizationLocalDataSource>()));
  getIt.registerLazySingleton<ProfileRepository>(() => ProfileRepositoryImpl(remoteDataSource: getIt<ProfileRemoteDataSource>()));
  getIt.registerLazySingleton<CompanySettingsRepository>(() => CompanySettingsRepositoryImpl(remoteDataSource: getIt<CompanyRemoteDataSource>()));

  // USE CASES
  getIt.registerLazySingleton(() => SignupUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => VerifySignUpOtpUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => LoginUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => VerifyLoginOtpUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => VerifyTokenUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => RequestResetCodeUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => VerifyResetCodeUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => GetLocaleUsecase(getIt<LocalizationRepository>()));
  getIt.registerLazySingleton(() => SetLocaleUsecase(getIt<LocalizationRepository>()));
  getIt.registerLazySingleton(() => GetUserProfileUseCase(getIt<ProfileRepository>()));
  getIt.registerLazySingleton(() => GetCompanyOverviewUseCase(getIt<CompanySettingsRepository>()));

}



class AppProviders {
  static List<SingleChildWidget> providers() {
    return [
      BlocProvider<AuthBloc>(
        create: (_) => AuthBloc(
          tokenStorage: getIt<TokenStorage>(),
          loginUseCase: getIt<LoginUseCase>(),
          signupUseCase: getIt<SignupUseCase>(),
          verifyLoginOtpUseCase: getIt<VerifyLoginOtpUseCase>(),
          verifyTokenUseCase: getIt<VerifyTokenUseCase>(),
          requestResetCodeUseCase: getIt<RequestResetCodeUseCase>(),
          verifyResetCodeUseCase: getIt<VerifyResetCodeUseCase>(),
        ),
      ),
      BlocProvider<LocalizationBloc>(
        create: (_) => LocalizationBloc(
          getLocaleUsecase: getIt<GetLocaleUsecase>(),
          setLocaleUsecase: getIt<SetLocaleUsecase>(),
        )..add(GetInitialLocale()),
      ),
      BlocProvider<CompanyBloc>(
        create: (_) => CompanyBloc(
          dataSource: getIt<CompanyRemoteDataSource>(),
          sessionService: getIt<SessionService>(),
          permissionService: getIt<PermissionService>(),
        ),
      ),
      BlocProvider<SubscriptionBloc>(
        create: (_) => SubscriptionBloc(dataSource: getIt<SubscriptionRemoteDataSource>()),
      ),
      BlocProvider<ThemeBloc>(create: (_) => ThemeBloc()),
      BlocProvider<NavBarBloc>(create: (_) => NavBarBloc()),
      BlocProvider<ProfileBloc>(
        create: (_) => ProfileBloc(getUserProfileUseCase: getIt<GetUserProfileUseCase>()),
      ),
      BlocProvider<CompanySettingsBloc>(
        create: (_) => CompanySettingsBloc(getCompanyOverviewUseCase: getIt<GetCompanyOverviewUseCase>()),
      ),
    ];
  }
}