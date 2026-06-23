part of 'trip_detail_bloc.dart';

sealed class TripDetailEvent extends Equatable {
  const TripDetailEvent();
  @override
  List<Object?> get props => [];
}

final class TripDetailLoadRequested extends TripDetailEvent {}

final class TripDetailSpotAdded extends TripDetailEvent {
  final String name;
  final String? address;
  final String category;
  final String? openingHours;
  final String? estimatedDuration;
  final String? notes;

  const TripDetailSpotAdded({
    required this.name,
    this.address,
    this.category = 'other',
    this.openingHours,
    this.estimatedDuration,
    this.notes,
  });

  @override
  List<Object?> get props => [name, address, category];
}

final class TripDetailExpenseAdded extends TripDetailEvent {
  final Expense expense;
  const TripDetailExpenseAdded({required this.expense});
  @override
  List<Object?> get props => [expense];
}

final class TripDetailDaySelected extends TripDetailEvent {
  final int index;
  const TripDetailDaySelected({required this.index});
  @override
  List<Object?> get props => [index];
}

final class TripDetailSpotVisitedToggled extends TripDetailEvent {
  final String spotId;
  const TripDetailSpotVisitedToggled({required this.spotId});
  @override
  List<Object?> get props => [spotId];
}

final class TripDetailSpotsReordered extends TripDetailEvent {
  final String dayId;
  final int oldIndex;
  final int newIndex;

  const TripDetailSpotsReordered({
    required this.dayId,
    required this.oldIndex,
    required this.newIndex,
  });

  @override
  List<Object?> get props => [dayId, oldIndex, newIndex];
}

final class TripDetailSpotUpdated extends TripDetailEvent {
  final String spotId;
  final String name;
  final String? address;
  final String category;
  final String? openingHours;
  final String? estimatedDuration;
  final String? notes;

  const TripDetailSpotUpdated({
    required this.spotId,
    required this.name,
    this.address,
    this.category = 'other',
    this.openingHours,
    this.estimatedDuration,
    this.notes,
  });

  @override
  List<Object?> get props => [spotId, name, address, category];
}
