import 'dart:convert';
import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartbike_flutter/features/my_bikes/data/my_bike_data_source/my_bike_api_impl.dart';
import 'package:smartbike_flutter/features/my_bikes/domain/bike_entity/bike_model/bike_model.dart';
import 'package:smartbike_flutter/features/my_bikes/domain/bike_entity/state/bike_list_state.dart';
import 'package:smartbike_flutter/generated/locale_keys.g.dart';
import 'package:smartbike_flutter/network/api_end_points.dart';
import 'package:smartbike_flutter/network/exception.dart';


final myBikeRepoProvider = Provider<MyBikeRepo>((ref) => MyBikeRepo(ref));

class MyBikeRepo {

  int dataCount = 0;
  bool paginatedLoader = false;
  final Ref _ref;

  MyBikeRepo(this._ref);


  Future<BikeList> getBike({required List <int> userIds, required int start ,required int limit, required apiEndPoint})  async {

    List<BikeData> bikeList = [];

    Map<String, dynamic> body = {
      "filters": {},

      "sort": [
        {
          "property": "vehicle_id",
          "direction": "asc"
        }
      ],
      "data_filters": []
    };

    Map<String, dynamic> headers = {
      'start' : start,
      'limit' : limit
    };

    try {
      final response = await _ref.read(myBikeApiProvider).getBike(pathParam: apiEndPoint, body: body,headers: headers );
      int responseCode = 0;
      if(response.statusCode != null){
        responseCode = response.statusCode!;
      }
      if(response.statusCode == 200){
        log('bikeResponse ${response.data}');
        if(json.decode(response.data)['data'] != null){
          if(start == 0){
            bikeList = (json.decode(response.data)['data'] as List<dynamic>).map((bike) => BikeData.fromJson(bike)).toList();
            dataCount = jsonDecode(response.data)['dataCount'];
            if(bikeList.length > 10) paginatedLoader = true;
            return BikeList(values: bikeList);
          } else{
            paginatedLoader = true;
            bikeList.addAll((json.decode(response.data)['data'] as List<dynamic>).map((bike) => BikeData.fromJson(bike)).toList());
            dataCount = jsonDecode(response.data)['dataCount'];
            paginatedLoader = false;
            return BikeList(values: bikeList, );
          }
        } else{
          dataCount = 0;
          paginatedLoader = false;
          if(bikeList.length != 0){
            return BikeList(values: bikeList);
          } else {
            throw DataException.customException(LocaleKeys.toastNoRecords.tr());
          }
        }
      }else if(responseCode >= 400 && responseCode < 500){
        log('bikeApiResponse : ${response.data}');
        throw DataException.customException(LocaleKeys.toastDontAccess.tr());
      }
      else{
        throw DataException.customException(LocaleKeys.toastServiceUnavailable.tr());
      }
    }
    catch(e,stacktrace){
      if (e is DataException) {
        rethrow;
      } else {
        log('get_All_Bike_Exc: $e', stackTrace: stacktrace);
        throw DataException.customException(LocaleKeys.toastServiceUnavailable.tr());
      }
    }
  }


  Future<BikeList?> searchSBM(String vehicleSbmKeyFobNames)  async {
    List<BikeData> bikeList = [];
    Map<String, dynamic> body =
    {
      "filters": {"vehicleSbmKeyFobNames":[vehicleSbmKeyFobNames]},
      "sort": [
        {
          "property": "id",
          "direction": "asc"
        }
      ],
      "data_filters": [

      ]

    };
    try {
      final response = await _ref.read(myBikeApiProvider).searchSBM(pathParam: searchSbmEndPoint, body: body);
      if( response.statusCode == 200){
        if(json.decode(response.data)['data'] != null){
          bikeList = (json.decode(response.data)['data'] as List<dynamic>).map((bike) => BikeData.fromJson(bike)).toList();
          return BikeList(values: bikeList, );
        }
        else{
          return null;
        }
      }else{
        throw DataException.customException(LocaleKeys.toastFailedToSearch.tr());
      }
    }
    catch(e,stacktrace){
      if (e is DataException) {
        rethrow;
      } else {
        log('search_SBM_Exc: $e', stackTrace: stacktrace);
        throw DataException.customException(LocaleKeys.toastFailedToSearch.tr());
      }
    }
  }
}