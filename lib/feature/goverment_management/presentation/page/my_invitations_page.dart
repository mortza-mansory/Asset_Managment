import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:assetsrfid/core/utils/context_extensions.dart';
import 'package:assetsrfid/feature/goverment_management/presentation/bloc/invitations/invitation_bloc.dart';
import 'package:assetsrfid/feature/goverment_management/domain/entities/invitation_entity.dart';
import 'package:assetsrfid/core/di/app_providers.dart';
import 'package:get_it/get_it.dart';

import '../../domain/usecase/fetch_my_invitations_usecase.dart';
import '../../domain/usecase/respond_to_invitation_usecase.dart';
import '../../domain/usecase/send_invitation_usecase.dart';

final getIt = GetIt.instance;

class MyInvitationsPage extends StatelessWidget {
  const MyInvitationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // ✨ منطق شما برای فراهم کردن BLoC دست نخورده باقی می‌ماند
    return BlocProvider(
      create: (_) => InvitationBloc(
        sendInvitationUseCase: getIt<SendInvitationUseCase>(),
        fetchMyInvitationsUseCase: getIt<FetchMyInvitationsUseCase>(),
        respondToInvitationUseCase: getIt<RespondToInvitationUseCase>(),
      )..add(FetchMyInvitations()),
      child: const MyInvitationsView(),
    );
  }
}

class MyInvitationsView extends StatelessWidget {
  const MyInvitationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final scaffoldBackgroundColor = isDarkMode ? const Color(0xFF1A1B1E) : const Color(0xFFF4F6F8);

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('My Pending Invitations', style: GoogleFonts.poppins()),
        backgroundColor: isDarkMode ? const Color(0xFF232428) : Colors.white,
        elevation: 1,
      ),
      body: BlocConsumer<InvitationBloc, InvitationState>(
        // ✨ منطق listener شما دست نخورده باقی می‌ماند
        listener: (context, state) {
          if (state is InvitationActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.green));
            context.read<InvitationBloc>().add(FetchMyInvitations());
          } else if (state is MyInvitationsFailure) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
          }
        },
        builder: (context, state) {
          if (state is MyInvitationsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is MyInvitationsLoaded) {
            if (state.invitations.isEmpty) {
              return _buildEmptyState(context);
            }
            return RefreshIndicator(
              onRefresh: () async => context.read<InvitationBloc>().add(FetchMyInvitations()),
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: state.invitations.length,
                itemBuilder: (context, index) {
                  return _InvitationCard(invitation: state.invitations[index]);
                },
              ),
            );
          }
          return const Center(child: Text('Loading invitations...'));
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.mark_email_unread_outlined, size: 25.w, color: Colors.grey.shade400),
          SizedBox(height: 2.h),
          Text(
            'You have no pending invitations.',
            style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.grey.shade600),
          ),
          SizedBox(height: 1.h),
          Text(
            'Pull down to refresh.',
            style: GoogleFonts.poppins(fontSize: 10.sp, color: Colors.grey.shade500),
          ),
        ],
      ),
    ).animate().fadeIn();
  }
}

class _InvitationCard extends StatelessWidget {
  final InvitationEntity invitation;
  const _InvitationCard({required this.invitation});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final cardColor = isDarkMode ? const Color(0xFF2A2B2F) : Colors.white;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      color: cardColor,
      shape: RoundedRectangleBorder(
          side: BorderSide(color: isDarkMode ? Colors.white12 : Colors.grey.shade200, width: 1),
          borderRadius: BorderRadius.circular(12)
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: theme.primaryColor.withOpacity(0.1),
                  child: Text(
                    invitation.companyName.isNotEmpty ? invitation.companyName[0].toUpperCase() : '?',
                    style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Invitation to join "${invitation.companyName}"', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(
                        'Invited by: ${invitation.invitedBy}',
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow(context, Icons.work_outline, 'As Role:', invitation.roleToGrant),
            _buildInfoRow(context, Icons.timer_outlined, 'Expires:', DateFormat.yMMMd().add_jm().format(invitation.expiresAt), color: Colors.orange.shade700),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => context.read<InvitationBloc>().add(RespondToInvitation(token: invitation.token, accept: false)),
                  style: TextButton.styleFrom(foregroundColor: Colors.red.shade400),
                  child: const Text('Decline'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => context.read<InvitationBloc>().add(RespondToInvitation(token: invitation.token, accept: true)),
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Accept'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade600, foregroundColor: Colors.white),
                ),
              ],
            )
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.2, curve: Curves.easeOut);
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value, {Color? color}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: theme.textTheme.bodySmall?.color),
          const SizedBox(width: 8),
          Text(label, style: theme.textTheme.bodySmall),
          const Spacer(),
          Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}