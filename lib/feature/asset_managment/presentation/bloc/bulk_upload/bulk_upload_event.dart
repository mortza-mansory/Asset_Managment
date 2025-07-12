// lib/feature/asset_managment/presentation/bloc/bulk_upload/bulk_upload_event.dart

part of 'bulk_upload_bloc.dart';

abstract class BulkUploadEvent extends Equatable {
  const BulkUploadEvent();

  @override
  List<Object> get props => [];
}

class DownloadExcelTemplate extends BulkUploadEvent {
  final String language;

  const DownloadExcelTemplate({required this.language});

  @override
  List<Object> get props => [language];
}

class UploadExcelFile extends BulkUploadEvent {
  final PlatformFile file;

  const UploadExcelFile({required this.file});

  @override
  List<Object> get props => [file];
}