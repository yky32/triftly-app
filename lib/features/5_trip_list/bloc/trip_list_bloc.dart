import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/models/trip_models.dart';

part 'trip_list_event.dart';
part 'trip_list_state.dart';

class TripListBloc extends Bloc<TripListEvent, TripListState> {
  TripListBloc() : super(const TripListState()) {
    on<TripListLoadRequested>(_onLoadRequested);
    on<TripListTripCreated>(_onTripCreated);
  }

  Future<void> _onLoadRequested(
    TripListLoadRequested event,
    Emitter<TripListState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    // TODO: Load from Supabase + Hive cache
    await Future.delayed(const Duration(milliseconds: 500));
    emit(state.copyWith(isLoading: false, trips: _mockTrips()));
  }

  Future<void> _onTripCreated(
    TripListTripCreated event,
    Emitter<TripListState> emit,
  ) async {
    // TODO: Save to Supabase + Hive cache
    emit(state.copyWith(trips: [event.trip, ...state.trips]));
  }

  List<Trip> _mockTrips() {
    final now = DateTime.now();
    final today = Trip.today;

    return [
      // —— In progress ——
      Trip(
        id: 'trip-taipei',
        name: 'Taipei Food Run',
        destination: 'Taipei, Taiwan',
        startDate: today.subtract(const Duration(days: 2)),
        endDate: today.add(const Duration(days: 3)),
        defaultCurrency: 'TWD',
        buddies: [
          Buddy.create(name: 'Wayne'),
          Buddy.create(name: 'Mia'),
        ],
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      Trip(
        id: 'trip-bangkok',
        name: 'Bangkok Sprint',
        destination: 'Bangkok, Thailand',
        startDate: today,
        endDate: today.add(const Duration(days: 4)),
        defaultCurrency: 'THB',
        buddies: [
          Buddy.create(name: 'Wayne'),
          Buddy.create(name: 'Ken'),
          Buddy.create(name: 'Priya'),
        ],
        createdAt: now.subtract(const Duration(days: 14)),
      ),
      // —— Upcoming ——
      Trip(
        id: 'trip-tokyo',
        name: 'Tokyo 2026',
        destination: 'Tokyo, Japan',
        startDate: today.add(const Duration(days: 12)),
        endDate: today.add(const Duration(days: 18)),
        defaultCurrency: 'JPY',
        buddies: [
          Buddy.create(name: 'Wayne'),
          Buddy.create(name: 'Alice'),
          Buddy.create(name: 'Bob'),
          Buddy.create(name: 'Dave'),
        ],
        createdAt: now,
      ),
      Trip(
        id: 'trip-seoul',
        name: 'Seoul Weekend',
        destination: 'Seoul, Korea',
        startDate: today.add(const Duration(days: 28)),
        endDate: today.add(const Duration(days: 31)),
        defaultCurrency: 'KRW',
        buddies: [
          Buddy.create(name: 'Wayne'),
          Buddy.create(name: 'Alice'),
        ],
        createdAt: now,
      ),
      Trip(
        id: 'trip-bali',
        name: 'Bali Reset',
        destination: 'Bali, Indonesia',
        startDate: today.add(const Duration(days: 45)),
        endDate: today.add(const Duration(days: 52)),
        defaultCurrency: 'IDR',
        buddies: [Buddy.create(name: 'Wayne')],
        createdAt: now,
      ),
      Trip(
        id: 'trip-paris',
        name: 'Paris in Autumn',
        destination: 'Paris, France',
        startDate: today.add(const Duration(days: 90)),
        endDate: today.add(const Duration(days: 97)),
        defaultCurrency: 'EUR',
        buddies: [
          Buddy.create(name: 'Wayne'),
          Buddy.create(name: 'Sophie'),
        ],
        createdAt: now,
      ),
      // —— Completed ——
      Trip(
        id: 'trip-osaka',
        name: 'Osaka Ramen Tour',
        destination: 'Osaka, Japan',
        startDate: today.subtract(const Duration(days: 21)),
        endDate: today.subtract(const Duration(days: 16)),
        defaultCurrency: 'JPY',
        buddies: [
          Buddy.create(name: 'Wayne'),
          Buddy.create(name: 'Yuki'),
        ],
        createdAt: now.subtract(const Duration(days: 60)),
      ),
      Trip(
        id: 'trip-london',
        name: 'London Workation',
        destination: 'London, UK',
        startDate: today.subtract(const Duration(days: 75)),
        endDate: today.subtract(const Duration(days: 68)),
        defaultCurrency: 'GBP',
        buddies: [Buddy.create(name: 'Wayne')],
        createdAt: now.subtract(const Duration(days: 120)),
      ),
      Trip(
        id: 'trip-hk',
        name: 'Hong Kong Home',
        destination: 'Hong Kong',
        startDate: today.subtract(const Duration(days: 200)),
        endDate: today.subtract(const Duration(days: 195)),
        defaultCurrency: 'HKD',
        buddies: [
          Buddy.create(name: 'Wayne'),
          Buddy.create(name: 'Chris'),
          Buddy.create(name: 'Jen'),
        ],
        createdAt: now.subtract(const Duration(days: 220)),
      ),
    ];
  }
}

/// Group and sort trips for the Trips tab sections.
class TripListSections {
  const TripListSections({
    required this.inProgress,
    required this.upcoming,
    required this.completed,
  });

  final List<Trip> inProgress;
  final List<Trip> upcoming;
  final List<Trip> completed;

  factory TripListSections.from(List<Trip> trips) {
    final inProgress = trips.where((t) => t.isInProgress).toList()
      ..sort((a, b) => a.endDay.compareTo(b.endDay));

    final upcoming = trips.where((t) => t.isUpcoming).toList()
      ..sort((a, b) => a.startDay.compareTo(b.startDay));

    final completed = trips.where((t) => t.isCompleted).toList()
      ..sort((a, b) => b.endDay.compareTo(a.endDay));

    return TripListSections(
      inProgress: inProgress,
      upcoming: upcoming,
      completed: completed,
    );
  }

  bool get isEmpty => inProgress.isEmpty && upcoming.isEmpty && completed.isEmpty;
}
