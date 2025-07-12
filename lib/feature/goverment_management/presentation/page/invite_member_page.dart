import 'package:assetsrfid/core/services/permission_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:assetsrfid/core/utils/context_extensions.dart';
import 'package:assetsrfid/feature/goverment_management/presentation/bloc/invitations/invitation_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:assetsrfid/core/services/session_service.dart';

final getIt = GetIt.instance;

class InviteMemberPage extends StatefulWidget {
  const InviteMemberPage({super.key});

  @override
  State<InviteMemberPage> createState() => _InviteMemberPageState();
}

class _InviteMemberPageState extends State<InviteMemberPage> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  String _selectedRole = 'O'; // Operator به‌عنوان پیش‌فرض
  bool _canManageGovernmentAdmins = false; // دسترسی مدیریت ادمین‌ها
  bool _canManageOperators = false; // دسترسی مدیریت اپراتورها

  void _sendInvitation() {
    if (_formKey.currentState!.validate()) {
      context.read<InvitationBloc>().add(SendInvitation(
        identifier: _identifierController.text,
        role: _selectedRole,
        canManageGovernmentAdmins: _canManageGovernmentAdmins,
        canManageOperators: _canManageOperators,
      ));
    }
  }
  Widget _buildPermissionChip(String text, bool isGranted) {
    return Chip(
      avatar: Icon(
        isGranted ? Icons.check_circle : Icons.cancel,
        color: isGranted ? Colors.green.shade700 : Colors.red.shade700,
        size: 18,
      ),
      label: Text(text),
      backgroundColor: isGranted ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
      side: BorderSide.none,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final scaffoldBackgroundColor = isDarkMode ? const Color(0xFF1A1B1E) : const Color(0xFFF4F6F8);
    final sessionService = getIt<SessionService>();
    final currentUserRole = sessionService.getActiveCompany()?.role ?? 'O';
    final canManageGovernmentAdmins = sessionService.getActiveCompany()?.canManageGovernmentAdmins ?? false;
    final canManageOperators = sessionService.getActiveCompany()?.canManageOperators ?? false;
    final permissionService = getIt<PermissionService>();
    final currentUserCanManageGovernmentAdmins = permissionService.canManageGovernmentAdmins; // Get specific permission
    final currentUserCanManageOperators = permissionService.canManageOperators;       // Get specific permission


    final List<String> availableRoles = currentUserRole == 'A1'
        ? ['A1', 'A2', 'O']
        : (canManageGovernmentAdmins && canManageOperators)
        ? ['A2', 'O']
        : canManageOperators
        ? ['O']
        : [];

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('دعوت عضو جدید', style: GoogleFonts.poppins()),
        backgroundColor: scaffoldBackgroundColor,
        elevation: 1,
      ),
      body: BlocListener<InvitationBloc, InvitationState>(
        listener: (context, state) {
          if (state is InvitationActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
            Navigator.of(context).pop();
          } else if (state is InvitationRequiresOtp) {
            // TODO: مدیریت نیاز به OTP
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('نیاز به OTP'), backgroundColor: Colors.blue),
            );
          } else if (state is InvitationFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('اطلاعات کاربر', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                Text(
                  'ایمیل یا شماره تلفن کاربری که قصد دعوت او را دارید وارد کنید.',
                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                ),
                SizedBox(height: 2.h),
                TextFormField(
                  controller: _identifierController,
                  decoration: const InputDecoration(
                    labelText: 'ایمیل یا شماره تلفن',
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                    prefixIcon: Icon(Icons.person_search_outlined),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'این فیلد الزامی است' : null,
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 4.h),
                Text('تخصیص نقش', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                SizedBox(height: 1.h),
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  ),
                  items: availableRoles
                      .map((role) => DropdownMenuItem<String>(
                    value: role,
                    child: Text(_translateRole(role, l10n)),
                  ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedRole = value;
                        // Reset permissions if role is not A2, or if current user cannot grant them
                        if (value != 'A2' || !currentUserCanManageGovernmentAdmins) { // Adjusted condition
                          _canManageGovernmentAdmins = false;
                        }
                        if (value != 'A2' || !currentUserCanManageOperators) { // Adjusted condition
                          _canManageOperators = false;
                        }
                      });
                    }
                  },
                ),
                if (_selectedRole == 'A2' && currentUserRole != 'O') ...[ // Show A2 permissions only if A2 is selected and current user is not Operator
                  SizedBox(height: 2.h),
                  Text('دسترسی‌های ادمین', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  if (currentUserCanManageGovernmentAdmins) // Only show if current user can grant this permission
                    CheckboxListTile(
                      title: Text('مدیریت سایر ادمین‌ها (A2)'),
                      value: _canManageGovernmentAdmins,
                      onChanged: (value) {
                        setState(() {
                          _canManageGovernmentAdmins = value ?? false;
                        });
                      },
                    ),
                  if (currentUserCanManageOperators) // Only show if current user can grant this permission
                    CheckboxListTile(
                      title: Text('مدیریت اپراتورها (O)'),
                      value: _canManageOperators,
                      onChanged: (value) {
                        setState(() {
                          _canManageOperators = value ?? false;
                        });
                      },
                    ),
                ],
                SizedBox(height: 2.h),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('دسترسی‌های این نقش:', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (_selectedRole == 'A1' || _selectedRole == 'A2') ...[
                            _buildPermissionChip('مدیریت کاربران', true), // Admins/Owners manage users generally
                            _buildPermissionChip('ویرایش جزئیات', true),
                          ],
                          if (_selectedRole == 'A2') ...[
                            _buildPermissionChip('مدیریت ادمین‌ها (A2)', _canManageGovernmentAdmins), // Reflect selected value
                            _buildPermissionChip('مدیریت اپراتورها (O)', _canManageOperators),         // Reflect selected value
                          ],
                          if (_selectedRole == 'O') ...[
                            _buildPermissionChip('مشاهده اموال', true), // Operators can view assets
                            _buildPermissionChip('مدیریت کاربران', false), // Operators cannot manage users
                          ]
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 5.h),
                BlocBuilder<InvitationBloc, InvitationState>(
                  builder: (context, state) {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: state is InvitationInProgress ? null : _sendInvitation,
                        icon: state is InvitationInProgress
                            ? Container(
                          width: 24,
                          height: 24,
                          padding: const EdgeInsets.all(2.0),
                          child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                        )
                            : const Icon(Icons.send_rounded),
                        label: const Text('ارسال دعوت‌نامه'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.bold),
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ).animate().fadeIn(),
          ),
        ),
      ),
    );
  }

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
}