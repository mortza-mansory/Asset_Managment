
import 'package:assetsrfid/core/utils/context_extensions.dart';
import 'package:flutter/material.dart';

class UploadStatusDisplay extends StatelessWidget {
  final int? successfulUploads;
  final int? failedUploads;
  final int? totalRowsProcessed;
  final String? errorMessage;
  final bool isError;

  const UploadStatusDisplay({
    super.key,
    this.successfulUploads,
    this.failedUploads,
    this.totalRowsProcessed,
    this.errorMessage,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isError) {
      return Card(
        color: Colors.red.shade100, // Adjusted to a basic color
        margin: const EdgeInsets.symmetric(vertical: 10),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.upload_failed_title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.red.shade900), // Adjusted color
              ),
              const SizedBox(height: 10),
              Text(
                '${context.l10n.error_message}: ${errorMessage ?? context.l10n.unknown_error}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.red.shade900), // Adjusted color
              ),
            ],
          ),
        ),
      );
    }

    if (successfulUploads == null && failedUploads == null && totalRowsProcessed == null) {
      return const SizedBox.shrink(); // No data to display yet
    }

    return Card(
      color: Colors.grey.shade200, // Adjusted to a basic color
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.upload_summary_title,
              style: Theme.of(context).textTheme.titleLarge, // Changed styling
            ),
            const SizedBox(height: 10),
            Text(
              '${context.l10n.total_rows_processed}: ${totalRowsProcessed ?? 0}',
              style: Theme.of(context).textTheme.bodyMedium, // Changed styling
            ),
            Text(
              '${context.l10n.successful_uploads}: ${successfulUploads ?? 0}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.green[700]),
            ),
            Text(
              '${context.l10n.failed_uploads}: ${failedUploads ?? 0}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.red[700]),
            ),
          ],
        ),
      ),
    );
  }
}