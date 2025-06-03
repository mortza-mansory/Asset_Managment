import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onSearch;

  const CustomSearchBar({
    super.key,
    required this.controller,
    this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: 'جستجو...',
          prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.onSurface),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
        ),
        onSubmitted: (_) => onSearch?.call(),
      ),
    );
  }
}