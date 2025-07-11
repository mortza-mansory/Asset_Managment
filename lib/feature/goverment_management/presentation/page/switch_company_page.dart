import 'package:assetsrfid/core/services/permission_service.dart';
import 'package:assetsrfid/core/services/session_service.dart';
import 'package:assetsrfid/core/utils/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:assetsrfid/feature/theme/bloc/theme_bloc.dart';
import 'package:assetsrfid/feature/goverment_management/presentation/bloc/company/company_bloc.dart';
import 'package:assetsrfid/feature/goverment_management/presentation/bloc/company/company_event.dart';
import 'package:assetsrfid/feature/goverment_management/presentation/bloc/company/company_state.dart';
import 'package:assetsrfid/feature/goverment_management/data/models/company_model.dart';
import 'package:get_it/get_it.dart'; // Add this import

// Ensure getIt is accessible, assuming it's initialized via setupDependencies somewhere
// final getIt = GetIt.instance; // Uncomment if not globally accessible

class CompanyMembership {
  final String id;
  final String companyName;
  final String userRole;
  final String rawRole;
  final IconData icon;
  final String? address;
  final String? industry;
  final bool canManageGovernmentAdmins;
  final bool canManageOperators;

  CompanyMembership({
    required this.id,
    required this.companyName,
    required this.userRole,
    required this.rawRole,
    required this.icon,
    this.address,
    this.industry,
    this.canManageGovernmentAdmins = false,
    this.canManageOperators = false,
  });
}

class SwitchCompanyPage extends StatefulWidget {
  const SwitchCompanyPage({super.key});

  @override
  State<SwitchCompanyPage> createState() => _SwitchCompanyPageState();
}

class _SwitchCompanyPageState extends State<SwitchCompanyPage> {
  String _activeCompanyId = '';

  @override
  void initState() {
    super.initState();
    _activeCompanyId = getIt<SessionService>().getActiveCompany()?.id.toString() ?? '';
    _fetchCompanies();
  }

  void _fetchCompanies() {
    context.read<CompanyBloc>().add(FetchCompanies());
  }

  void _switchCompany(String companyId, String companyName, String role, bool canManageGovernmentAdmins, bool canManageOperators) async {
    final sessionService = getIt<SessionService>();
    final permissionService = getIt<PermissionService>();

    final activeCompany = ActiveCompany(
      id: int.parse(companyId),
      name: companyName,
      role: role,
      canManageGovernmentAdmins: canManageGovernmentAdmins,
      canManageOperators: canManageOperators,
    );
    await sessionService.saveActiveCompany(activeCompany);

    permissionService.updateRulesForRole(
        role,
        canManageGovernmentAdmins: canManageGovernmentAdmins,
        canManageOperators: canManageOperators
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.switchToCompanySnackbar(companyName)),
        backgroundColor: Colors.green,
      ),
    );
    context.go('/splash'); // Re-initiate app to load new permissions
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDarkMode = context.watch<ThemeBloc>().state.isDarkMode;
    final scaffoldBackgroundColor = isDarkMode ? const Color(0xFF1E1E20) : const Color(0xFFF4F6F8);
    final primaryTextColor = isDarkMode ? Colors.white.withOpacity(0.9) : Colors.black87;

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.switchCompanyPageTitle, style: GoogleFonts.poppins()),
        backgroundColor: scaffoldBackgroundColor,
        //   foregroundColor: primaryTextColor,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () =>  context.go('/splash'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _fetchCompanies,
            tooltip: l10n.refreshCompaniesTooltip,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/create_company'),
        backgroundColor: Colors.teal.shade400,
        child: const Icon(Icons.add),
        tooltip: l10n.createNewCompanyTooltip,
      ),
      body: BlocListener<CompanyBloc, CompanyState>(
        listener: (context, state) {
          if (state is CompanySwitchSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.switchToCompanySnackbar(state.companyName)),
                backgroundColor: Colors.green,
              ),
            );
            context.go('/splash');
          }
          else if (state is CompanyDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.companyDeletedSnackbar),
                backgroundColor: Colors.red,
              ),
            );
            _fetchCompanies();
          } else if (state is CompanyUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.companyUpdatedSnackbar(state.company.name)),
                backgroundColor: Colors.green,
              ),
            );
            _fetchCompanies();
          } else if (state is CompanyFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.errorOperation(state.message)),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<CompanyBloc, CompanyState>(
          builder: (context, state) {
            if (state is CompanyLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is CompaniesLoaded) {
              final memberships = state.companies.map((company) {
                // Ensure company.name is not null before passing
                final String companyName = company.name;
                final String userRole = _mapRoleToL10n(company.role, l10n); // Make sure this mapping is correct
                final IconData roleIcon = _getIconForRole(company.role); // Make sure this mapping is correct

                return CompanyMembership(
                  id: company.id.toString(),
                  companyName: companyName,
                  userRole: userRole,
                  icon: roleIcon,
                  address: company.address,
                  industry: company.industry,
                  rawRole: company.role ?? 'O', // Provide a default if null
                  canManageGovernmentAdmins: company.canManageGovernmentAdmins ?? false,
                  canManageOperators: company.canManageOperators ?? false,
                );
              }).toList();

              if (memberships.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.noCompaniesFound,
                        style: GoogleFonts.poppins(fontSize: 16.sp, color: primaryTextColor),
                      ),
                      SizedBox(height: 2.h),
                      ElevatedButton(
                        onPressed: () => context.push('/create_company'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal.shade600,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                          textStyle: GoogleFonts.poppins(fontSize: 12.sp),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.add),
                            SizedBox(width: 1.w),
                            Text(l10n.createNewCompanyButton),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                itemCount: memberships.length,
                itemBuilder: (context, index) {
                  final membership = memberships[index];
                  final bool isActive = _activeCompanyId == membership.id;

                  return _CompanyMembershipCard(
                    membership: membership,
                    isActive: isActive,
                    onTap: () => context.read<CompanyBloc>().add(
                      SwitchCompany(
                        companyId: membership.id,
                        companyName: membership.companyName,
                        rawRole: membership.rawRole,
                        canManageGovernmentAdmins: membership.canManageGovernmentAdmins,
                        canManageOperators: membership.canManageOperators,
                      ),
                    ),

                    onDelete: () {
                      context.read<CompanyBloc>().add(DeleteCompany(companyId: int.parse(membership.id)));
                    },
                    onEdit: () {
                      context.push('/companies/update', extra: membership);
                    },
                  ).animate().fadeIn(delay: (100 * index).ms).slideY(begin: 0.2, curve: Curves.easeOut);
                },
              );
            } else if (state is CompanyFailure) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.errorLoadingCompanies(state.message),
                      style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 2.h),
                    ElevatedButton(
                      onPressed: _fetchCompanies,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.shade600,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                        textStyle: GoogleFonts.poppins(fontSize: 12.sp),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.refresh_rounded),
                          SizedBox(width: 1.w),
                          Text(l10n.retryButton),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  String _mapRoleToL10n(String role, l10n) {
    switch (role) {
      case 'A1':
        return l10n.companyRoleOwner;
      case 'A2': // Assuming S role maps to A2 for display based on prior context
        return l10n.companyRoleAdmin;
      case 'O': // Assuming Operator role maps to O
        return l10n.companyRoleOperator;
      default:
        return l10n.companyRoleMember;
    }
  }

  IconData _getIconForRole(String role) {
    switch (role) {
      case 'A1':
        return Icons.business;
      case 'A2': // Assuming S role maps to A2 for display based on prior context
        return Icons.local_fire_department_outlined;
      case 'O': // Assuming Operator role maps to O
        return Icons.build_outlined;
      default:
        return Icons.computer_outlined;
    }
  }
}

