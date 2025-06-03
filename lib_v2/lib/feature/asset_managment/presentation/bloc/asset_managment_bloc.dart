import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

part 'asset_managment_event.dart';
part 'asset_managment_state.dart';

class AssetManagmentBloc extends Bloc<AssetManagmentEvent, AssetManagmentState> {
  AssetManagmentBloc() : super(AssetManagmentInitial()) {
    on<AssetManagmentEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
