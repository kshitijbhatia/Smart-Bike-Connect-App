import 'dart:convert';

SearchUserModel searchUserModelFromJson(String str) => SearchUserModel.fromJson(json.decode(str));

String searchUserModelToJson(SearchUserModel data) => json.encode(data.toJson());

class SearchUserModel {
  String status;
  int statusCode;
  List<SearchData> data;
  int dataCount;
  String message;

  SearchUserModel({
    required this.status,
    required this.statusCode,
    required this.data,
    required this.dataCount,
    required this.message,
  });

  factory SearchUserModel.fromJson(Map<String, dynamic> json) => SearchUserModel(
    status: json["status"] ?? '',
    statusCode: json["statusCode"],
    data: List<SearchData>.from(json["data"].map((x) => SearchData.fromJson(x))),
    dataCount: json["dataCount"],
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "statusCode": statusCode,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "dataCount": dataCount,
    "message": message,
  };
}

class SearchData {
  int id;
  String email;
  dynamic address;
  int version;
  String username;
  int isActive;
  int isTenant;
  String lastName;
  String firstName;
  int usertypeId;
  int countryCode;
  int contactNumber;
  int isFirstLogin;
  int invalidLoginCount;
  List<ExistingCred> existingCreds;

  SearchData({
    required this.id,
    required this.email,
    this.address,
    required this.version,
    required this.username,
    required this.isActive,
    required this.isTenant,
    required this.lastName,
    required this.firstName,
    required this.usertypeId,
    required this.countryCode,
    required this.contactNumber,
    required this.isFirstLogin,
    required this.invalidLoginCount,
    required this.existingCreds,
  });

  factory SearchData.fromJson(Map<String, dynamic> json) => SearchData(
    id: json["id"] ?? 0,
    email: json["email"] ?? '',
    address: json["address"] ?? '',
    version: json["version"] ?? 1,
    username: json["username"] ?? '',
    isActive: json["is_active"] != null ? json["is_active"] == true ? 1 : 0 : 0,
    isTenant: json["is_tenant"] ?? 0,
    lastName: json["last_name"] ?? '',
    firstName: json["first_name"] ?? '',
    usertypeId: json["usertype_id"] ?? 0,
    countryCode: json["country_code"] ?? 91,
    contactNumber: json["contact_number"] ?? 0,
    isFirstLogin: json["is_first_login"] ?? 0,
    invalidLoginCount: json["invalid_login_count"] ?? 0,
    existingCreds: List<ExistingCred>.from(json["existingCreds"].map((x) => ExistingCred.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "email": email,
    "address": address,
    "version": version,
    "username": username,
    "is_active": isActive,
    "is_tenant": isTenant,
    "last_name": lastName,
    "first_name": firstName,
    "usertype_id": usertypeId,
    "country_code": countryCode,
    "contact_number": contactNumber,
    "is_first_login": isFirstLogin,
    "invalid_login_count": invalidLoginCount,
    "existingCreds": List<dynamic>.from(existingCreds.map((x) => x.toJson())),
  };
}

class ExistingCred {
  String deviceId;
  int contactNumber;

  ExistingCred({
    required this.deviceId,
    required this.contactNumber,
  });

  factory ExistingCred.fromJson(Map<String, dynamic> json) => ExistingCred(
    deviceId: json["device_id"] ?? '',
    contactNumber: json["contact_number"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "device_id": deviceId,
    "contact_number": contactNumber,
  };
}