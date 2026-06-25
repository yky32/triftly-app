import 'app_bootstrap.dart';
import '../../features/3_spend/bloc/spend_overview_bloc.dart';
import '../../features/5_trip_list/bloc/trip_list_bloc.dart';
import '../../features/6_trip_detail/bloc/trip_detail_bloc.dart';

/// Factory helpers for blocs wired to app services.
abstract final class AppScopeBlocs {
  static TripListBloc createTripListBloc() => TripListBloc(
        repository: AppBootstrap.tripRepository,
      );

  static TripDetailBloc createTripDetailBloc(String tripId) => TripDetailBloc(
        tripId: tripId,
        repository: AppBootstrap.tripRepository,
      );

  static SpendOverviewBloc createSpendOverviewBloc() => SpendOverviewBloc(
        session: AppBootstrap.userSession,
        repository: AppBootstrap.tripRepository,
      );
}
