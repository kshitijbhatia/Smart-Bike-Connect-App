import 'dart:convert';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartbike_flutter/constants/strings.dart';
import 'package:smartbike_flutter/features/my_bikes/domain/bike_entity/bike_model/bike_model.dart';
import 'package:smartbike_flutter/smartbike_database/smartbike_db_impl.dart';

final dbRepoProvider = Provider<SmartBikeDatabaseRepo>((ref) => SmartBikeDatabaseRepo(ref));

class SmartBikeDatabaseRepo{

  Ref _ref;

  SmartBikeDatabaseRepo(this._ref);


  Future<List<BikeData>> getAllBikes() async{
    final allBikes = await _ref.read(databaseProvider).getAllBikes();
    final bikesList = allBikes.map((bike) => BikeData.fromJson(bike)).toList();
    return bikesList;
  }

  Future<void> deleteAllBikes() async{
    await _ref.read(databaseProvider).deleteAllBikes();
  }

  Future<int> insertAllBikes(List<BikeData> allBikesList) async{
    int result = await _ref.read(databaseProvider).insertAllBikes(allBikesList);
    return result;
    //TODO try catch has to be implemented and failure scenarios as well.
  }

  Future<List<BikeData>> updateBikeDataAttributes(List<BikeData> allBikesList) async{

    List<BikeData> _tempBikeList = [];

    for(BikeData bikeData in allBikesList){

      int bikeState = await _ref.read(databaseProvider).getBikeLastState(bikeData.id); ///Updating BikeState from Db

      BikeData updatedBikeData;

      if(bikeState != -1){


        if(bikeState == 0){
          updatedBikeData = bikeData.copyWith(bike_state: BIKE_STATE.UNLOCKED);
        }else{
          updatedBikeData = bikeData.copyWith(bike_state: BIKE_STATE.LOCKED);
        }
      }else{
        updatedBikeData = bikeData.copyWith(bike_state: BIKE_STATE.UNLOCKED);
      }
      //log('bikeStateDb $bikeState || ${updatedBikeData.bike_state}');

      ///Updating LastParkedLocation from Db
      final locData = await _ref.read(databaseProvider).getBikeLastParkedLocation(bikeData.id);

      if(locData != ''){
        Map<String,dynamic> bikeLastParkedLocation = jsonDecode(locData);
        updatedBikeData = updatedBikeData.copyWith(LastParkedLocation: bikeLastParkedLocation);
        //log('lastPark : ${updatedBikeData.id} || ${updatedBikeData.LastParkedLocation} || ${updatedBikeData.bike_state}');
      }

      _tempBikeList.add(updatedBikeData);
    }

    return _tempBikeList;

  }

  Future<void> updateBikeState(final int bikeId, final int newBikeState) async{
    await _ref.read(databaseProvider).updateBikeState(bikeId, newBikeState);
  }

  Future<void> updateBikeLastParkedLocation(final int bikeId, final String bikeLastParkedLocation) async{
   try{
     await _ref.read(databaseProvider).updateBikeLastParkedLocation(bikeId, bikeLastParkedLocation);
   }catch(e,stackTrace){
     log('updateLastParkedLocException: $e', stackTrace: stackTrace);
   }
  }

  Future<Map<String,dynamic>> fetchBikeLastParkedLocation(final int bikeId) async {

    final locData = await _ref.read(databaseProvider).getBikeLastParkedLocation(bikeId);

    if(locData != ''){
      Map<String,dynamic> bikeLastParkedLocation = jsonDecode(locData);
      log('bikeLastParkLoc $bikeId');
      return bikeLastParkedLocation;
    }

    return {};

  }

}