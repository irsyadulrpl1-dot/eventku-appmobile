import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eventku/data/event_repository.dart';
import 'package:eventku/models/event.dart';

// Provider untuk repository (petugas yang mengurus data)
final eventRepositoryProvider = Provider<EventRepository>(
  (ref) => EventRepository(),
);

// Isi "papan pengumuman": semua yang dibutuhkan layar daftar acara
class EventListState {
  final List<Event> events;
  final bool isLoading;
  final bool isOffline;

  const EventListState({
    this.events = const [],
    this.isLoading = true,
    this.isOffline = false,
  });

  EventListState copyWith({
    List<Event>? events,
    bool? isLoading,
    bool? isOffline,
  }) {
    return EventListState(
      events: events ?? this.events,
      isLoading: isLoading ?? this.isLoading,
      isOffline: isOffline ?? this.isOffline,
    );
  }
}

// Petugas yang mengubah isi papan
class EventListNotifier extends Notifier<EventListState> {
  @override
  EventListState build() {
    // build() harus cepat, jadi pekerjaan berat dijadwalkan setelahnya
    Future.microtask(_loadInitial);
    return const EventListState();
  }

  Future<void> _loadInitial() async {
    final repo = ref.read(eventRepositoryProvider);

    // 1. Tampilkan data lokal dulu
    final local = await repo.getLocalEvents();
    state = state.copyWith(events: local, isLoading: local.isEmpty);

    // 2. Lalu perbarui dari server
    await refresh();
  }

  Future<void> refresh() async {
    final repo = ref.read(eventRepositoryProvider);
    try {
      final fresh = await repo.refreshFromServer();
      state = state.copyWith(events: fresh, isLoading: false, isOffline: false);
    } catch (e) {
      debugPrint('GAGAL AMBIL DARI SERVER: $e');
      state = state.copyWith(isLoading: false, isOffline: true);
    }
  }

  void retry() {
    state = state.copyWith(isLoading: true);
    refresh();
  }
}

final eventListProvider = NotifierProvider<EventListNotifier, EventListState>(
  EventListNotifier.new,
);
