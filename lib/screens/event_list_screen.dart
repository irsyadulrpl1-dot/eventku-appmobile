import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eventku/models/event.dart';
import 'package:eventku/providers/event_provider.dart';
import 'package:eventku/screens/event_detail_screen.dart';
import 'package:eventku/theme/app_colors.dart';
import 'package:eventku/utils/currency_formatter.dart';
import 'package:eventku/utils/date_formatter.dart';
import 'package:eventku/widgets/category_card.dart';
import 'package:eventku/widgets/empty_state.dart';
import 'package:eventku/widgets/event_card.dart';
import 'package:eventku/widgets/event_poster.dart';
import 'package:eventku/widgets/eventku_logo.dart';
import 'package:eventku/widgets/loading_widget.dart';
import 'package:eventku/widgets/search_bar.dart';

enum _SortMode { date, priceAsc, priceDesc }

class _Category {
  final String id;
  final String label;
  final IconData icon;
  final List<String> keywords;

  const _Category(this.id, this.label, this.icon, this.keywords);
}

const _categories = <_Category>[
  _Category('semua', 'Semua', Icons.grid_view_rounded, []),
  _Category('musik', 'Musik', Icons.music_note_rounded, [
    'musik',
    'konser',
    'festival',
    'live',
    'band',
    'music',
  ]),
  _Category('seminar', 'Seminar', Icons.school_rounded, [
    'seminar',
    'workshop',
    'edukasi',
    'talk',
    'kuliah',
    'kelas',
  ]),
  _Category('olahraga', 'Olahraga', Icons.sports_soccer_rounded, [
    'olahraga',
    'sport',
    'lari',
    'marathon',
    'bola',
    'futsal',
  ]),
  _Category('seni', 'Seni', Icons.palette_outlined, [
    'seni',
    'budaya',
    'teater',
    'pameran',
    'art',
    'tari',
  ]),
];

class EventListScreen extends ConsumerStatefulWidget {
  const EventListScreen({super.key});

  @override
  ConsumerState<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends ConsumerState<EventListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String _categoryId = 'semua';
  String? _location;
  _SortMode _sort = _SortMode.date;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Event> _visible(List<Event> source) {
    final category = _categories.firstWhere((c) => c.id == _categoryId);
    final query = _query.trim().toLowerCase();
    final list = source.where((event) {
      if (_location != null && event.location != _location) return false;
      if (category.keywords.isNotEmpty) {
        final blob =
            '${event.title} ${event.description} ${event.location}'.toLowerCase();
        final matched = category.keywords.any(blob.contains);
        if (!matched) return false;
      }
      if (query.isEmpty) return true;
      final blob =
          '${event.title} ${event.description} ${event.location}'.toLowerCase();
      return blob.contains(query);
    }).toList();

    switch (_sort) {
      case _SortMode.priceAsc:
        list.sort((a, b) => a.minPrice.compareTo(b.minPrice));
      case _SortMode.priceDesc:
        list.sort((a, b) => b.minPrice.compareTo(a.minPrice));
      case _SortMode.date:
        list.sort((a, b) => a.eventDate.compareTo(b.eventDate));
    }
    return list;
  }

