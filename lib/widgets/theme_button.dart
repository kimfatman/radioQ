import 'package:flutter/material.dart';

class ThemeButton extends StatelessWidget {
  final VoidCallback? onTap;

  const ThemeButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.brightness_6),
      onPressed: onTap,
    );
  }
}
