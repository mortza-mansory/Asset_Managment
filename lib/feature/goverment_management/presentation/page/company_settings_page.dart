import 'package:assetsrfid/core/services/session_service.dart';
import 'package:assetsrfid/core/utils/context_extensions.dart';
import 'package:assetsrfid/feature/goverment_management/domain/entities/company_member_entity.dart';
import 'package:assetsrfid/feature/goverment_management/domain/entities/company_overview_entity.dart';
import 'package:assetsrfid/feature/goverment_management/domain/usecase/get_company_overview_usecase.dart';
import 'package:assetsrfid/feature/goverment_management/domain/usecase/list_company_members_usecase.dart';
import 'package:assetsrfid/feature/goverment_management/domain/usecase/remove_member_usecase.dart';
import 'package:assetsrfid/feature/goverment_management/domain/usecase/update_member_role_usecase.dart';
import 'package:assetsrfid/feature/goverment_management/presentation/bloc/company_members/company_members_bloc.dart';
import 'package:assetsrfid/feature/goverment_management/presentation/bloc/company_settings/company_settings_bloc.dart';
import 'package:assetsrfid/feature/theme/bloc/theme_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:assetsrfid/feature/profile/domain/usecase/get_user_profile_usecase.dart'; // Import for GetUserProfileUseCase

final getIt = GetIt.instance;

class CompanySettingsPage extends StatelessWidget {
  const CompanySettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => CompanySettingsBloc(
            getCompanyOverviewUseCase: getIt<GetCompanyOverviewUseCase>(),
          )..add(LoadCompanyOverview()),
        ),
        BlocProvider(
          create: (_) => CompanyMembersBloc(
            listCompanyMembersUseCase: getIt<ListCompanyMembersUseCase>(),
            updateMemberRoleUseCase: getIt<UpdateMemberRoleUseCase>(),
            removeMemberUseCase: getIt<RemoveMemberUseCase>(),
            getUserProfileUseCase: getIt<GetUserProfileUseCase>(), // Added
          )..add(FetchCompanyMembers()),
        ),
      ],
      child: const CompanySettingsView(),
    );
  }
}

class CompanySettingsView extends StatelessWidget {
  const CompanySettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDarkMode = context.watch<ThemeBloc>().state.isDarkMode;
    final scaffoldBackgroundColor = isDarkMode ? const Color(0xFF1A1B1E) : const Color(0xFFF4F6F8);
    final indicatorColor = Colors.teal.shade400;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(l10n.companySettingsTitle, style: GoogleFonts.poppins()),
          backgroundColor: isDarkMode ? const Color(0xFF232428) : Colors.white,
          elevation: 1,
          bottom: TabBar(
            indicatorColor: indicatorColor,
            labelColor: indicatorColor,
            unselectedLabelColor: isDarkMode ? Colors.white54 : Colors.black54,
            labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            tabs: [
              Tab(icon: const Icon(Icons.people_outline), text: l10n.companySettingsUsersTab),
              Tab(icon: const Icon(Icons.info_outline), text: l10n.companySettingsDetailsTab),
              Tab(icon: const Icon(Icons.download_outlined), text: l10n.companySettingsExportTab),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _UsersView(),
            _DetailsView(),
            _ExportView(),
          ],
        ),
      ),
    );
  }
}

