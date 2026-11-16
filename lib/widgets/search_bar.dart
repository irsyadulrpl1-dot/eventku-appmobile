import 'package:material_ui/material_ui.dart';
import 'package:eventku/widgets/custom_text_field.dart';

class EventSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String> onChanged;
  final String hint;
  final VoidCallback? onClear;

  const EventSearchBar({
    super.key,
    this.controller,
    required this.onChanged,
    this.hint = 'Cari event, konser, atau acara',
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final hasText = controller?.text.isNotEmpty ?? false;
    return CustomTextField(
      controller: controller,
      hint: hint,
      onChanged: onChanged,
      prefixIcon: Icons.search_rounded,
      suffix: hasText
          ? IconButton(
              onPressed: onClear,
              icon: const Icon(Icons.close_rounded, size: 18),
            )
          : null,
    );
  }
}
