abstract class NavBarState {}

class NavBarVisible extends NavBarState {}

class NavBarHidden extends NavBarState {
  final bool isLocked;

  NavBarHidden({required this.isLocked});
}