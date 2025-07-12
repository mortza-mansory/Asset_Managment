// lib/feature/asset_managment/presentation/pages/bulk_upload_page.dart

import 'package:assetsrfid/feature/asset_managment/presentation/pages/components/upload_status_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart'; // Import for GoRouter context extension

import '../../../../core/utils/context_extensions.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/onboarding_scaffold.dart';
import '../bloc/bulk_upload/bulk_upload_bloc.dart';


class BulkUploadPage extends StatefulWidget {
  const BulkUploadPage({super.key});

  @override
  State<BulkUploadPage> createState() => _BulkUploadPageState();
}

class _BulkUploadPageState extends State<BulkUploadPage> {
  PlatformFile? _selectedFile;

  void _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = result.files.single;
      });
    } else {
      // User canceled the picker
      setState(() {
        _selectedFile = null;
      });
    }
  }

  void _uploadFile() {
    if (_selectedFile != null) {
      context.read<BulkUploadBloc>().add(UploadExcelFile(file: _selectedFile!));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.no_file_selected_error)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      title: context.l10n.bulk_upload_title, // Using the new title field
      currentStep: 1, // Dummy values
      totalSteps: 1, // Dummy values
      onBack: () => context.go('/home'), // Navigate back to guidance page
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.l10n.bulk_upload_instructions,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            NewCustomButton(
              onPressed: _pickFile,
              text: context.l10n.select_file_button,
              icon: Icons.folder_open,
            ),
            const SizedBox(height: 20),
            if (_selectedFile != null)
              Column(
                children: [
                  Text(
                    '${context.l10n.selected_file}: ${_selectedFile!.name}',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  NewCustomButton(
                    onPressed: _uploadFile,
                    text: context.l10n.upload_file_button,
                    icon: Icons.upload_file,
                  ),
                ],
              )
            else
              Text(
                context.l10n.no_file_chosen,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 30),
            Expanded(
              child: BlocConsumer<BulkUploadBloc, BulkUploadState>(
                listener: (context, state) {
                  if (state is BulkUploadSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(context.l10n.upload_success_message)),
                    );
                  } else if (state is BulkUploadError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message)),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is BulkUploadLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is BulkUploadSuccess) {
                    return UploadStatusDisplay(
                      successfulUploads: state.successfulUploads,
                      failedUploads: state.failedUploads,
                      totalRowsProcessed: state.totalRowsProcessed,
                    );
                  } else if (state is BulkUploadError) {
                    return UploadStatusDisplay(
                      errorMessage: state.message,
                      isError: true,
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}