// ویجت تب "جزئیات"
class _DetailsView extends StatelessWidget {
  const _DetailsView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CompanySettingsBloc, CompanySettingsState>(
      builder: (context, state) {
        if (state is CompanySettingsLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is CompanyOverviewLoaded) {
          return _buildDetailsContent(context, state.overview);
        }
        if (state is CompanySettingsFailure) {
          return Center(child: Text('خطا: ${state.message}'));
        }
        return const Center(child: Text('در حال بارگذاری اطلاعات...'));
      },
    );
  }

  Widget _buildDetailsContent(BuildContext context, CompanyOverviewEntity overview) {
    final l10n = context.l10n;
    return ListView(
      padding: EdgeInsets.all(4.w),
      children: [
        _buildInfoCard(
          context,
          icon: Icons.bar_chart_rounded,
          title: 'آمار کلی',
          children: [
            _buildStatRow(l10n.companyDetailsUserCount, overview.userCount.toString(), Icons.people_outline_rounded),
            _buildStatRow(l10n.companyDetailsAssetsCount, overview.assetsCount.toString(), Icons.widgets_outlined),
          ],
        ),
        SizedBox(height: 2.h),
        _buildInfoCard(
          context,
          icon: Icons.settings_suggest_outlined,
          title: 'وضعیت و ویرایش',
          children: [
            _buildStatRow(l10n.companyDetailsStatus,
                overview.isActive ? l10n.companyStatusActive : l10n.companyStatusInactive,
                overview.isActive ? Icons.check_circle_outline_rounded : Icons.cancel_outlined,
                valueColor: overview.isActive ? Colors.green.shade400 : Colors.red.shade400
            ),
            // TODO: Add company details edit functionality
          ],
        ),
      ],
    ).animate().fadeIn();
  }

  Widget _buildInfoCard(BuildContext context, {required IconData icon, required String title, required List<Widget> children}) {
    final isDarkMode = context.watch<ThemeBloc>().state.isDarkMode;
    return Card(
      color: isDarkMode ? const Color(0xFF232428) : Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.bold)),
            const Divider(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon, {Color? valueColor}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade500, size: 20),
          SizedBox(width: 3.w),
          Text(label, style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.grey.shade600)),
          const Spacer(),
          Text(value, style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w600, color: valueColor)),
        ],
      ),
    );
  }
}

class _UsersView extends StatelessWidget {
  const _UsersView();

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<ThemeBloc>().state.isDarkMode;
    final scaffoldBackgroundColor = isDarkMode ? const Color(0xFF1A1B1E) : const Color(0xFFF4F6F8);

    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/company-settings/invite'),
        backgroundColor: Colors.teal,
        tooltip: l10n.companyMembersAddUser,
        child: const Icon(Icons.add),
      ),
      body: BlocConsumer<CompanyMembersBloc, CompanyMembersState>(
        listener: (context, state) {
          if (state is CompanyMembersActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.green));
            context.read<CompanyMembersBloc>().add(FetchCompanyMembers());
          }
          if (state is CompanyMembersFailure) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
          }
        },
        builder: (context, state) {
          if (state is CompanyMembersLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is CompanyMembersLoaded) {
            if (state.members.isEmpty) {
              return Center(child: Text('No members found.'));
            }
            return RefreshIndicator(
              onRefresh: () async => context.read<CompanyMembersBloc>().add(FetchCompanyMembers()),
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 80),
                itemCount: state.members.length,
                itemBuilder: (context, index) {
                  final member = state.members[index];
                  // Pass the current user's permissions directly from the state
                  return _MemberCard(
                    member: member,
                    currentUserRawRole: state.currentUserRawRole,
                    currentUserCanManageGovernmentAdmins: state.currentUserCanManageGovernmentAdmins,
                    currentUserCanManageOperators: state.currentUserCanManageOperators,
                  );
                },
              ),
            );
          }
          return const Center(child: Text('Loading members...'));
        },
      ),
    );
  }
}

class _MemberCard extends StatelessWidget {
  final CompanyMemberEntity member;
  final String currentUserRawRole; // Received directly
  final bool currentUserCanManageGovernmentAdmins; // Received directly
  final bool currentUserCanManageOperators;       // Received directly

  const _MemberCard({
    required this.member,
    required this.currentUserRawRole,
    required this.currentUserCanManageGovernmentAdmins,
    required this.currentUserCanManageOperators,
  });

  String _translateRole(String rawRole, AppLocalizations l10n) {
    switch (rawRole) {
      case 'A1':
        return l10n.roleOwner;
      case 'A2':
        return l10n.roleAdmin;
      case 'O':
        return l10n.roleOperator;
      default:
        return rawRole;
    }
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'A1':
        return Colors.amber.shade700;
      case 'A2':
        return Colors.blue.shade500;
      default:
        return Colors.grey.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final cardColor = isDarkMode ? const Color(0xFF2A2B2F) : Colors.white;
    final translatedRole = _translateRole(member.role, l10n);
    final roleColor = _getRoleColor(member.role);
    final sessionService = getIt<SessionService>(); // Still needed for getUserId()

    // Diagnostic Prints: Check these values in your debug console
    print('--- _MemberCard for ${member.username} (Role: ${member.role}) ---');
    print('Member ID: ${member.userId}, Current User ID: ${sessionService.getUserId()}');
    print('Member canManageGovernmentAdmins: ${member.canManageGovernmentAdmins}');
    print('Member canManageOperators: ${member.canManageOperators}');
    print('Current User Role: $currentUserRawRole');
    print('Current User canManageGovernmentAdmins: $currentUserCanManageGovernmentAdmins');
    print('Current User canManageOperators: $currentUserCanManageOperators');


    // Determine if the current user has ANY permission to manage this specific member.
    // This will make the PopupMenuButton visible.
    final bool canInteractWithMember = (member.userId != sessionService.getUserId()) && // Cannot manage self
        ((currentUserRawRole == 'A1') || // Owner can manage all
            (currentUserRawRole == 'A2' && member.role == 'A2' && currentUserCanManageGovernmentAdmins) || // A2 managing A2
            (currentUserRawRole == 'A2' && member.role == 'O' && currentUserCanManageOperators)); // A2 managing Operator

    print('Calculated canInteractWithMember: $canInteractWithMember');
    print('----------------------------------------------------');


    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      color: cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: roleColor.withOpacity(0.15),
              child: Text(
                member.username.isNotEmpty ? member.username[0].toUpperCase() : '?',
                style: TextStyle(fontSize: 18, color: roleColor, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(member.username, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(translatedRole, style: theme.textTheme.bodySmall?.copyWith(color: roleColor, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            if (canInteractWithMember) // Use the broader condition for visibility
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'role') _showChangeRoleDialog(context, member, currentUserRawRole, currentUserCanManageGovernmentAdmins, currentUserCanManageOperators);
                  if (value == 'remove') _showRemoveUserDialog(context, member);
                },
                itemBuilder: (context) {
                  List<PopupMenuEntry<String>> menuItems = [];

                  // Add "Change Role" option if current user has permission
                  if (currentUserRawRole == 'A1' || // Owner can change any role
                      (currentUserRawRole == 'A2' && member.role == 'A2' && currentUserCanManageGovernmentAdmins) || // A2 can change other A2s
                      (currentUserRawRole == 'A2' && member.role == 'O' && currentUserCanManageOperators)) { // A2 can change Operators
                    menuItems.add(PopupMenuItem(value: 'role', child: Text(l10n.companyMembersChangeRole)));
                  }

                  // Add "Remove Member" option if current user has permission
                  // Ensure A1 cannot remove another A1, and A2 cannot remove A1.
                  if (member.role != 'A1' && // Cannot remove owner
                      (currentUserRawRole == 'A1' || // Owner can remove non-owners
                          (currentUserRawRole == 'A2' && member.role == 'A2' && currentUserCanManageGovernmentAdmins) || // A2 can remove other A2s
                          (currentUserRawRole == 'A2' && member.role == 'O' && currentUserCanManageOperators))) { // A2 can remove Operators
                    if (menuItems.isNotEmpty) {
                      menuItems.add(const PopupMenuDivider());
                    }
                    menuItems.add(PopupMenuItem(value: 'remove', child: Text(l10n.companyMembersRemoveUser, style: const TextStyle(color: Colors.red))));
                  }

                  return menuItems;
                },
              ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 200.ms);
  }

  void _showChangeRoleDialog(
      BuildContext context, CompanyMemberEntity member, String currentUserRawRole, bool currentUserCanManageGovernmentAdmins, bool currentUserCanManageOperators) {
    String selectedRole = member.role;
    bool dialogCanManageGovernmentAdmins = member.canManageGovernmentAdmins ?? false; // Initialize with member's current permission
    bool dialogCanManageOperators = member.canManageOperators ?? false;               // Initialize with member's current permission

    final l10n = context.l10n;
    final theme = Theme.of(context); // Ensure theme is available in this scope

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // Define available roles based on current user's role and permissions
            final List<String> availableRoles = [];
            if (currentUserRawRole == 'A1') {
              availableRoles.addAll(['A1', 'A2', 'O']);
            } else if (currentUserRawRole == 'A2') {
              if (currentUserCanManageGovernmentAdmins) {
                availableRoles.add('A2'); // Can change to A2 if can manage A2s
              }
              if (currentUserCanManageOperators) {
                availableRoles.add('O');  // Can change to O if can manage operators
              }
            }

            // If the current member's role is not in the list of roles the current user can assign,
            // or if the member is an A1 and current user is not A1, handle accordingly.
            // For simplicity, we just ensure `selectedRole` is one of `availableRoles`.
            if (member.role == 'A1' && currentUserRawRole != 'A1') {
              // If the target member is A1 and current user is not A1, they cannot change their role.
              // The PopupMenuButton logic already handles not showing the "role" option for A1s.
            } else if (!availableRoles.contains(selectedRole)) {
              if (availableRoles.contains(member.role)) {
                selectedRole = member.role;
              } else if (availableRoles.isNotEmpty) {
                selectedRole = availableRoles.first;
              } else {
                selectedRole = member.role; // Fallback to current role if no valid options to change to
              }
            }


            return AlertDialog(
              title: Text('Change Role for ${member.username}'),
              content: Column(
                mainAxisSize: MainAxisSize.min, // Corrected from MainAxisSize.AxisSize
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    isExpanded: true,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    items: availableRoles
                        .map((role) => DropdownMenuItem<String>(value: role, child: Text(_translateRole(role, l10n))))
                        .toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedRole = value!;
                        // Reset permissions if new role is not A2 or if current user cannot grant them
                        if (selectedRole != 'A2' || !currentUserCanManageGovernmentAdmins) {
                          dialogCanManageGovernmentAdmins = false;
                        }
                        if (selectedRole != 'A2' || !currentUserCanManageOperators) {
                          dialogCanManageOperators = false;
                        }
                      });
                    },
                  ),
                  // Only show these checkboxes if the selected role is A2 AND the current user has permission to manage A2s or Operators
                  if (selectedRole == 'A2' && (currentUserCanManageGovernmentAdmins || currentUserCanManageOperators)) ...[
                    SizedBox(height: 2.h),
                    Text('دسترسی‌های ادمین', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    if (currentUserCanManageGovernmentAdmins) // Show only if current user can grant this
                      CheckboxListTile(
                        title: Text('مدیریت سایر ادمین‌ها (A2)'),
                        value: dialogCanManageGovernmentAdmins,
                        onChanged: (value) {
                          setDialogState(() {
                            dialogCanManageGovernmentAdmins = value ?? false;
                          });
                        },
                      ),
                    if (currentUserCanManageOperators) // Show only if current user can grant this
                      CheckboxListTile(
                        title: Text('مدیریت اپراتورها (O)'),
                        value: dialogCanManageOperators,
                        onChanged: (value) {
                          setDialogState(() {
                            dialogCanManageOperators = value ?? false;
                          });
                        },
                      ),
                  ],
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () {
                    if (member.role == 'A1' && currentUserRawRole != 'A1') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.noPermissionToManageOwner), backgroundColor: Colors.red),
                      );
                      Navigator.pop(dialogContext);
                      return;
                    }
                    context.read<CompanyMembersBloc>().add(UpdateMemberRole(
                      userId: member.userId,
                      newRole: selectedRole,
                      canManageGovernmentAdmins: dialogCanManageGovernmentAdmins,
                      canManageOperators: dialogCanManageOperators,
                    ));
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Confirm'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showRemoveUserDialog(BuildContext context, CompanyMemberEntity member) {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.companyMembersRemoveUser),
        content: Text(l10n.companyMembersConfirmRemove(member.username)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              context.read<CompanyMembersBloc>().add(RemoveMember(userId: member.userId));
              Navigator.pop(dialogContext);
            },
            child: Text(l10n.companyMembersConfirm, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _ExportView extends StatelessWidget {
  const _ExportView();
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: EdgeInsets.all(5.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.cloud_download_outlined, size: 25.w, color: Colors.teal.shade200),
          SizedBox(height: 3.h),
          Text(
            l10n.exportDataButton,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 2.h),
          Text(
            l10n.exportDataDescription,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 11.sp, color: Colors.grey.shade600),
          ),
          SizedBox(height: 5.h),
          ElevatedButton.icon(
            onPressed: () { /* TODO: Implement export logic */ },
            icon: const Icon(Icons.download_rounded),
            label: Text(l10n.exportDataButton),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              textStyle: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600),
            ),
          ),
          SizedBox(height: 2.h),
          ElevatedButton.icon(
            onPressed: () {
              context.go('/bulk_upload_guidance');
            },
            icon: const Icon(Icons.upload_file),
            label: Text(l10n.go_to_upload_page),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              textStyle: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600),
            ),
          )
        ],
      ).animate().fadeIn(),
    );
  }
}