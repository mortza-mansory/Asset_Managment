import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import 'nav_bar_bloc.dart';
import 'nav_bar_event.dart';
import 'nav_bar_state.dart';


class NavBarBloc extends Bloc<NavBarEvent, NavBarState> {
  NavBarBloc() : super(NavBarVisible()) {
    on<ScrollUpdated>(_onScrollUpdated);
    on<ResetNavBar>(_onResetNavBar);
  }

  void _onScrollUpdated(ScrollUpdated event, Emitter<NavBarState> emit) {
    if (!event.canHide) {
      if (state is! NavBarVisible) {
        emit(NavBarVisible());
      }
      return;
    }

    final currentState = state;
    if (currentState is NavBarVisible) {
      if (event.isScrollingDown && event.scrollOffset > 40) {
        emit(NavBarHidden(isLocked: true));
      }
    } else if (currentState is NavBarHidden && currentState.isLocked) {
      if (event.scrollOffset <= 100) {
        emit(NavBarVisible());
      }
      // Stay locked
    }
  }

  void _onResetNavBar(ResetNavBar event, Emitter<NavBarState> emit) {
    emit(NavBarVisible());
  }
}