part of 'today_bloc.dart';

sealed class TodayEvent {
  const TodayEvent();
}

class TodayLoaded extends TodayEvent {
  const TodayLoaded();
}

class TodayDaySelected extends TodayEvent {
  const TodayDaySelected(this.dayIndex);

  final int dayIndex;
}

class TodaySpotToggled extends TodayEvent {
  const TodaySpotToggled({required this.spotIndex});

  final int spotIndex;
}
