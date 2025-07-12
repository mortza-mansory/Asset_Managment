// import 'package:assetsrfid/core/utils/context_extensions.dart';
// import 'package:assetsrfid/shared/widgets/onboarding_scaffold.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:sizer/sizer.dart';
//
// class MyCompaniesPage extends StatelessWidget {
//   const MyCompaniesPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return OnboardingScaffold(
//       currentStep: 4,
//       totalSteps: 5,
//       body: Padding(
//         padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 5.h),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Icon(Icons.pending_actions_rounded, size: 25.w, color: Colors.amber.shade700),
//             SizedBox(height: 3.h),
//             Text(
//               context.l10n.myCompaniesWaiting,
//               style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.bold),
//               textAlign: TextAlign.center,
//             ),
//             SizedBox(height: 1.5.h),
//             Text(
//               context.l10n.myCompaniesSubtitle,
//               style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.grey.shade600, height: 1.5),
//               textAlign: TextAlign.center,
//             ),
//             SizedBox(height: 5.h),
//             ElevatedButton.icon(
//               icon: const Icon(Icons.refresh_rounded),
//               label: Text(context.l10n.myCompaniesRefresh),
//               onPressed: () {},
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }