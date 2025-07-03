import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:assetsrfid/core/di/app_providers.dart';
import 'package:assetsrfid/core/services/session_service.dart';
import 'package:assetsrfid/feature/profile/domain/entity/user_profile_entity.dart';
import 'package:assetsrfid/feature/profile/domain/usecase/get_user_profile_usecase.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {

  final SessionService _sessionService = getIt<SessionService>();
  final GetUserProfileUseCase _getUserProfileUseCase;

  ProfileBloc({required GetUserProfileUseCase getUserProfileUseCase})
      : _getUserProfileUseCase = getUserProfileUseCase,
        super(ProfileInitial()) {
    on<LoadProfileData>(_onLoadProfileData);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoadProfileData(LoadProfileData event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());

    final activeCompany = _sessionService.getActiveCompany();
    if (activeCompany == null) {
      emit(const ProfileLoadFailure(message: 'No active company selected.'));
      return;
    }

    final failureOrUserProfile = await _getUserProfileUseCase();

    failureOrUserProfile.fold(
          (failure) => emit(ProfileLoadFailure(message: failure.message)),
          (userProfile) => emit(ProfileLoaded(userData: userProfile, activeCompany: activeCompany)),
    );
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<ProfileState> emit) async {
    await _sessionService.clearSession();
    emit(ProfileLoggedOut());
  }
}