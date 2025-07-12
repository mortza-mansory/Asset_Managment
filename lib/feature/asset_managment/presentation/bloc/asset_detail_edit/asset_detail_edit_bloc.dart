// lib/feature/asset_managment/presentation/bloc/asset_detail_edit/asset_detail_edit_bloc.dart

import 'package:bloc/bloc.dart';
import 'package:assetsrfid/core/error/failures.dart';
import 'package:assetsrfid/feature/asset_managment/domain/entities/asset_entity.dart';
import 'package:assetsrfid/feature/asset_managment/domain/usecase/update_asset_usecase.dart';
import 'package:assetsrfid/feature/asset_managment/domain/usecase/get_asset_categories_usecase.dart';
import 'package:assetsrfid/core/services/session_service.dart';

import 'asset_detail_edit_event.dart';
import 'asset_detail_edit_state.dart';


class AssetDetailEditBloc extends Bloc<AssetDetailEditEvent, AssetDetailEditState> {
  final UpdateAssetUseCase updateAssetUseCase;
  final GetAssetCategoriesUseCase getAssetCategoriesUseCase;
  final SessionService sessionService;


  AssetDetailEditBloc({
    required this.updateAssetUseCase,
    required this.getAssetCategoriesUseCase,
    required this.sessionService,
  }) : super(AssetDetailEditInitial()) {
    on<LoadAssetForEdit>(_onLoadAssetForEdit);
    on<UpdateAssetDetails>(_onUpdateAssetDetails);
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return (failure as ServerFailure).message;
      case CacheFailure:
        return (failure as CacheFailure).message;
      default:
        return 'An unexpected error occurred.';
    }
  }

  Future<void> _onLoadAssetForEdit(
      LoadAssetForEdit event,
      Emitter<AssetDetailEditState> emit,
      ) async {
    emit(AssetDetailEditLoaded(asset: event.asset));
  }

  Future<void> _onUpdateAssetDetails(
      UpdateAssetDetails event,
      Emitter<AssetDetailEditState> emit,
      ) async {
    emit(const AssetDetailEditLoading(message: 'Saving changes...'));

    final Map<String, dynamic> updateData = {
      if (event.name != null) 'name': event.name,
      if (event.model != null) 'model': event.model,
      if (event.serialNumber != null) 'serial_number': event.serialNumber,
      if (event.location != null) 'location': event.location,
      if (event.locationAddress != null) 'location_address': event.locationAddress, // جدید: اضافه شدن location_address
      if (event.custodian != null) 'custodian': event.custodian,
      if (event.value != null) 'value': event.value,
      if (event.description != null) 'description': event.description,
      if (event.status != null) 'status': event.status!.name,
    };

    final result = await updateAssetUseCase(event.assetId, updateData);

    await result.fold(
          (failure) async => emit(AssetDetailEditError(message: _mapFailureToMessage(failure))),
          (updatedAsset) async {
        emit(AssetDetailEditSuccess(message: 'Asset updated successfully!', updatedAsset: updatedAsset));
      },
    );
  }
}