part of 'trip_detail_bloc.dart';

class TripDetailState extends Equatable {
  final Trip? trip;
  final List<TripDay> days;
  final List<Spot> spots;
  final List<Expense> expenses;
  final List<SettlementRecord> settlements;
  final int selectedDayIndex;
  final bool isLoading;
  final String? error;
  final bool deleted;

  const TripDetailState({
    this.trip,
    this.days = const [],
    this.spots = const [],
    this.expenses = const [],
    this.settlements = const [],
    this.selectedDayIndex = 0,
    this.isLoading = false,
    this.error,
    this.deleted = false,
  });

  TripDetailState copyWith({
    Trip? trip,
    List<TripDay>? days,
    List<Spot>? spots,
    List<Expense>? expenses,
    List<SettlementRecord>? settlements,
    int? selectedDayIndex,
    bool? isLoading,
    String? error,
    bool? deleted,
  }) =>
      TripDetailState(
        trip: trip ?? this.trip,
        days: days ?? this.days,
        spots: spots ?? this.spots,
        expenses: expenses ?? this.expenses,
        settlements: settlements ?? this.settlements,
        selectedDayIndex: selectedDayIndex ?? this.selectedDayIndex,
        isLoading: isLoading ?? this.isLoading,
        error: error,
        deleted: deleted ?? this.deleted,
      );

  @override
  List<Object?> get props =>
      [trip, days, spots, expenses, settlements, selectedDayIndex, isLoading, error, deleted];
}
