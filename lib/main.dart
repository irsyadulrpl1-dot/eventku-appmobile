import 'package:material_ui/material_ui.dart';
import 'package:eventku/data/transaction_repository.dart';
import 'package:eventku/screens/splash_screen.dart';
import 'package:eventku/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID');
  try {
    await TransactionRepository().expireOverdue();
  } catch (e) {
    debugPrint('GAGAL MENANDAI TAGIHAN KEDALUWARSA: $e');
  }
  runApp(const ProviderScope(child: EventkuApp()));
}

class EventkuApp extends StatelessWidget {
  const EventkuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EventKu',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      builder: (context, child) {
        return DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF4F1FC), Color(0xFFE7E1F8)],
            ),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: child ?? const SizedBox.shrink(),
            ),
          ),
        );
      },
      home: const SplashScreen(),
    );
  }
}