  void _open(Event event) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EventDetailScreen(event: event)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(eventListProvider);
    final notifier = ref.read(eventListProvider.notifier);
    final filtered = _visible(state.events);
    final browsing =
        _query.trim().isEmpty && _categoryId == 'semua' && _location == null;
    final featured = browsing && filtered.isNotEmpty ? filtered.first : null;
    final list = featured == null ? filtered : filtered.skip(1).toList();
    final locations = state.events.map((e) => e.location).toSet().toList()
      ..sort();

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          if (state.isOffline) const _OfflineBanner(),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: notifier.refresh,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: _header(locations)),
                  if (state.isLoading)
                    const SliverFillRemaining(child: LoadingWidget(message: 'Memuat event...'))
                  else if (state.events.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyState(
                        icon: Icons.wifi_off_rounded,
                        title: 'Event belum tersedia',
                        message:
                            'Periksa koneksi internetmu, lalu muat ulang daftar event.',
                        actionLabel: 'Coba lagi',
                        onAction: notifier.retry,
                      ),
                    )
                  else if (filtered.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyState(
                        icon: Icons.search_off_rounded,
                        title: 'Event tidak ditemukan',
                        message:
                            'Coba kata kunci lain, atau ubah kategori dan lokasi.',
                      ),
                    )
                  else ...[
                    if (featured != null)
                      SliverToBoxAdapter(
                        child: _FeaturedBanner(
                          event: featured,
                          onTap: () => _open(featured),
                        ),
                      ),
                    if (list.isNotEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                          child: Row(
                            children: [
                              Text(
                                browsing ? 'Event Populer' : 'Hasil pencarian',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const Spacer(),
                              Text(
                                '${list.length} event',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      sliver: SliverList.builder(
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          final event = list[index];
                          return EventCard(
                            event: event,
                            onTap: () => _open(event),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(List<String> locations) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const EventKuLogo(size: 36, showWordmark: true),
          const SizedBox(height: 18),
          Text(
            'Temukan eventmu',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 4),
          const Text(
            'Beli tiket dengan mudah, lalu simpan e-ticket di satu tempat.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 16),
          EventSearchBar(
            controller: _searchController,
            onChanged: (value) => setState(() => _query = value),
            onClear: () {
              _searchController.clear();
              setState(() => _query = '');
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 92,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = _categories[index];
                return CategoryCard(
                  icon: category.icon,
                  label: category.label,
                  selected: _categoryId == category.id,
                  onTap: () => setState(() => _categoryId = category.id),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (locations.length > 1)
                Expanded(child: _locationMenu(locations))
              else
                const Spacer(),
              const SizedBox(width: 8),
              _sortMenu(),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _locationMenu(List<String> locations) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          isExpanded: true,
          value: _location,
          borderRadius: BorderRadius.circular(12),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text('Semua lokasi'),
            ),
            for (final location in locations)
              DropdownMenuItem<String?>(
                value: location,
                child: Text(location, overflow: TextOverflow.ellipsis),
              ),
          ],
          onChanged: (value) => setState(() => _location = value),
        ),
      ),
    );
  }

  Widget _sortMenu() {
    final label = switch (_sort) {
      _SortMode.date => 'Tanggal',
      _SortMode.priceAsc => 'Harga terendah',
      _SortMode.priceDesc => 'Harga tertinggi',
    };
    return PopupMenuButton<_SortMode>(
      initialValue: _sort,
      onSelected: (value) => setState(() => _sort = value),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      itemBuilder: (context) => const [
        PopupMenuItem(value: _SortMode.date, child: Text('Tanggal terdekat')),
        PopupMenuItem(value: _SortMode.priceAsc, child: Text('Harga terendah')),
        PopupMenuItem(
          value: _SortMode.priceDesc,
          child: Text('Harga tertinggi'),
        ),
      ],
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sort_rounded, size: 16, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFFFF7ED),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: const Row(
        children: [
          Icon(Icons.wifi_off_rounded, size: 16, color: Color(0xFFB45309)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Mode offline: menampilkan data tersimpan',
              style: TextStyle(
                color: Color(0xFFB45309),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedBanner extends StatelessWidget {
  final Event event;
  final VoidCallback onTap;

  const _FeaturedBanner({required this.event, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Event Unggulan', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Material(
            color: AppColors.textPrimary,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              onTap: onTap,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                child: SizedBox(
                  height: 210,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      EventPoster(imageUrl: event.posterUrl),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0x22000000), Color(0xE617152E)],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Unggulan',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              event.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${formatTanggal(event.eventDate)}  •  ${event.location}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.86),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Text(
                                  'Mulai ${formatRupiah(event.minPrice)}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    'Beli Tiket',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
