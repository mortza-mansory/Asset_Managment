import 'package:assetsrfid/core/services/session_service.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/error/failures.dart';
import '../../../domain/entities/asset_entity.dart';
import '../../../domain/usecase/get_assets_usecase.dart';

part 'asset_managment_event.dart';
part 'asset_managment_state.dart';

class AssetManagmentBloc extends Bloc<AssetManagmentEvent, AssetManagmentState> {
  final GetAssetsUseCase _getAssetsUseCase;
  final SessionService _sessionService; // Inject SessionService
  BuildContext? _context; // To hold the context for navigation

  AssetManagmentBloc({
    required GetAssetsUseCase getAssetsUseCase,
    required SessionService sessionService, // Add SessionService to constructor
  })  : _getAssetsUseCase = getAssetsUseCase,
        _sessionService = sessionService,
        super(AssetManagmentInitial()){
    on<LoadAssets>(_onLoadAssets);
    on<CheckAssetsAndNavigateIfNeeded>(_onCheckAssetsAndNavigateIfNeeded);
  }

  void setContext(BuildContext context) {
    _context = context;
  }

  Future<void> _onLoadAssets(LoadAssets event, Emitter<AssetManagmentState> emit) async {
    emit(AssetManagmentLoading());
    final result = await _getAssetsUseCase(
      companyId: event.companyId,
      page: event.page,
      perPage: event.perPage,
      searchQuery: event.searchQuery,
      categoryId: event.categoryId,
    );

    result.fold(
          (failure) => emit(AssetManagmentError(message: _mapFailureToMessage(failure))),
          (assets) => emit(AssetsLoaded(assets: assets, isEmpty: assets.isEmpty)),
    );
  }

  Future<void> _onCheckAssetsAndNavigateIfNeeded(
      CheckAssetsAndNavigateIfNeeded event, Emitter<AssetManagmentState> emit) async {
    if (_context == null) {
      print('Error: BuildContext not set in AssetManagmentBloc. Cannot navigate.');
      emit(AssetManagmentError(message: 'Internal error: Cannot perform navigation.'));
      return;
    }

    emit(AssetManagmentLoading());
    final hasSeenBanner = _sessionService.hasSeenBulkUploadBanner();

    final result = await _getAssetsUseCase(
      companyId: event.companyId,
      page: 1,
      perPage: 1,
    );

    result.fold(
          (failure) {
        String errorMessage = 'Failed to check assets.';
        if (failure is ServerFailure) {
          errorMessage = failure.message;
        } else if (failure is NetworkFailure) {
          errorMessage = 'No internet connection. Please check your network.';
        } else if (failure is ClientFailure) {
          errorMessage = failure.message;
        } else {
          errorMessage = failure.message;
        }
        emit(AssetManagmentError(message: errorMessage));
        _context!.go('/home');
      },
          (assets) {
        if (assets.isEmpty && !hasSeenBanner) {
          _context!.go('/bulk_upload_guidance');
        } else {
          _context!.go('/home');
        }
   //     emit(AssetManagmentLoaded(assets: assets)); // Emit loaded state after navigation
      },
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'Server Error: ${(failure as ServerFailure).message}';
      case CacheFailure:
        return 'Cache Error: ${(failure as CacheFailure).message}';
      case NetworkFailure:
        return 'Network Error: Please check your internet connection.';
      default:
        return 'Unexpected Error';
    }
  }
}