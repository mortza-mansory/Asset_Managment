// lib/feature/asset_managment/presentation/bloc/bulk_upload/bulk_upload_state.dart

part of 'bulk_upload_bloc.dart';

abstract class BulkUploadState extends Equatable {
  const BulkUploadState();

  @override
  List<Object> get props => [];
}

class BulkUploadInitial extends BulkUploadState {}

class BulkUploadLoading extends BulkUploadState {}

class BulkUploadTemplateDownloadSuccess extends BulkUploadState {
  final String fileName;
  final String filePath;

  const BulkUploadTemplateDownloadSuccess({required this.fileName, required this.filePath});

  @override
  List<Object> get props => [fileName, filePath];
}

class BulkUploadSuccess extends BulkUploadState {
  final int successfulUploads;
  final int failedUploads;
  final int totalRowsProcessed;

  const BulkUploadSuccess({
    required this.successfulUploads,
    required this.failedUploads,
    required this.totalRowsProcessed,
  });

  @override
  List<Object> get props => [successfulUploads, failedUploads, totalRowsProcessed];
}

class BulkUploadError extends BulkUploadState {
  final String message;

  const BulkUploadError({required this.message});

  @override
  List<Object> get props => [message];
}