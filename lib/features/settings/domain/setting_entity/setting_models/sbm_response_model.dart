import 'dart:convert';

SbmModel sbmModelFromJson(String str) => SbmModel.fromJson(json.decode(str));

String sbmModelToJson(SbmModel data) => json.encode(data.toJson());

class SbmModel {
  String status;
  int statusCode;
  List<Sbmdata> sbmData;
  int dataCount;
  String message;

  SbmModel({
    required this.status,
    required this.statusCode,
    required this.sbmData,
    required this.dataCount,
    required this.message,
  });

  factory SbmModel.fromJson(Map<String, dynamic> json) => SbmModel(
    status: json["status"],
    statusCode: json["statusCode"],
    sbmData: List<Sbmdata>.from(json["sbmData"].map((x) => Sbmdata.fromJson(x))),
    dataCount: json["dataCount"],
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "statusCode": statusCode,
    "sbmdata": List<dynamic>.from(sbmData.map((x) => x.toJson())),
    "dataCount": dataCount,
    "message": message,
  };
}

class Sbmdata {
  String sbmBarcode;
  int sbmId;
  String hwVer;
  String swVer;
  String macAddress;
  String functionality;
  dynamic dateOfMapping;
  int vehicleId;
  String vin;
  String keyfobsMapped;

  Sbmdata({
    required this.sbmBarcode,
    required this.sbmId,
    required this.hwVer,
    required this.swVer,
    required this.macAddress,
    required this.functionality,
    this.dateOfMapping,
    required this.vehicleId,
    required this.vin,
    required this.keyfobsMapped,
  });

  factory Sbmdata.fromJson(Map<String, dynamic> json) => Sbmdata(
    sbmBarcode: json["sbm_barcode"],
    sbmId: json["sbm_id"],
    hwVer: json["hw_ver"],
    swVer: json["sw_ver"],
    macAddress: json["mac_address"],
    functionality: json["functionality"],
    dateOfMapping: json["date_of_mapping"],
    vehicleId: json["vehicle_id"],
    vin: json["vin"],
    keyfobsMapped: json["keyfobs_mapped"],
  );

  Map<String, dynamic> toJson() => {
    "sbm_barcode": sbmBarcode,
    "sbm_id": sbmId,
    "hw_ver": hwVer,
    "sw_ver": swVer,
    "mac_address": macAddress,
    "functionality": functionality,
    "date_of_mapping": dateOfMapping,
    "vehicle_id": vehicleId,
    "vin": vin,
    "keyfobs_mapped": keyfobsMapped,
  };
}
