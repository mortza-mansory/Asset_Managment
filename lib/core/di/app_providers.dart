import 'package:assetsrfid/core/services/cache_service.dart';
import 'package:assetsrfid/core/services/permission_service.dart';
import 'package:assetsrfid/core/services/session_service.dart';
import 'package:assetsrfid/feature/asset_managment/domain/usecase/get_asset_by_id_usecase.dart';
import 'package:assetsrfid/feature/asset_managment/domain/usecase/get_asset_by_rfid_usecase.dart';
import 'package:assetsrfid/feature/asset_managment/domain/usecase/get_asset_history_usecase.dart';
import 'package:assetsrfid/feature/asset_managment/domain/usecase/update_asset_usecase.dart';
import 'package:assetsrfid/feature/asset_managment/presentation/bloc/asset_detail/asset_detail_bloc.dart';
import 'package:assetsrfid/feature/asset_managment/presentation/bloc/asset_detail_edit/asset_detail_edit_bloc.dart';
import 'package:assetsrfid/feature/asset_managment/presentation/bloc/asset_history/asset_history_bloc.dart';
import 'package:assetsrfid/feature/asset_managment/presentation/bloc/assets_management/asset_managment_bloc.dart';
import 'package:assetsrfid/feature/asset_managment/presentation/bloc/bulk_upload/bulk_upload_bloc.dart';
import 'package:assetsrfid/feature/assets_explore/domain/usecase/create_asset_category_usecase.dart';
import 'package:assetsrfid/feature/assets_explore/domain/usecase/delete_asset_category_usecase.dart';
import 'package:assetsrfid/feature/assets_explore/domain/usecase/update_asset_category_link_usecase.dart';
import 'package:assetsrfid/feature/assets_explore/domain/usecase/update_asset_category_usecase.dart';
import 'package:assetsrfid/feature/assets_explore/presentation/bloc/asset_category_management/asset_category_management_bloc.dart';
import 'package:assetsrfid/feature/assets_loan_management/data/datasource/loan_remote_datasource.dart';
import 'package:assetsrfid/feature/assets_loan_management/data/repository/loan_repository_impl.dart';
import 'package:assetsrfid/feature/assets_loan_management/domain/repository/loan_repository.dart';
import 'package:assetsrfid/feature/assets_loan_management/domain/usecase/create_loan_usecase.dart';
import 'package:assetsrfid/feature/assets_loan_management/domain/usecase/get_loan_by_id_usecase.dart';
import 'package:assetsrfid/feature/assets_loan_management/domain/usecase/get_loaned_out_assets_usecase.dart';
import 'package:assetsrfid/feature/assets_loan_management/domain/usecase/get_my_loans_usecase.dart';
import 'package:assetsrfid/feature/assets_loan_management/domain/usecase/get_user_profile_by_id_usecase.dart';
import 'package:assetsrfid/feature/assets_loan_management/domain/usecase/return_asset_usecase.dart';
import 'package:assetsrfid/feature/assets_loan_management/presentation/bloc/asset_loan_dashboard/asset_loan_dashboard_bloc.dart';
import 'package:assetsrfid/feature/assets_loan_management/presentation/bloc/create_loan/create_loan_bloc.dart';
import 'package:assetsrfid/feature/goverment_management/data/repository/company_members_repository_impl.dart';
import 'package:assetsrfid/feature/goverment_management/data/repository/company_settings_repository_impl.dart';
import 'package:assetsrfid/feature/goverment_management/data/repository/invitation_repository_impl.dart';
import 'package:assetsrfid/feature/goverment_management/domain/repository/company_members_repository.dart';
import 'package:assetsrfid/feature/goverment_management/domain/repository/company_settings_repository.dart';
import 'package:assetsrfid/feature/goverment_management/domain/repository/invitation_repository.dart';
import 'package:assetsrfid/feature/goverment_management/domain/usecase/fetch_my_invitations_usecase.dart';
import 'package:assetsrfid/feature/goverment_management/domain/usecase/get_company_overview_usecase.dart';
import 'package:assetsrfid/feature/goverment_management/domain/usecase/list_company_members_usecase.dart';
import 'package:assetsrfid/feature/goverment_management/domain/usecase/remove_member_usecase.dart';
import 'package:assetsrfid/feature/goverment_management/domain/usecase/respond_to_invitation_usecase.dart';
import 'package:assetsrfid/feature/goverment_management/domain/usecase/send_invitation_usecase.dart';
import 'package:assetsrfid/feature/goverment_management/domain/usecase/update_member_role_usecase.dart';
import 'package:assetsrfid/feature/goverment_management/presentation/bloc/company_members/company_members_bloc.dart';
import 'package:assetsrfid/feature/goverment_management/presentation/bloc/company_settings/company_settings_bloc.dart';
import 'package:assetsrfid/feature/goverment_management/presentation/bloc/invitations/invitation_bloc.dart';
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

