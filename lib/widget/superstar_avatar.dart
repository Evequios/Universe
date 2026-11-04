import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/superstars.dart';

/// Reusable portrait for a superstar. Falls back to initials when no usable
/// photo is configured or when the remote image cannot be loaded.
class SuperstarAvatar extends StatelessWidget {
  final Superstars superstar;
  final double size;
  final double radius;
  final Color backgroundColor;
  final Color borderColor;

  const SuperstarAvatar({
    super.key,
    required this.superstar,
    this.size = 52,
    this.radius = 14,
    this.backgroundColor = const Color(0xFF35171D),
    this.borderColor = const Color(0x88E11D2E),
  });

  String get _initials {
    final name = superstar.name.trim();
    if (name.isEmpty) return '?';
    return name.split(RegExp(r'\\s+')).map((part) => part[0]).take(2).join().toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final url = superstar.photoUrl?.trim();
    final hasPhoto = url != null && url.isNotEmpty;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasPhoto
          ? Image.network(
              url!,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _fallback(),
            )
          : _fallback(),
    );
  }

  Widget _fallback() => Center(
        child: Text(
          _initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.31,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.4,
          ),
        ),
      );
}
