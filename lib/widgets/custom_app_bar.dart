import 'package:material_ui/material_ui.dart';
import 'package:eventku/theme/app_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const CustomAppBar({super.key, required this.title, this.actions});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);
    return AppBar(
      title: Text(title),
      actions: actions,
      automaticallyImplyLeading: false,
      leading: canPop
          ? Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Center(
                child: Material(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => Navigator.maybePop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.line),
                      ),
                      child: const Icon(Icons.arrow_back_rounded, size: 18),
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }
}
