import 'package:material_ui/material_ui.dart';
import 'package:eventku/theme/app_colors.dart';

class LoadingWidget extends StatelessWidget {
  final String message;

  const LoadingWidget({super.key, this.message = 'Memuat...'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2.6),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
