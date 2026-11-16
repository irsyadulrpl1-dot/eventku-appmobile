import 'package:material_ui/material_ui.dart';
import 'package:eventku/screens/event_list_screen.dart';
import 'package:eventku/screens/history_screen.dart';
import 'package:eventku/theme/app_colors.dart';
import 'package:eventku/widgets/custom_bottom_navigation.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;
  int _historyVersion = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _index,
        children: [
          const EventListScreen(),
          HistoryScreen(key: ValueKey(_historyVersion)),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: _index,
        onTap: (i) {
          setState(() {
            if (i == 1) _historyVersion++;
            _index = i;
          });
        },
        items: const [
          BottomNavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home_rounded,
            label: 'Beranda',
          ),
          BottomNavItem(
            icon: Icons.confirmation_number_outlined,
            activeIcon: Icons.confirmation_number_rounded,
            label: 'Pesanan',
          ),
        ],
      ),
    );
  }
}
