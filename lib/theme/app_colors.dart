import 'package:material_ui/material_ui.dart';

/// Palet visual EventKu. Dipakai seluruh halaman supaya warnanya konsisten.
class AppColors {
  static const primary = Color(0xFF6338E8);
  static const primaryDark = Color(0xFF4C24C9);
  static const secondary = Color(0xFFA78BFA);
  static const background = Color(0xFFF8F7FC);
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF17152E);
  static const textSecondary = Color(0xFF85839A);
  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFEF4444);
  static const line = Color(0xFFE8E6F2);
  static const lavender = Color(0xFFF3F0FF);

  static const shadow = Color(0x1417152E);
}

class AppRadius {
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 20.0;
}

BoxDecoration appSurfaceDecoration({double radius = AppRadius.md}) {
  return BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: AppColors.line),
    boxShadow: const [
      BoxShadow(
        color: AppColors.shadow,
        blurRadius: 24,
        offset: Offset(0, 8),
      ),
    ],
  );
}
