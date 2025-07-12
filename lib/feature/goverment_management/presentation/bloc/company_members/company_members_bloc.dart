// Remove this line: import 'package:assetsrfid/feature/goverment_management/presentation/bloc/company_members/company_members_event.dart';
import 'package:assetsrfid/core/error/failures.dart';
import 'package:assetsrfid/feature/goverment_management/domain/usecase/remove_member_usecase.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:assetsrfid/core/di/app_providers.dart';
import 'package:assetsrfid/core/services/session_service.dart';
import 'package:assetsrfid/feature/goverment_management/domain/entities/company_member_entity.dart';
import 'package:assetsrfid/feature/goverment_management/domain/usecase/list_company_members_usecase.dart';
import 'package:assetsrfid/feature/goverment_management/domain/usecase/update_member_role_usecase.dart';
import 'package:assetsrfid/feature/profile/domain/usecase/get_user_profile_usecase.dart'; // Keep this import if getUserProfileUseCase is used for other user profile data
import 'package:assetsrfid/feature/profile/domain/entity/user_profile_entity.dart'; // Keep this import if UserProfileEntity is used for other user profile data
import 'package:assetsrfid/feature/goverment_management/data/models/company_member_model.dart'; // <--- ADD THIS IMPORT


part 'company_members_event.dart';
part 'company_members_state.dart';

class CompanyMembersBloc extends Bloc<CompanyMembersEvent, CompanyMembersState> {
  final ListCompanyMembersUseCase listCompanyMembersUseCase;
  final UpdateMemberRoleUseCase updateMemberRoleUseCase;
  final RemoveMemberUseCase removeMemberUseCase;
  final GetUserProfileUseCase getUserProfileUseCase; // Used for general profile data if needed, but not for active company role
  final SessionService _sessionService = getIt<SessionService>();

  CompanyMembersBloc({
    required this.listCompanyMembersUseCase,
    required this.updateMemberRoleUseCase,
    required this.removeMemberUseCase,
    required this.getUserProfileUseCase,
  }) : super(CompanyMembersInitial()) {
    on<FetchCompanyMembers>(_onFetchCompanyMembers);
    on<UpdateMemberRole>(_onUpdateMemberRole);
    on<RemoveMember>(_onRemoveMember);
  }

  Future<void> _onFetchCompanyMembers(FetchCompanyMembers event, Emitter<CompanyMembersState> emit) async {
    emit(CompanyMembersLoading());
    final activeCompany = _sessionService.getActiveCompany();

    if (activeCompany == null || activeCompany.id == -1) {
      emit(const CompanyMembersFailure(message: 'No active company selected. Please select a company.'));
      return;
    }

    final companyId = activeCompany.id;
    final currentUserId = _sessionService.getUserId(); // Get current logged-in user ID

    final membersResult = await listCompanyMembersUseCase.call(companyId);

    // RESTORE 'await' here. This ensures the entire fold operation completes before the handler finishes.
    await membersResult.fold(
          (membersFailure) async {
        emit(CompanyMembersFailure(message: _mapFailureToMessage(membersFailure)));
      },
          (members) async {
        final currentUserMemberEntry = members.firstWhere(
              (member) => member.userId == currentUserId,
          orElse: () => CompanyMemberModel(
            userId: currentUserId ?? -1,
            username: 'Unknown User',
            role: 'O',
            status: 'inactive',
            joinedAt: DateTime.now(),
            canManageGovernmentAdmins: false,
            canManageOperators: false,
          ),
        );

        // Get the current user's role and granular permissions directly from their member entry
        final currentUserRawRole = currentUserMemberEntry.role;
        final currentUserCanManageGovernmentAdmins = currentUserMemberEntry.canManageGovernmentAdmins ?? false;
        final currentUserCanManageOperators = currentUserMemberEntry.canManageOperators ?? false;

        print('Current User Role from Members List: $currentUserRawRole');
        print('Current User canManageGovernmentAdmins from Members List: $currentUserCanManageGovernmentAdmins');
        print('Current User canManageOperators from Members List: $currentUserCanManageOperators');

        // --- START: MODIFICATION HERE ---
        // Create a new ActiveCompany object with updated permissions
        final updatedActiveCompany = ActiveCompany(
          id: activeCompany.id,
          name: activeCompany.name,
          role: currentUserRawRole, // Ensure role is consistent with fetched member
          canManageGovernmentAdmins: currentUserCanManageGovernmentAdmins,
          canManageOperators: currentUserCanManageOperators,
        );

        // Save the updated ActiveCompany to the session service
        await _sessionService.saveActiveCompany(updatedActiveCompany);
        // --- END: MODIFICATION HERE ---

        emit(CompanyMembersLoaded(
          members: members,
          currentUserRawRole: currentUserRawRole,
          currentUserCanManageGovernmentAdmins: currentUserCanManageGovernmentAdmins,
          currentUserCanManageOperators: currentUserCanManageOperators,
        ));
      },
    );
  }

  Future<void> _onUpdateMemberRole(UpdateMemberRole event, Emitter<CompanyMembersState> emit) async {
    emit(CompanyMembersLoading());
    final companyId = _sessionService.getActiveCompany()?.id;
    if (companyId == null) {
      emit(const CompanyMembersFailure(message: 'No active company found.'));
      return;
    }
    final result = await updateMemberRoleUseCase.call(
      companyId: companyId,
      userId: event.userId,
      newRole: event.newRole,
      canManageGovernmentAdmins: event.canManageGovernmentAdmins,
      canManageOperators: event.canManageOperators,
    );
    result.fold(
          (failure) => emit(CompanyMembersFailure(message: _mapFailureToMessage(failure))),
          (_) => emit(const CompanyMembersActionSuccess(message: 'Role updated successfully')),
    );
  }

  Future<void> _onRemoveMember(RemoveMember event, Emitter<CompanyMembersState> emit) async {
    emit(CompanyMembersLoading());
    final companyId = _sessionService.getActiveCompany()?.id;
    if (companyId == null) {
      emit(const CompanyMembersFailure(message: 'No active company found.'));
      return;
    }
    final result = await removeMemberUseCase.call(
      companyId: companyId,
      userId: event.userId,
    );
    result.fold(
          (failure) => emit(CompanyMembersFailure(message: _mapFailureToMessage(failure))),
          (_) => emit(const CompanyMembersActionSuccess(message: 'Member removed successfully')),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return (failure as ServerFailure).message;
      default:
        return 'Unexpected error occurred';
    }
  }
}