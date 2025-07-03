part of 'profile_bloc.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();
  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {

  final UserProfileEntity userData;
  final ActiveCompany activeCompany;

  const ProfileLoaded({required this.userData, required this.activeCompany});

  @override
  List<Object?> get props => [userData, activeCompany];
}

class ProfileLoadFailure extends ProfileState {
  final String message;
  const ProfileLoadFailure({required this.message});
  @override
  List<Object> get props => [message];
}

class ProfileLoggedOut extends ProfileState {}