import '../models/settlement_record.dart';
import '../models/trip_models.dart';
import '../services/trip_store.dart';

abstract class TripRepository {
  List<Trip> allTrips();
  Trip? tripById(String id);
  Trip? tripByShareToken(String token);
  Future<TripDetailData?> loadDetail(String tripId);
  TripDetailData? detailSync(String tripId);

  Future<void> upsertTrip(Trip trip);
  Future<void> updateTrip(Trip trip);
  Future<void> deactivateTrip(String tripId);
  Future<void> leaveJoinedTrip(String tripId);
  Future<List<TripMemberSummary>> tripMembers(String tripId);
  Future<bool> setTripMemberRole({
    required String tripId,
    required String memberUserId,
    required String role,
  });
  Future<bool> removeTripMember({
    required String tripId,
    required String memberUserId,
  });

  void addSpot(String tripId, Spot spot);
  void updateSpot(String tripId, Spot spot);
  void removeSpot(String tripId, String spotId);
  void reorderSpotsInDay(String tripId, String dayId, int oldIndex, int newIndex);

  void addExpense(String tripId, Expense expense);
  void updateExpense(String tripId, Expense expense);
  void removeExpense(String tripId, String expenseId);
  void addSettlement(String tripId, SettlementRecord record);

  /// Pull latest trips from Supabase when [cloudUserId] is a Supabase auth id.
  Future<void> pullFromCloud(String? cloudUserId);
}
