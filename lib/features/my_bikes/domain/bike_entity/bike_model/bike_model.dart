import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../constants/strings.dart';

part 'bike_model.freezed.dart';



@freezed
class BikeData with _$BikeData{
  const factory BikeData({
    required int id,
    @Default(BIKE_STATE.UNLOCKED) BIKE_STATE bike_state,
    @Default({}) Map<String,dynamic>LastParkedLocation,
    required String name,
    @Default('')  String friendlyName,
    required int tenantId,
    required  String modelName,
    dynamic createdBy,
    dynamic updatedBy,
    dynamic createdAt,
    dynamic updatedAt,
    required  int isActive,
    dynamic statusId,
    required dynamic userMappings,
    required dynamic sbmMappings,
    required String keyfobMappings,
    required  int mappedLocality,
    required int mappedCity,
    required int mappedCountry,
  }) = _BikeData;

  const BikeData._();


  factory BikeData.fromJson(Map<String, dynamic> json) {

    String? friendlyName = null;
    Map userMapping = jsonDecode(json["user_mappings"]);
    userMapping.entries.forEach((entry) {
    Map userTypeElement = entry.value;
    if(Constants.GLOBAL_USER_ID == userTypeElement['user_id']){
      if(userTypeElement.containsKey('functionality') && userTypeElement['functionality'] != null){
        Map friendlyNameMap = userTypeElement['functionality'];
        if(friendlyNameMap.containsKey('friendlyName') && friendlyNameMap['friendlyName'] != null){
          friendlyName = friendlyNameMap['friendlyName'];
        }
      }
    }
    });
      
    return BikeData(
      id: json["id"] ?? 0,
      name: json["name"] ?? '',
      tenantId: json["tenant_id"] ?? 0,
      modelName:  json["model_name"] ?? '',
      friendlyName: json["friendlyName"] ?? friendlyName ??   '',
      createdBy: json["created_by"] ?? '',
      updatedBy: json["updated_by"] ?? '',
      createdAt: json["created_at"] ?? 0,
      updatedAt: json["updated_at"] ?? 0,
      isActive: json["is_active"] != null ? json["is_active"] == true ? 1 : 0 : 0,
      statusId: json["status_id"] ??'',
      userMappings: json["user_mappings"] ?? '',
      sbmMappings: json["sbm_mappings"] ?? '',
      keyfobMappings: json["keyfob_mappings"] ?? '',
      mappedLocality: json["mapped_locality"] ?? 0,
      mappedCity: json["mapped_city"] ?? 0,
      mappedCountry: json["mapped_country"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "friendlyName": friendlyName,
    "tenant_id": tenantId,
    "user_mappings": userMappings,
    "model_name": modelName,
    "created_by": createdBy,
    "updated_by": updatedBy,
    "created_at": createdAt,
    "updated_at": updatedAt,
    "is_active": isActive,
    "status_id": statusId,
    "sbm_mappings": sbmMappings,
    "keyfob_mappings": keyfobMappings,
    "mapped_locality": mappedLocality,
    "mapped_city": mappedCity,
    "mapped_country": mappedCountry,
  };

}

