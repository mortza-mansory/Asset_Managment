import 'package:assetsrfid/core/utils/context_extensions.dart';
import 'package:assetsrfid/feature/goverment_management/presentation/bloc/company/company_bloc.dart';
import 'package:assetsrfid/feature/goverment_management/presentation/bloc/company/company_event.dart';
import 'package:assetsrfid/feature/goverment_management/presentation/bloc/company/company_state.dart';
import 'package:assetsrfid/shared/widgets/custom_button.dart';
import 'package:assetsrfid/shared/widgets/custom_text_field.dart';
import 'package:assetsrfid/shared/widgets/onboarding_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class CreateCompanyPage extends StatefulWidget {
  const CreateCompanyPage({super.key});

  @override
  State<CreateCompanyPage> createState() => _CreateCompanyPageState();
}

class _CreateCompanyPageState extends State<CreateCompanyPage> {
  final _nameController = TextEditingController();
  final _industryController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _industryController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _createCompany() {
    if (_nameController.text.isNotEmpty) {
      context.read<CompanyBloc>().add(CreateCompany(name: _nameController.text));
    }
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      currentStep: 4,
      totalSteps: 5,
      onBack: () => context.pop(),
      body: BlocListener<CompanyBloc, CompanyState>(
        listener: (context, state) {
          if (state is CompanyCreated) {
            context.go('/onboarding_complete');
          } else if (state is CompanyFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.createCompanyTitle,
                  style: GoogleFonts.poppins(fontSize: 22.sp, fontWeight: FontWeight.bold),
                ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1),
                SizedBox(height: 1.h),
                Text(
                  context.l10n.createCompanySubtitle,
                  style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1),
                SizedBox(height: 5.h),
                NewCustomTextField(controller: _nameController, labelText: context.l10n.companyNameLabel, prefixIcon: Icons.business_rounded, animationDelay: 400.ms),
                SizedBox(height: 2.5.h),
                NewCustomTextField(controller: _industryController, labelText: context.l10n.companyIndustryLabel, prefixIcon: Icons.factory_outlined, animationDelay: 500.ms),
                SizedBox(height: 2.5.h),
                NewCustomTextField(controller: _addressController, labelText: context.l10n.companyAddressLabel, prefixIcon: Icons.location_city_rounded, animationDelay: 600.ms),
                SizedBox(height: 6.h),
                BlocBuilder<CompanyBloc, CompanyState>(
                  builder: (context, state) {
                    return NewCustomButton(
                      text: context.l10n.createCompanyAction,
                      backgroundColor: Colors.teal.shade600,
                      isLoading: state is CompanyLoading,
                      onPressed: _createCompany,
                      animationDelay: 700.ms,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}