part of 'spend_overview_bloc.dart';

sealed class SpendOverviewEvent extends Equatable {
  const SpendOverviewEvent();

  @override
  List<Object?> get props => [];
}

final class SpendOverviewLoadRequested extends SpendOverviewEvent {
  const SpendOverviewLoadRequested();
}

final class SpendOverviewReloadRequested extends SpendOverviewEvent {
  const SpendOverviewReloadRequested();
}
