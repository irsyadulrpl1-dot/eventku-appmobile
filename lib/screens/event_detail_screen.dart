import 'package:material_ui/material_ui.dart';
import 'package:eventku/models/event.dart';
import 'package:eventku/screens/checkout_screen.dart';
import 'package:eventku/theme/app_colors.dart';
import 'package:eventku/utils/currency_formatter.dart';
import 'package:eventku/utils/date_formatter.dart';
import 'package:eventku/widgets/event_poster.dart';
import 'package:eventku/widgets/primary_button.dart';

class EventDetailScreen extends StatefulWidget {
  final Event event;

  const EventDetailScreen({super.key, required this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final photos = event.images.isEmpty ? [event.posterUrl] : event.images;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _HeroGallery(
              photos: photos,
              currentPage: _currentPage,
              onPageChanged: (index) => setState(() => _currentPage = index),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.title, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 14),
                  _InfoTile(
                    icon: Icons.calendar_today_rounded,
                    label: 'Tanggal',
                    value: formatTanggal(event.eventDate),
                  ),
                  _InfoTile(
                    icon: Icons.schedule_rounded,
                    label: 'Waktu',
                    value: formatJam(event.eventDate),
                  ),
                  _InfoTile(
                    icon: Icons.place_outlined,
                    label: 'Lokasi',
                    value: event.location,
                  ),
                  _InfoTile(
                    icon: Icons.sell_outlined,
                    label: 'Harga mulai',
                    value: formatRupiah(event.minPrice),
                  ),
                  const SizedBox(height: 20),
                  Text('Tentang Event', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    event.description,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      height: 1.55,
                      fontSize: 14,
                    ),
                  ),
                  if (event.ticketCategories.isNotEmpty) ...[
                    const SizedBox(height: 22),
                    Text(
                      'Kategori Tiket',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 10),
                    for (final category in event.ticketCategories)
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: appSurfaceDecoration(radius: 14),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.confirmation_number_outlined,
                              color: AppColors.primary,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                category.name,
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                            Text(
                              formatRupiah(category.price),
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.line)),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mulai dari',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      formatRupiah(event.minPrice),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 160,
                child: PrimaryButton(
                  label: 'Beli Tiket',
                  icon: Icons.arrow_forward_rounded,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CheckoutScreen(event: event),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroGallery extends StatelessWidget {
  final List<String> photos;
  final int currentPage;
  final ValueChanged<int> onPageChanged;

  const _HeroGallery({
    required this.photos,
    required this.currentPage,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 4 / 3,
          child: PageView.builder(
            itemCount: photos.length,
            onPageChanged: onPageChanged,
            itemBuilder: (context, index) {
              return EventPoster(imageUrl: photos[index]);
            },
          ),
        ),
        Positioned(
          left: 16,
          top: MediaQuery.paddingOf(context).top + 8,
          child: _CircleButton(
            icon: Icons.arrow_back_rounded,
            onTap: () => Navigator.maybePop(context),
          ),
        ),
        if (photos.length > 1)
          Positioned(
            left: 0,
            right: 0,
            bottom: 14,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(photos.length, (index) {
                final active = index == currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: active ? 18 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: active ? Colors.white : Colors.white.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(8),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 38,
          height: 38,
          child: Icon(icon, size: 18, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.lavender,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