import 'package:assetsrfid/feature/asset_managment/data/datasource/asset_remote_datasource.dart';
import 'package:assetsrfid/feature/asset_managment/data/repository/asset_repository_impl.dart';
import 'package:assetsrfid/feature/asset_managment/domain/repository/asset_repository.dart';
import 'package:assetsrfid/feature/asset_managment/domain/usecase/get_assets_usecase.dart';
import 'package:assetsrfid/feature/asset_managment/domain/usecase/get_asset_categories_usecase.dart';
import 'package:assetsrfid/feature/assets_explore/presentation/bloc/assets_explore/asset_explore_bloc.dart';
import 'package:assetsrfid/feature/asset_managment/domain/usecase/download_excel_template_usecase.dart'; // New Import
import 'package:assetsrfid/feature/asset_managment/domain/usecase/upload_excel_file_usecase.dart'; // New Import


final getIt = GetIt.instance;
void setupDependencies() {

  // SERVICES
  getIt.registerLazySingleton<SessionService>(() => SessionService());
  getIt.registerLazySingleton<PermissionService>(() => PermissionService());
  getIt.registerLazySingleton<TokenStorage>(() => TokenStorage());
  getIt.registerLazySingleton<http.Client>(() => http.Client());
  getIt.registerLazySingleton<CacheService>(() => CacheService());

  // DATA SOURCES
  getIt.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(client: getIt<http.Client>()));
  getIt.registerLazySingleton<CompanyRemoteDataSource>(() => CompanyRemoteDataSourceImpl(client: getIt<http.Client>(), tokenStorage: getIt<TokenStorage>()));
  getIt.registerLazySingleton<SubscriptionRemoteDataSource>(() => SubscriptionRemoteDataSourceImpl(client: getIt<http.Client>(), tokenStorage: getIt<TokenStorage>()));
  getIt.registerLazySingleton<LocalizationLocalDataSource>(() => LocalizationLocalDataSourceImpl());
  getIt.registerLazySingleton<ProfileRemoteDataSource>(() => ProfileRemoteDataSourceImpl(client: getIt<http.Client>()));
  getIt.registerLazySingleton<AssetRemoteDataSource>(() => AssetRemoteDataSourceImpl(client: getIt<http.Client>(), tokenStorage: getIt<TokenStorage>()));
  getIt.registerLazySingleton<LoanRemoteDataSource>(() => LoanRemoteDataSourceImpl(client: getIt<http.Client>(), tokenStorage: getIt<TokenStorage>()));

  // REPOSITORIES
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(remoteDataSource: getIt<AuthRemoteDataSource>()));
  getIt.registerLazySingleton<LocalizationRepository>(() => LocalizationRepositoryImpl(localDataSource: getIt<LocalizationLocalDataSource>()));
  getIt.registerLazySingleton<ProfileRepository>(() => ProfileRepositoryImpl(remoteDataSource: getIt<ProfileRemoteDataSource>()));
  getIt.registerLazySingleton<CompanySettingsRepository>(() => CompanySettingsRepositoryImpl(remoteDataSource: getIt<CompanyRemoteDataSource>()));
  getIt.registerLazySingleton<CompanyMembersRepository>(() => CompanyMembersRepositoryImpl(remoteDataSource: getIt<CompanyRemoteDataSource>()));
  getIt.registerLazySingleton<InvitationRepository>(() => InvitationRepositoryImpl(remoteDataSource: getIt<CompanyRemoteDataSource>()));
  getIt.registerLazySingleton<AssetRepository>(() => AssetRepositoryImpl(remoteDataSource: getIt<AssetRemoteDataSource>(), cacheService: getIt<CacheService>()));
  getIt.registerLazySingleton<LoanRepository>(() => LoanRepositoryImpl(remoteDataSource: getIt<LoanRemoteDataSource>()));

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
  getIt.registerFactory(() => GetUserProfileUseCase(getIt<ProfileRepository>()));
  getIt.registerLazySingleton(() => GetCompanyOverviewUseCase(getIt<CompanySettingsRepository>()));
  getIt.registerLazySingleton(() => ListCompanyMembersUseCase(getIt<CompanyMembersRepository>()));
  getIt.registerLazySingleton(() => UpdateMemberRoleUseCase(getIt<CompanyMembersRepository>()));
  getIt.registerLazySingleton(() => RemoveMemberUseCase(getIt<CompanyMembersRepository>()));
  getIt.registerLazySingleton(() => SendInvitationUseCase(getIt<InvitationRepository>()));
  getIt.registerLazySingleton(() => FetchMyInvitationsUseCase(getIt<InvitationRepository>()));
  getIt.registerLazySingleton(() => RespondToInvitationUseCase(getIt<InvitationRepository>()));
  getIt.registerLazySingleton(() => GetAssetsUseCase(getIt<AssetRepository>()));
  getIt.registerLazySingleton(() => GetAssetCategoriesUseCase(getIt<AssetRepository>()));
  getIt.registerLazySingleton(() => CreateAssetCategoryUseCase(getIt<AssetRepository>()));
  getIt.registerLazySingleton(() => UpdateAssetCategoryUseCase(getIt<AssetRepository>()));
  getIt.registerLazySingleton(() => DeleteAssetCategoryUseCase(getIt<AssetRepository>()));
  getIt.registerLazySingleton(() => UpdateAssetCategoryLinkUseCase(getIt<AssetRepository>()));
  getIt.registerLazySingleton(() => GetMyLoansUseCase(getIt<LoanRepository>()));
  getIt.registerLazySingleton(() => GetLoanedOutAssetsUseCase(getIt<LoanRepository>()));
  getIt.registerLazySingleton(() => CreateLoanUseCase(getIt<LoanRepository>()));
  getIt.registerLazySingleton(() => ReturnAssetUseCase(getIt<LoanRepository>()));
  getIt.registerLazySingleton(() => GetLoanByIdUseCase(getIt<LoanRepository>()));
  getIt.registerLazySingleton(() => GetAssetByRfidUseCase(getIt<AssetRepository>()));
  getIt.registerLazySingleton(() => UpdateAssetUseCase(getIt<AssetRepository>()));
  getIt.registerLazySingleton(() => GetAssetHistoryUseCase(getIt<AssetRepository>()));
  getIt.registerLazySingleton(() => GetAssetByIdUseCase(getIt<AssetRepository>()));
  // New Bulk Upload Use Cases
  getIt.registerLazySingleton(() => DownloadExcelTemplateUsecase(getIt<AssetRepository>()));
  getIt.registerLazySingleton(() => UploadExcelFileUsecase(getIt<AssetRepository>()));

  // BLOCS
  getIt.registerFactory(() => AuthBloc(
    tokenStorage: getIt<TokenStorage>(),
    loginUseCase: getIt<LoginUseCase>(),
    signupUseCase: getIt<SignupUseCase>(),
    verifyLoginOtpUseCase: getIt<VerifyLoginOtpUseCase>(),
    verifyTokenUseCase: getIt<VerifyTokenUseCase>(),
    requestResetCodeUseCase: getIt<RequestResetCodeUseCase>(),
    verifyResetCodeUseCase: getIt<VerifyResetCodeUseCase>(),
  ));
  getIt.registerFactory(() => LocalizationBloc(
    getLocaleUsecase: getIt<GetLocaleUsecase>(),
    setLocaleUsecase: getIt<SetLocaleUsecase>(),
  ));
  getIt.registerFactory(() => CompanyBloc(
    dataSource: getIt<CompanyRemoteDataSource>(),
    sessionService: getIt<SessionService>(),
    permissionService: getIt<PermissionService>(),
  ));
  getIt.registerFactory(() => SubscriptionBloc(dataSource: getIt<SubscriptionRemoteDataSource>()));
  getIt.registerFactory(() => ThemeBloc());
  getIt.registerFactory(() => NavBarBloc());
  getIt.registerFactory(() => ProfileBloc(getUserProfileUseCase: getIt<GetUserProfileUseCase>()));
  getIt.registerFactory(() => CompanySettingsBloc(getCompanyOverviewUseCase: getIt<GetCompanyOverviewUseCase>()));
  getIt.registerFactory(() => CompanyMembersBloc(
    listCompanyMembersUseCase: getIt<ListCompanyMembersUseCase>(),
    updateMemberRoleUseCase: getIt<UpdateMemberRoleUseCase>(),
    removeMemberUseCase: getIt<RemoveMemberUseCase>(),
    getUserProfileUseCase: getIt<GetUserProfileUseCase>(),
  ));
  getIt.registerFactory(() => InvitationBloc(
    sendInvitationUseCase: getIt<SendInvitationUseCase>(),
    fetchMyInvitationsUseCase: getIt<FetchMyInvitationsUseCase>(),
    respondToInvitationUseCase: getIt<RespondToInvitationUseCase>(),
  ));
  getIt.registerFactory(() => AssetExploreBloc(
    getAssetsUseCase: getIt<GetAssetsUseCase>(),
    getAssetCategoriesUseCase: getIt<GetAssetCategoriesUseCase>(),
    sessionService: getIt<SessionService>(),
  ));
  getIt.registerFactory(() => AssetCategoryManagementBloc(
    getAssetCategoriesUseCase: getIt<GetAssetCategoriesUseCase>(),
    getAssetsUseCase: getIt<GetAssetsUseCase>(),
    createAssetCategoryUseCase: getIt<CreateAssetCategoryUseCase>(),
    updateAssetCategoryUseCase: getIt<UpdateAssetCategoryUseCase>(),
    deleteAssetCategoryUseCase: getIt<DeleteAssetCategoryUseCase>(),
    updateAssetCategoryLinkUseCase: getIt<UpdateAssetCategoryLinkUseCase>(),
    sessionService: getIt<SessionService>(),
  ));
  getIt.registerFactory(() => AssetLoanDashboardBloc(
    getMyLoansUseCase: getIt<GetMyLoansUseCase>(),
    getLoanedOutAssetsUseCase: getIt<GetLoanedOutAssetsUseCase>(),
    returnAssetUseCase: getIt<ReturnAssetUseCase>(),
    sessionService: getIt<SessionService>(),
  ));
  getIt.registerFactory(() => AssetDetailBloc(
    getAssetByRfidUseCase: getIt(),
    getAssetHistoryUseCase: getIt(),
    getAssetCategoriesUseCase: getIt(),
    sessionService: getIt(),
  ));

  // Asset History Bloc
  getIt.registerFactory(() => AssetHistoryBloc(
    getAssetHistoryUseCase: getIt(),
    getAssetByIdUseCase: getIt(),
  ));

  // Asset Detail Edit Bloc
  getIt.registerFactory(() => AssetDetailEditBloc(
    updateAssetUseCase: getIt(),
    getAssetCategoriesUseCase: getIt(),
    sessionService: getIt(),
  ));
  getIt.registerFactory(() => CreateLoanBloc(
    createLoanUseCase: getIt<CreateLoanUseCase>(),
    getAssetByRfidUseCase: getIt<GetAssetByRfidUseCase>(),
    sessionService: getIt<SessionService>(),
  ));
  getIt.registerFactory(() => BulkUploadBloc(
    downloadExcelTemplateUsecase: getIt<DownloadExcelTemplateUsecase>(),
    uploadExcelFileUsecase: getIt<UploadExcelFileUsecase>(),
  ));

  getIt.registerFactory(() => AssetManagmentBloc(
    getAssetsUseCase: getIt<GetAssetsUseCase>(),
    sessionService: getIt<SessionService>(), // Added missing required argument
  ));
}

