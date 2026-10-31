
import 'package:flutter/material.dart';

class AppFormStyles {
  AppFormStyles._();

  static const Color background = Color(0xFF101010);
  static const Color surface = Color(0xFF1B1B1B);
  static const Color border = Color(0xFF383838);
  static const Color primary = Color(0xFFD71920);
  static const Color secondaryText = Color(0xFFAAAAAA);

  static InputDecoration inputDecoration({
    required String label,
    String? hint,
    IconData? icon,
  }) {
    final outline = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: border),
    );

    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon == null
          ? null
          : Icon(icon, color: secondaryText),
      labelStyle: const TextStyle(color: secondaryText),
      hintStyle: const TextStyle(color: Color(0xFF777777)),
      filled: true,
      fillColor: surface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      border: outline,
      enabledBorder: outline,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: primary,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.redAccent,
          width: 1.5,
        ),
      ),
    );
  }
}

class AppFormSection extends StatelessWidget {
  final String title;
  final Widget? child;
  final List<Widget>? children;

  const AppFormSection({
    super.key,
    required this.title,
    this.child,
    this.children,
  }) : assert(child != null || children != null);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppFormStyles.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppFormStyles.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: AppFormStyles.primary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.3,
            ),
          ),
          const SizedBox(height: 18),
          child ?? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children!,
          ),
        ],
      ),
    );
  }
}
