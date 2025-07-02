import 'package:assetsrfid/core/utils/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:assetsrfid/feature/theme/bloc/theme_bloc.dart';
import 'package:assetsrfid/feature/goverment_management/presentation/bloc/company_bloc.dart';
import 'package:assetsrfid/feature/goverment_management/presentation/bloc/company_event.dart';
import 'package:assetsrfid/feature/goverment_management/presentation/bloc/company_state.dart';
import 'package:assetsrfid/feature/goverment_management/data/models/company_model.dart';

class CompanyMembership {
  final String id;
  final String companyName;
  final String userRole;
  final IconData icon;
  final String? address;
  final String? industry;

  CompanyMembership({
    required this.id,
    required this.companyName,
    required this.userRole,
    required this.icon,
    this.address,
    this.industry,
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
    print('SwitchCompanyPage initState called');
    _fetchCompanies();
  }

  void _fetchCompanies() {
    print('Fetching companies...');
    context.read<CompanyBloc>().add(FetchCompanies());
  }

  void _switchCompany(String companyId, String companyName) {
    setState(() {
      _activeCompanyId = companyId;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.switchToCompanySnackbar(companyName)),
        backgroundColor: Colors.green,
      ),
    );
    context.go('/dashboard');
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
        backgroundColor: isDarkMode ? const Color(0xFF2A2B2F) : Colors.white,
        foregroundColor: primaryTextColor,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
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
          print('CompanyBloc state: $state');
          if (state is CompanyDeleted) {
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
            print('BlocBuilder state: $state');
            if (state is CompanyLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is CompaniesLoaded) {
              final memberships = state.companies.map((company) => CompanyMembership(
                id: company.id.toString(),
                companyName: company.name,
                userRole: _mapRoleToL10n(company.role, l10n),
                icon: _getIconForRole(company.role),
                address: company.address,
                industry: company.industry,
              )).toList();

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
                    onTap: () => _switchCompany(membership.id, membership.companyName),
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
      case 'S':
        return l10n.companyRoleAdmin;
      case 'Operator':
        return l10n.companyRoleOperator;
      default:
        return l10n.companyRoleMember;
    }
  }

  IconData _getIconForRole(String role) {
    switch (role) {
      case 'A1':
        return Icons.business;
      case 'S':
        return Icons.local_fire_department_outlined;
      case 'Operator':
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

    print('Rendering _CompanyMembershipCard for ${membership.companyName}');

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
                    print('Switch button pressed for ${membership.companyName}');
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
                      print('Edit button pressed for ${membership.companyName}');
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