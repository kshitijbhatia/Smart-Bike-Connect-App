



import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartbike_flutter/features/my_bikes/data/my_bike_data_source/my_bike_api.dart';
import 'package:smartbike_flutter/network/exception.dart';
import 'package:smartbike_flutter/network/network_provider.dart';


final myBikeApiProvider = Provider<MyBike>((ref) => BikeAPIImpl(ref));

class BikeAPIImpl implements MyBike{

  final Ref _ref;

  BikeAPIImpl(this._ref);

  @override
  Future<Response> getBike({required String pathParam ,required Map<String, dynamic> body,required Map<String, dynamic> headers}) async {
    try {
      final response = await _ref.read(clientProvider).post( pathParam ,data: body,options: Options(headers: headers));
      return response;
    } on DioError catch (error) {
      debugPrint('******exc_get_bike $error');
      throw DataException.fromDioError(error);
    }
  }

  @override
  Future<Response> searchSBM({required String pathParam,required Map<String, dynamic> body}) async {
    try {
      final response = await _ref.read(clientProvider).post( pathParam ,data: body);
      return response;
    } on DioError catch (error) {
      debugPrint('******exc_search_SBM $error');
      throw DataException.fromDioError(error);
    }
  }



}