class _CompanyMembershipCard extends StatelessWidget {
  final CompanyMembership membership;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _CompanyMembershipCard({
    required this.membership,
    required this.isActive,
    required this.onTap,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDarkMode = context.watch<ThemeBloc>().state.isDarkMode;
    final cardColor = isDarkMode ? const Color(0xFF2A2B2F) : Colors.white;
    final primaryTextColor = isDarkMode ? Colors.white.withOpacity(0.9) : Colors.black87;
    final secondaryTextColor = isDarkMode ? Colors.white.withOpacity(0.6) : Colors.grey.shade600;
    final activeColor = Colors.teal.shade400;

    return Dismissible(
      key: Key(membership.id),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.confirmDeleteTitle),
            content: Text(l10n.confirmDeleteMessage(membership.companyName)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l10n.cancelButton),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(l10n.deleteButton, style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        onDelete();
      },
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 4.w),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      secondaryBackground: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 4.w),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      child: Card(
        color: cardColor,
        elevation: 2,
        margin: EdgeInsets.symmetric(vertical: 1.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isActive ? activeColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 6.w,
                backgroundColor: isActive ? activeColor.withOpacity(0.2) : (isDarkMode ? Colors.white12 : Colors.grey.shade200),
                child: Icon(membership.icon, color: isActive ? activeColor : secondaryTextColor),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      membership.companyName,
                      style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.bold, color: primaryTextColor),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      membership.userRole,
                      style: GoogleFonts.poppins(fontSize: 11.sp, color: secondaryTextColor),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (isActive)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2.w),
                  child: Tooltip(
                    message: l10n.activeCompanyTooltip,
                    child: Icon(Icons.check_circle_rounded, color: activeColor, size: 7.w),
                  ),
                ),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 25.w, minWidth: 20.w),
                child: ElevatedButton(
                  onPressed: isActive
                      ? null
                      : () {
                    onTap();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isActive ? Colors.grey.shade400 : Colors.teal.shade600,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                    textStyle: GoogleFonts.poppins(fontSize: 10.sp),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    l10n.switchButton,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              if (membership.userRole == l10n.companyRoleOwner) ...[
                SizedBox(width: 2.w),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 25.w, minWidth: 20.w),
                  child: ElevatedButton(
                    onPressed: () {
                      onEdit();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                      textStyle: GoogleFonts.poppins(fontSize: 10.sp),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      l10n.editCompanyButton,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}