class AppProviders {
  static List<SingleChildWidget> providers() {
    return [
      BlocProvider<AssetManagmentBloc>(create: (context) => getIt<AssetManagmentBloc>()), // Use getIt to create instance
      BlocProvider<AuthBloc>(create: (_) => getIt<AuthBloc>()),
      BlocProvider<LocalizationBloc>(
        create: (_) => getIt<LocalizationBloc>()..add(GetInitialLocale()),
      ),
      BlocProvider<CompanyBloc>(create: (_) => getIt<CompanyBloc>()),
      BlocProvider<SubscriptionBloc>(create: (_) => getIt<SubscriptionBloc>()),
      BlocProvider<ThemeBloc>(create: (_) => getIt<ThemeBloc>()),
      BlocProvider<NavBarBloc>(create: (_) => getIt<NavBarBloc>()),
      BlocProvider<ProfileBloc>(create: (_) => getIt<ProfileBloc>()),
      BlocProvider<CompanySettingsBloc>(create: (_) => getIt<CompanySettingsBloc>()),
      BlocProvider<CompanyMembersBloc>(create: (_) => getIt<CompanyMembersBloc>()),
      BlocProvider<InvitationBloc>(create: (_) => getIt<InvitationBloc>()),
      BlocProvider<AssetExploreBloc>(create: (_) => getIt<AssetExploreBloc>()),
      BlocProvider<AssetCategoryManagementBloc>(create: (_) => getIt<AssetCategoryManagementBloc>()),
      BlocProvider<AssetLoanDashboardBloc>(create: (_) => getIt<AssetLoanDashboardBloc>()),
      BlocProvider<AssetDetailBloc>(create: (_) => getIt<AssetDetailBloc>()),
      BlocProvider<AssetHistoryBloc>(create: (_) => getIt<AssetHistoryBloc>()),
      BlocProvider<AssetDetailEditBloc>(create: (_) => getIt<AssetDetailEditBloc>()),
      BlocProvider<CreateLoanBloc>(create: (_) => getIt<CreateLoanBloc>()),
      BlocProvider<BulkUploadBloc>(create: (_) => getIt<BulkUploadBloc>()), // This line remains the same
    ];
  }
}