part of 'trip_detail_bloc.dart';

class TripDetailState extends Equatable {
  final Trip? trip;
  final List<TripDay> days;
  final List<Spot> spots;
  final List<Expense> expenses;
  final int selectedDayIndex;
  final bool isLoading;
  final String? error;

  const TripDetailState({
    this.trip,
    this.days = const [],
    this.spots = const [],
    this.expenses = const [],
    this.selectedDayIndex = 0,
    this.isLoading = false,
    this.error,
  });

  TripDetailState copyWith({
    Trip? trip,
    List<TripDay>? days,
    List<Spot>? spots,
    List<Expense>? expenses,
    int? selectedDayIndex,
    bool? isLoading,
    String? error,
  }) =>
      TripDetailState(
        trip: trip ?? this.trip,
        days: days ?? this.days,
        spots: spots ?? this.spots,
        expenses: expenses ?? this.expenses,
        selectedDayIndex: selectedDayIndex ?? this.selectedDayIndex,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );

  @override
  List<Object?> get props => [trip, days, spots, expenses, selectedDayIndex, isLoading, error];
}
