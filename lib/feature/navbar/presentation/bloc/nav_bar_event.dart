abstract class NavBarEvent {}

class ScrollUpdated extends NavBarEvent {
  final double scrollOffset;
  final bool isScrollingDown;
  final bool canHide;

  ScrollUpdated({
    required this.scrollOffset,
    required this.isScrollingDown,
    required this.canHide,
  });
}

class ResetNavBar extends NavBarEvent {}
