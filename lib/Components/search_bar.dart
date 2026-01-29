import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../accessibility/accessibility_state.dart';

class SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;

  const SearchBar({
    super.key,
    required this.controller,
    required this.hintText,
    this.onSubmitted,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AccessibilityState.rebuild,
      builder: (context, _) {
        final bool highContrast = AccessibilityState.contrast.value >= 2;

        return TextField(
          controller: controller,
          onSubmitted: onSubmitted,
          style: TextStyle(color: highContrast ? Colors.white : Colors.black),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: highContrast ? Colors.white70 : Colors.grey,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: highContrast ? Colors.white : Colors.black54,
            ),
            suffixIcon: controller.text.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: highContrast ? Colors.white : Colors.black54,
                    ),
                    onPressed: () {
                      controller.clear();
                      onClear?.call();
                    },
                  )
                : null,
            filled: true,
            fillColor: highContrast ? Colors.black : AppTheme.lightBlue,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide.none,
            ),
          ),
        );
      },
    );
  }
}
