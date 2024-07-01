

import '../features/my_bikes/domain/bike_entity/bike_model/bike_model.dart';

abstract class SmartBikeDatabase{

  Future<List<Map<String, dynamic>>> getAllBikes();
  Future<int>  insertAllBikes(final List<BikeData> allBikesList);
  Future<void> deleteAllBikes();
  Future<void> updateBikeState(final int bikeId, final int newBikeState);
  Future<void>  updateBikeLastParkedLocation(final int bikeId,final String bikeLastParkedLocation);
  Future<int>  getBikeLastState(final int bikeId);
  Future<String> getBikeLastParkedLocation(final int bikeId);
}