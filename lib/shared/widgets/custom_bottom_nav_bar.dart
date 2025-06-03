import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final List<IconData> icons = [Icons.person, Icons.qr_code, Icons.add, Icons.grid_view, Icons.home];
    return Container(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4.0,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(5, (index) {
          return IconButton(
            icon: Icon(
              icons[index],
              size: 6.w,
              color: currentIndex == index
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: () => onTap(index),
          );
        }),
      ),
    );
  }
}