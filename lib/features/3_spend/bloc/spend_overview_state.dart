part of 'spend_overview_bloc.dart';

class SpendOverviewState extends Equatable {
  const SpendOverviewState({
    this.isLoading = false,
    this.overview,
    this.errorMessage,
  });

  final bool isLoading;
  final GlobalSpendOverview? overview;
  final String? errorMessage;

  SpendOverviewState copyWith({
    bool? isLoading,
    GlobalSpendOverview? overview,
    String? errorMessage,
  }) =>
      SpendOverviewState(
        isLoading: isLoading ?? this.isLoading,
        overview: overview ?? this.overview,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [isLoading, overview, errorMessage];
}
