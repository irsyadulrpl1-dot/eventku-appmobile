import 'package:cached_network_image/cached_network_image.dart';
import 'package:material_ui/material_ui.dart';
import 'package:eventku/theme/app_colors.dart';

class EventPoster extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;

  const EventPoster({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      placeholder: (context, url) => const ColoredBox(
        color: AppColors.lavender,
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      errorWidget: (context, url, error) => const ColoredBox(
        color: AppColors.lavender,
        child: Icon(
          Icons.confirmation_number_outlined,
          color: AppColors.primary,
          size: 36,
        ),
      ),
    );
  }
}
