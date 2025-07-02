import 'package:assetsrfid/core/utils/context_extensions.dart';
import 'package:assetsrfid/feature/goverment_management/presentation/bloc/company_bloc.dart';
import 'package:assetsrfid/feature/goverment_management/presentation/bloc/company_event.dart';
import 'package:assetsrfid/feature/goverment_management/presentation/bloc/company_state.dart';
import 'package:assetsrfid/shared/widgets/custom_button.dart';
import 'package:assetsrfid/shared/widgets/custom_text_field.dart';
import 'package:assetsrfid/shared/widgets/onboarding_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:assetsrfid/feature/goverment_management/presentation/page/switch_company_page.dart';

class UpdateCompanyPage extends StatefulWidget {
  final CompanyMembership company;
  const UpdateCompanyPage({super.key, required this.company});

  @override
  State<UpdateCompanyPage> createState() => _UpdateCompanyPageState();
}

class _UpdateCompanyPageState extends State<UpdateCompanyPage> {
  final _nameController = TextEditingController();
  final _industryController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.company.companyName;
    _industryController.text = widget.company.industry ?? '';
    _addressController.text = widget.company.address ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _industryController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _updateCompany() {
    if (_nameController.text.isNotEmpty) {
      context.read<CompanyBloc>().add(UpdateCompany(
        companyId: int.parse(widget.company.id),
        name: _nameController.text,
        address: _addressController.text.isNotEmpty ? _addressController.text : null,
        industry: _industryController.text.isNotEmpty ? _industryController.text : null,
      ));
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
          if (state is CompanyUpdated) {
            context.go('/companies/switch');
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
                  context.l10n.updateCompanyTitle,
                  style: GoogleFonts.poppins(fontSize: 22.sp, fontWeight: FontWeight.bold),
                ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1),
                SizedBox(height: 1.h),
                Text(
                  context.l10n.updateCompanySubtitle,
                  style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1),
                SizedBox(height: 5.h),
                NewCustomTextField(
                  controller: _nameController,
                  labelText: context.l10n.companyNameLabel,
                  prefixIcon: Icons.business_rounded,
                  animationDelay: 400.ms,
                ),
                SizedBox(height: 2.5.h),
                NewCustomTextField(
                  controller: _industryController,
                  labelText: context.l10n.companyIndustryLabel,
                  prefixIcon: Icons.factory_outlined,
                  animationDelay: 500.ms,
                ),
                SizedBox(height: 2.5.h),
                NewCustomTextField(
                  controller: _addressController,
                  labelText: context.l10n.companyAddressLabel,
                  prefixIcon: Icons.location_city_rounded,
                  animationDelay: 600.ms,
                ),
                SizedBox(height: 6.h),
                BlocBuilder<CompanyBloc, CompanyState>(
                  builder: (context, state) {
                    return NewCustomButton(
                      text: context.l10n.updateCompanyAction,
                      backgroundColor: Colors.teal.shade600,
                      isLoading: state is CompanyLoading,
                      onPressed: _updateCompany,
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