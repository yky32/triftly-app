part of 'spend_bloc.dart';

sealed class SpendEvent {
  const SpendEvent();
}

final class SpendLoaded extends SpendEvent {
  const SpendLoaded();
}

final class SpendReloadRequested extends SpendEvent {
  const SpendReloadRequested();
}
