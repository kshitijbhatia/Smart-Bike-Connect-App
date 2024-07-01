
import 'dart:convert';

AuthenticationModel authenticationModelFromJson(String str) => AuthenticationModel.fromJson(json.decode(str));

String authenticationModelToJson(AuthenticationModel data) => json.encode(data.toJson());

class AuthenticationModel {
  AuthenticationModel({
    required this.data,
  });

  Data data;


  factory AuthenticationModel.fromJson(Map<String, dynamic> json) => AuthenticationModel(
    data: Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "data": data.toJson(),
  };
}

class Data {
  Data({
    required this.isSystemCreated,
    required this.userData,
    required this.appConfig,
    required this.userPermMapping,
    required this.accessToken,
    required this.refreshToken,
  });

  bool isSystemCreated;
  UserData userData;
  AppConfig appConfig;
  List<UserPermMapping> userPermMapping;
  String accessToken;
  String refreshToken;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    isSystemCreated: json["isSystemCreated"] ?? false,
    userData: UserData.fromJson(json["userData"]),
    appConfig: AppConfig.fromJson(json["appConfig"]),
    userPermMapping: List<UserPermMapping>.from(json["userPermMapping"].map((x) => UserPermMapping.fromJson(x))),
    accessToken: json["accessToken"],
    refreshToken: json["refreshToken"],
  );

  Map<String, dynamic> toJson() => {
    "isSystemCreated": isSystemCreated,
    "userData": userData.toJson(),
    "appConfig": appConfig.toJson(),
    "userPermMapping": List<dynamic>.from(userPermMapping.map((x) => x.toJson())),
    "accessToken": accessToken,
    "refreshToken": refreshToken,
  };
}

class AppConfig {
  AppConfig();

  factory AppConfig.fromJson(Map<String, dynamic> json) => AppConfig(
  );

  Map<String, dynamic> toJson() => {
  };
}

class UserData {
  UserData({
    required this.username,
  });

  String username;

  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
    username: json["username"],
  );

  Map<String, dynamic> toJson() => {
    "username": username,
  };
}

class UserPermMapping {
  UserPermMapping({
    required this.roleId,
    this.moduleType,
    required this.parentId,
    required this.allowedAccess,
    required this.name,
    required this.assignedAccess,
    required this.id,
    required this.displayName,
  });

  int roleId;
  String? moduleType;
  int parentId;
  List<EdAccess> allowedAccess;
  String name;
  List<EdAccess> assignedAccess;
  int id;
  String displayName;

  factory UserPermMapping.fromJson(Map<String, dynamic> json) {
    return UserPermMapping(
      roleId: json["role_id"],
      moduleType: json["module_type"] ?? "",
      parentId: json["parent_id"],
      allowedAccess: json["allowed_access"] == null ? [] : List<EdAccess>.from(json["allowed_access"].map((x) => edAccessValues.map[x])),
      name: json["name"],
      assignedAccess: List<EdAccess>.from(json["assigned_access"].map((x) => edAccessValues.map[x]!)),
      id: json["id"],
      displayName: json["display_name"],
    );
  }

  Map<String, dynamic> toJson() => {
    "role_id": roleId,
    "module_type": moduleType,
    "parent_id": parentId,
    "allowed_access": List<dynamic>.from(allowedAccess.map((x) => edAccessValues.reverse[x])),
    "name": name,
    "assigned_access": List<dynamic>.from(assignedAccess.map((x) => edAccessValues.reverse[x])),
    "id": id,
    "display_name": displayName,
  };

  @override
  String toString() {
    return 'UserPermMapping (id: $id name: $name displayName: $displayName moduleType: $moduleType roleId: $roleId parentId: $parentId AllowedAcc : $allowedAccess AssignedAcc : $assignedAccess)';
  }
}

enum EdAccess { VIEW, EDIT, DELETE, CREATE, END, DEALER_ADMIN, DEALER_USER,PRIMARY_USER, SECONDARY_USER,SMARTLINK_USER }

final edAccessValues = EnumValues({
  "CREATE": EdAccess.CREATE,
  "DELETE": EdAccess.DELETE,
  "EDIT": EdAccess.EDIT,
  "END": EdAccess.END,
  "VIEW": EdAccess.VIEW,
  "DEALER_ADMIN" : EdAccess.DEALER_ADMIN,
  "DEALER_USER" : EdAccess.DEALER_USER,
  "PRIMARY_USER" : EdAccess.PRIMARY_USER,
  "SECONDARY_USER" : EdAccess.SECONDARY_USER,
  "SMARTLINK_USER" : EdAccess.SMARTLINK_USER
});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
