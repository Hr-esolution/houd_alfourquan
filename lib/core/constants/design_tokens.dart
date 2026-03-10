import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════════════
//  DESIGN TOKENS — Palette stricte Dark/Light Glassmorphism
// ═══════════════════════════════════════════════════════════════════════
//  Dark  : noir #0A0A0A · or #C9A84C · blanc #FFFFFF
//  Light : noir #0A0A0A · blanc #FFFFFF · vert #1B5E20 · or #C9A84C
// ═══════════════════════════════════════════════════════════════════════

class DT {
  // Shared colors
  static const noir = Color(0xFF0A0A0A);
  static const blanc = Color(0xFFFFFFFF);
  static const or = Color(0xFFC9A84C);
  static const orLight = Color(0xFFE8C96A);
  static const orDark = Color(0xFF8A6A1E);

  // Light mode only
  static const vert = Color(0xFF1B5E20);
  static const vertLight = Color(0xFF2E7D32);

  // Dark surfaces
  static const darkCard = Color(0xFF181818);

  // ──────────────────────────────────────────────────────────────────────
  //  Helpers
  // ──────────────────────────────────────────────────────────────────────
  static bool dark(BuildContext c) => Theme.of(c).brightness == Brightness.dark;

  static Color bg(BuildContext c) => dark(c) ? noir : blanc;
  static Color glass(BuildContext c) =>
      dark(c) ? blanc.withValues(alpha: 0.05) : noir.withValues(alpha: 0.03);
  static Color borderColor(BuildContext c) =>
      dark(c) ? or.withValues(alpha: 0.25) : noir.withValues(alpha: 0.08);
  static Color accent(BuildContext c) => dark(c) ? or : vert;
  static Color txt(BuildContext c) => dark(c) ? blanc : noir;
  static Color subC(BuildContext c) =>
      dark(c) ? blanc.withValues(alpha: 0.45) : noir.withValues(alpha: 0.45);
  static Color divider(BuildContext c) =>
      dark(c) ? blanc.withValues(alpha: 0.06) : noir.withValues(alpha: 0.07);

  // ──────────────────────────────────────────────────────────────────────
  //  Gradients
  // ──────────────────────────────────────────────────────────────────────
  static List<Color> accentGrad(BuildContext c) =>
      dark(c) ? [orDark, or] : [vert, vertLight];

  static List<Color> goldGrad = const [orDark, or];

  // ──────────────────────────────────────────────────────────────────────
  //  Typography
  // ──────────────────────────────────────────────────────────────────────
  static TextStyle titleLg(BuildContext c) => TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w800,
    color: dark(c) ? or : noir,
    letterSpacing: 0.6,
  );

  static TextStyle titleMd(BuildContext c) =>
      TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: txt(c));

  static TextStyle label(BuildContext c) => TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w800,
    color: or,
    letterSpacing: 1.2,
  );

  static TextStyle sub(BuildContext c) =>
      TextStyle(fontSize: 10, fontWeight: FontWeight.w400, color: subC(c));
}

// ═══════════════════════════════════════════════════════════════════════
//  Glassmorphism Container
// ═══════════════════════════════════════════════════════════════════════
class Glass extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding, margin;
  final Color? forceBorder;
  final double borderRadius;

  const Glass({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.forceBorder,
    this.borderRadius = 14,
  });

  @override
  Widget build(BuildContext c) => Container(
    margin: margin,
    padding: padding,
    decoration: BoxDecoration(
      color: DT.glass(c),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: forceBorder ?? DT.borderColor(c), width: 0.8),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: DT.dark(c) ? 0.35 : 0.06),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: child,
  );
}

// ═══════════════════════════════════════════════════════════════════════
//  Gradient Action Button (30×30)
// ═══════════════════════════════════════════════════════════════════════
class ActionBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;
  final List<Color>? colors;
  final Color? iconColor;
  final double size;

  const ActionBtn({
    super.key,
    required this.icon,
    required this.onTap,
    this.tooltip,
    this.colors,
    this.iconColor,
    this.size = 30,
  });

  @override
  Widget build(BuildContext context) {
    final grad = colors ?? DT.accentGrad(context);
    final Widget btn = GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: grad,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: grad.last.withValues(alpha: 0.30),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: iconColor ?? DT.blanc, size: size * 0.53),
      ),
    );
    return tooltip != null ? Tooltip(message: tooltip!, child: btn) : btn;
  }
}

// ═══════════════════════════════════════════════════════════════════════
//  Mini Icon Button (for player bar etc.)
// ═══════════════════════════════════════════════════════════════════════
class MiniBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final double size;

  const MiniBtn({
    super.key,
    required this.icon,
    required this.color,
    required this.onTap,
    this.size = 22,
  });

  @override
  Widget build(_) => GestureDetector(
    onTap: onTap,
    child: Icon(icon, color: color, size: size),
  );
}

// ═══════════════════════════════════════════════════════════════════════
//  Badge numéroté (compteur)
// ═══════════════════════════════════════════════════════════════════════
class DHBadge extends StatelessWidget {
  final String text;
  final Color? color;
  final double alpha;

  const DHBadge({super.key, required this.text, this.color, this.alpha = 0.35});

  @override
  Widget build(BuildContext context) {
    final c = color ?? DT.or;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        border: Border.all(color: c.withValues(alpha: alpha)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: c),
      ),
    );
  }
}
