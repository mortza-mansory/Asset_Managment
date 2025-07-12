import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:assetsrfid/feature/asset_managment/domain/usecase/download_excel_template_usecase.dart';
import 'package:assetsrfid/feature/asset_managment/domain/usecase/upload_excel_file_usecase.dart';
import 'package:assetsrfid/core/error/failures.dart';

part 'bulk_upload_event.dart';
part 'bulk_upload_state.dart';

class BulkUploadBloc extends Bloc<BulkUploadEvent, BulkUploadState> {
  final DownloadExcelTemplateUsecase _downloadExcelTemplateUsecase;
  final UploadExcelFileUsecase _uploadExcelFileUsecase;

  BulkUploadBloc({
    required DownloadExcelTemplateUsecase downloadExcelTemplateUsecase,
    required UploadExcelFileUsecase uploadExcelFileUsecase,
  })  : _downloadExcelTemplateUsecase = downloadExcelTemplateUsecase,
        _uploadExcelFileUsecase = uploadExcelFileUsecase,
        super(BulkUploadInitial()) {
    on<DownloadExcelTemplate>(_onDownloadExcelTemplate);
    on<UploadExcelFile>(_onUploadExcelFile);
  }

  Future<void> _onDownloadExcelTemplate(
      DownloadExcelTemplate event, Emitter<BulkUploadState> emit) async {
    emit(BulkUploadLoading());
    final result = await _downloadExcelTemplateUsecase(event.language);

    result.fold(
          (failure) {
        String errorMessage = 'Failed to download template.';
        if (failure is ServerFailure) {
          errorMessage = failure.message;
        } else if (failure is ClientFailure) {
          errorMessage = failure.message;
        }
        emit(BulkUploadError(message: errorMessage));
      },
          (filePath) {
        final fileName = filePath.split('/').last;
        emit(BulkUploadTemplateDownloadSuccess(fileName: fileName, filePath: filePath));
      },
    );
  }

  Future<void> _onUploadExcelFile(
      UploadExcelFile event, Emitter<BulkUploadState> emit) async {
    emit(BulkUploadLoading());
    final result = await _uploadExcelFileUsecase(event.file);

    result.fold(
          (failure) {
        String errorMessage = 'Failed to upload file.';
        if (failure is ServerFailure) {
          errorMessage = failure.message;
        } else if (failure is ClientFailure) {
          errorMessage = failure.message;
        }
        emit(BulkUploadError(message: errorMessage));
      },
          (data) {
        final results = data['results'] ?? {};
        emit(BulkUploadSuccess(
          successfulUploads: results['successful_uploads'] ?? 0,
          failedUploads: results['failed_uploads'] ?? 0,
          totalRowsProcessed: results['total_rows_processed'] ?? 0,
        ));
      },
    );
  }
}