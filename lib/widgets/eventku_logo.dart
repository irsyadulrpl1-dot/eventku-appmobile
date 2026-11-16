import 'package:material_ui/material_ui.dart';
import 'package:eventku/theme/app_colors.dart';

/// Tanda EventKu: tiket ungu dengan bintang, sesuai identitas di referensi.
class EventKuLogo extends StatelessWidget {
  final double size;
  final bool onDark;
  final bool showWordmark;

  const EventKuLogo({
    super.key,
    this.size = 44,
    this.onDark = false,
    this.showWordmark = false,
  });

  @override
  Widget build(BuildContext context) {
    final mark = Transform.rotate(
      angle: -0.18,
      child: Container(
        width: size,
        height: size * 0.78,
        decoration: BoxDecoration(
          color: onDark ? Colors.white : AppColors.primary,
          borderRadius: BorderRadius.circular(size * 0.22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: onDark ? 0.12 : 0.08),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Icon(
          Icons.star_rounded,
          color: onDark ? AppColors.primary : Colors.white,
          size: size * 0.46,
        ),
      ),
    );

    if (!showWordmark) return mark;

    final titleColor = onDark ? Colors.white : AppColors.textPrimary;
    final captionColor = onDark
        ? Colors.white.withValues(alpha: 0.82)
        : AppColors.textSecondary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        SizedBox(width: size * 0.28),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'EventKu',
              style: TextStyle(
                color: titleColor,
                fontSize: size * 0.42,
                fontWeight: FontWeight.w800,
                height: 1.1,
              ),
            ),
            Text(
              'Satu Aplikasi, Semua Event!',
              style: TextStyle(color: captionColor, fontSize: size * 0.24),
            ),
          ],
        ),
      ],
    );
  }
}
