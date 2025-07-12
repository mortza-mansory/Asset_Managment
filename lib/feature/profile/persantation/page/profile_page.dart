import 'package:assetsrfid/core/utils/context_extensions.dart';
import 'package:assetsrfid/feature/profile/persantation/bloc/profile_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:assetsrfid/feature/localization/presentation/bloc/localization_bloc.dart';
import 'package:assetsrfid/feature/localization/presentation/bloc/localization_event.dart';
import 'package:assetsrfid/feature/localization/presentation/bloc/localization_state.dart';
import 'package:assetsrfid/feature/navbar/presentation/bloc/nav_bar_bloc.dart';
import 'package:assetsrfid/feature/navbar/presentation/bloc/nav_bar_event.dart';
import 'package:assetsrfid/feature/profile/domain/entity/user_profile_entity.dart';
import 'package:assetsrfid/feature/theme/bloc/theme_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class ProfilePage extends StatefulWidget {
  final bool canHide;
  const ProfilePage({super.key, this.canHide = true});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(LoadProfileData());
    _scrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    if (!mounted) return;
    context.read<NavBarBloc>().add(
      ScrollUpdated(
        scrollOffset: _scrollController.offset,
        isScrollingDown: _scrollController.offset > 0,
        canHide: widget.canHide,
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<ThemeBloc>().state.isDarkMode;
    final scaffoldBackgroundColor = isDarkMode ? const Color(0xFF1A1B1E) : const Color(0xFFF4F6F8);

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      body: SafeArea(
        child: BlocConsumer<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state is ProfileLoggedOut) {
              context.go('/splash');
            }
          },
          builder: (context, state) {
            if (state is ProfileLoading || state is ProfileInitial) {
              return const Center(child: CircularProgressIndicator(color: Colors.blueGrey,));
            }
            if (state is ProfileLoadFailure) {
              return Center(child: Text('Error: ${state.message}'));
            }
            if (state is ProfileLoaded) {
              return _buildProfileContent(context, state);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  String _translateRole(String rawRole, AppLocalizations l10n) {
    switch (rawRole) {
      case 'A1': return l10n.roleOwner;
      case 'A2': return l10n.roleAdmin;
      case 'O': return l10n.roleOperator; // Changed from 'Operator' to 'O' to match backend Enum
      default: return rawRole;
    }
  }

  Widget _buildProfileContent(BuildContext context, ProfileLoaded state) {
    final l10n = context.l10n;
    final isDarkMode = context.watch<ThemeBloc>().state.isDarkMode;
    final translatedRole = _translateRole(state.activeCompany.role, l10n);

    final cardBackgroundColor = isDarkMode ? const Color(0xFF232428) : Colors.white;
    final primaryTextColor = isDarkMode ? Colors.white.withOpacity(0.9) : Colors.black87;
    final secondaryTextColor = isDarkMode ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.65);
    final iconColor = isDarkMode ? Colors.white.withOpacity(0.75) : Colors.grey.shade700;
    final sectionTitleColor = isDarkMode ? Colors.white.withOpacity(0.85) : Colors.black.withOpacity(0.8);
    final accentColor = Colors.tealAccent.shade200;

    return SingleChildScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildProfileHeader(context, state, primaryTextColor, secondaryTextColor, accentColor, isDarkMode),
          SizedBox(height: 1.h),

          _buildInfoSection(
              context: context, title: l10n.profileOrgInfoTitle, icon: Icons.business_center_outlined,
              onEdit: () => context.push('/company-settings'),
              items: [
                _InfoRowData(icon: Icons.apartment_outlined, label: l10n.profileOrgInfoOrgNameLabel, value: state.activeCompany.name),
                _InfoRowData(icon: Icons.badge_outlined, label: l10n.profileOrgInfoRoleLabel, value: translatedRole),
              ],
              cardBackgroundColor: cardBackgroundColor, primaryTextColor: primaryTextColor, secondaryTextColor: secondaryTextColor,
              iconColor: iconColor, sectionTitleColor: sectionTitleColor, isDarkMode: isDarkMode, animationDelay: 200.ms
          ),

          _buildInfoSection(
              context: context, title: l10n.profileAccountSettingsTitle, icon: Icons.manage_accounts_outlined,
            //  onEdit: () { /* TODO: Navigate to user profile edit page */ },
              items: [
                if (state.userData.email != null)
                  _InfoRowData(icon: Icons.email_outlined, label: l10n.profileContactInfoEmailLabel, value: state.userData.email!),
                if (state.userData.phoneNum != null) // Changed from phoneNumber
                  _InfoRowData(icon: Icons.phone_iphone_outlined, label: l10n.profileContactInfoPhoneLabel, value: state.userData.phoneNum!), // Changed from phoneNumber
                _InfoRowData(icon: Icons.password_outlined, label: l10n.profileAccountSettingsChangePassword, value: "", isAction: true, onTap: () {context.go("/forgot_password");}),
              ],
              cardBackgroundColor: cardBackgroundColor, primaryTextColor: primaryTextColor, secondaryTextColor: secondaryTextColor,
              iconColor: iconColor, sectionTitleColor: sectionTitleColor, isDarkMode: isDarkMode, animationDelay: 300.ms
          ),

          _buildInfoSection(
              context: context, title: "Application Actions", icon: Icons.apps_outlined, onEdit: null,
              items: [
                _InfoRowData(icon: Icons.info_outline, label: l10n.aboutAppTitle, value: "", isAction: true, onTap: () => context.push('/about-app')),
                _InfoRowData(
                  icon: Icons.exit_to_app_outlined, label: l10n.profileAccountSettingsLogout, value: "", isAction: true,
                  actionColor: isDarkMode ? Colors.red.shade300 : Colors.red.shade700,
                  onTap: () => context.read<ProfileBloc>().add(LogoutRequested()),
                ),
              ],
              cardBackgroundColor: cardBackgroundColor, primaryTextColor: primaryTextColor, secondaryTextColor: secondaryTextColor,
              iconColor: iconColor, sectionTitleColor: sectionTitleColor, isDarkMode: isDarkMode, animationDelay: 400.ms
          ),
          SizedBox(height: 3.h),
        ],
      ),
    ).animate().fadeIn(duration: 350.ms);
  }

  Widget _buildProfileHeader(BuildContext context, ProfileLoaded state, Color nameColor, Color roleColor, Color accentColor, bool isDarkMode) {
    final userData = state.userData;
    final activeCompany = state.activeCompany;
    final headerTextColor = isDarkMode ? Colors.white : Colors.black45;
    final dropDownBackgroundColor = isDarkMode ? const Color(0xFF37474F) : const Color(0xFFFFFFFF);

    String getInitials(String username) { // Changed from fullName
      if (username.isEmpty) return "U";
      List<String> names = username.split(" ");
      String initials = names.isNotEmpty && names[0].isNotEmpty ? names[0][0] : "";
      if (names.length > 1 && names.last.isNotEmpty) {
        initials += names.last[0];
      }
      return initials.toUpperCase();
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 5.w),
      margin: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2A2B2F) : Theme.of(context).primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        children: [
          ActionChip(
            onPressed: () => context.push('/switch_company'),
            avatar: Icon(Icons.unfold_more_rounded, color: isDarkMode ? Colors.white70 : Colors.teal.shade800, size: 20),
            label: Text(activeCompany.name, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: isDarkMode ? Colors.white70 : Colors.teal.shade800)),
            backgroundColor: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.teal.withOpacity(0.15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ).animate().fadeIn(delay: 50.ms),
          SizedBox(height: 2.h),

          // ✨ CircleAvatar logic is now simplified
          CircleAvatar(
            radius: 12.w,
            backgroundColor: isDarkMode ? accentColor.withOpacity(0.8) : Theme.of(context).primaryColor.withOpacity(0.6),
            child: Text(
                getInitials(userData.username), // Changed from fullName
                style: GoogleFonts.poppins(fontSize: 18.sp, color: isDarkMode ? Colors.black87 : Colors.white, fontWeight: FontWeight.w600)
            ),
          ).animate().scale(delay: 100.ms, duration: 400.ms, curve: Curves.elasticOut),
          SizedBox(height: 1.5.h),
          Text(userData.username, textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.bold, color: nameColor)).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2), // Changed from fullName
          SizedBox(height: 0.5.h),
          Text(_translateRole(activeCompany.role, context.l10n), textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 12.sp, color: roleColor, fontWeight: FontWeight.w500)).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3),
          SizedBox(height: 1.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(size: 22.sp, isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined, color: headerTextColor),
                onPressed: () => context.read<ThemeBloc>().toggleTheme(),
              ),
              BlocBuilder<LocalizationBloc, LocalizationState>(
                builder: (context, state) {
                  return DropdownButton<Locale>(
                    value: state.locale,
                    icon: Icon(Icons.language, color: headerTextColor, size: 20.sp),
                    underline: const SizedBox(),
                    dropdownColor: dropDownBackgroundColor,
                    items: const [ DropdownMenuItem(value: Locale('en'), child: Text('EN')), DropdownMenuItem(value: Locale('fa'), child: Text('FA')) ],
                    onChanged: (locale) { if (locale != null) { context.read<LocalizationBloc>().add(ChangeLocale(locale)); } },
                    style: GoogleFonts.poppins(color: headerTextColor, fontSize: 12.sp),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildInfoSection({ required BuildContext context, required String title, required IconData icon, VoidCallback? onEdit, required List<_InfoRowData> items, required Color cardBackgroundColor, required Color primaryTextColor, required Color secondaryTextColor, required Color iconColor, required Color sectionTitleColor, required bool isDarkMode, required Duration animationDelay, }) {
    return Card(
      elevation: isDarkMode ? 1 : 2,
      color: cardBackgroundColor,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.2.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: sectionTitleColor, size: 6.w),
                SizedBox(width: 2.5.w),
                Text(title, style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w600, color: sectionTitleColor)),
                const Spacer(),
                if (onEdit != null)
                  IconButton(
                    icon: Icon(Icons.edit_outlined, size: 5.w, color: secondaryTextColor),
                    onPressed: onEdit,
                    tooltip: 'Edit',
                  )
              ],
            ),
            const Divider(thickness: 0.5),
            ...items.asMap().entries.map((entry) {
              return _InfoRow(data: entry.value, isDarkMode: isDarkMode, primaryTextColor: primaryTextColor, secondaryTextColor: secondaryTextColor, iconColor: iconColor)
                  .animate(delay: (100 * entry.key).ms).fadeIn(duration: 300.ms).slideX(begin: 0.1, curve: Curves.easeOut);
            }).toList(),
          ],
        ),
      ),
    ).animate(delay: animationDelay).fadeIn(duration: 400.ms).slideY(begin: 0.1, curve: Curves.easeOutExpo);
  }
}

class _InfoRowData {
  final IconData icon; final String label; final String value; final bool isAction; final Color? actionColor; final VoidCallback? onTap;
  _InfoRowData({required this.icon, required this.label, required this.value, this.isAction = false, this.actionColor, this.onTap});
}

class _InfoRow extends StatelessWidget {
  final _InfoRowData data; final bool isDarkMode; final Color primaryTextColor; final Color secondaryTextColor; final Color iconColor;
  const _InfoRow({required this.data, required this.isDarkMode, required this.primaryTextColor, required this.secondaryTextColor, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: data.isAction ? data.onTap : null,
      borderRadius: BorderRadius.circular(8.0),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 1.4.h, horizontal: 1.w),
        child: Row(
          children: [
            Icon(data.icon, color: data.isAction ? (data.actionColor ?? iconColor) : iconColor, size: 5.5.w),
            SizedBox(width: 3.5.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data.label, style: GoogleFonts.poppins(fontSize: 11.5.sp, color: data.isAction ? (data.actionColor ?? primaryTextColor) : secondaryTextColor, fontWeight: data.isAction ? FontWeight.w600 : FontWeight.w500)),
                  if (!data.isAction && data.value.isNotEmpty)
                    Padding(padding: EdgeInsets.only(top: 0.2.h), child: Text(data.value, style: GoogleFonts.poppins(fontSize: 12.5.sp, color: primaryTextColor, fontWeight: FontWeight.w600))),
                ],
              ),
            ),
            if (data.isAction) Icon(Icons.arrow_forward_ios_rounded, size: 4.w, color: secondaryTextColor.withOpacity(0.7)),
          ],
        ),
      ),
    );
  }
}