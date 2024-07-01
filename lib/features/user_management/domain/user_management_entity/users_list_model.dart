
class UsersListModel {
  bool success;
  List<Users> data;
  int dataCount;

  UsersListModel({
    required this.success,
    required this.data,
    required this.dataCount,
  });

  factory UsersListModel.fromJson(Map<String, dynamic> json) => UsersListModel(
    success: json["success"],
    data: List<Users>.from(json["data"].map((x) => Users.fromJson(x))),
    dataCount: json["dataCount"],
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "dataCount": dataCount,
  };
}

class Users {

  List<UserData> userData;
  List<UserGroupDatumElement> userRoleData;
  List<UserGroupDatumElement> userGroupData;

  Users({
    required this.userData,
    required this.userRoleData,
    required this.userGroupData,
  });

  factory Users.fromJson(Map<String, dynamic> json) => Users(
    userData: List<UserData>.from(json["userData"].map((x) => UserData.fromJson(x))),
    userRoleData: List<UserGroupDatumElement>.from(json["userRoleData"].map((x) => UserGroupDatumElement.fromJson(x))),
    userGroupData: List<UserGroupDatumElement>.from(json["userGroupData"].map((x) => UserGroupDatumElement.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "userData": List<dynamic>.from(userData.map((x) => x.toJson())),
    "userRoleData": List<dynamic>.from(userRoleData.map((x) => x.toJson())),
    "userGroupData": List<dynamic>.from(userGroupData.map((x) => x.toJson())),
  };

  @override
  String toString() {
    return 'Users{userData: $userData, userRoleData: $userRoleData, userGroupData: $userGroupData}';
  }
}

class UserData {
  int id;
  String username;
  String email;
  String userHash;
  dynamic address;
  int contactNumber;
  int countryCode;
  int usertypeId;
  String firstName;
  String lastName;
  String createdBy;
 dynamic createdOn;
  int version;

  UserData({
    required this.id,
    required this.username,
    required this.email,
    required this.userHash,
    this.address,
    required this.contactNumber,
    required this.countryCode,
    required this.usertypeId,
    required this.firstName,
    required this.lastName,
    required this.createdBy,
    required this.createdOn,
    required this.version,

  });

  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
    id: json["id"] ,
    username: json["username"] ??'',
    email: json["email"] ??"",
    userHash: json["user_hash"] ??"",
    address: json["address"] ??"",
    contactNumber: json["contact_number"] ,
    countryCode: json["country_code"],
    usertypeId: json["usertype_id"],
    firstName: json["first_name"] ??"",
    lastName: json["last_name"] ?? "",
    createdBy: json["created_by"] ?? '',
   createdOn: json["created_on"] ??'',
    version: json["version"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "username": username,
    "email": email,
    "user_hash": userHash,
    "address": address,
    "contact_number": contactNumber,
    "country_code": countryCode,
    "usertype_id": usertypeId,
    "first_name": firstName,
    "last_name": lastName,
    "created_by": createdBy,
    "created_on": createdOn,
    "version": version,
  };

  @override
  String toString() {
    return 'UserData{id: $id, username: $username, email: $email, userHash: $userHash, address: $address, contactNumber: $contactNumber, countryCode: $countryCode, usertypeId: $usertypeId, firstName: $firstName, lastName: $lastName, createdBy: $createdBy, createdOn: $createdOn, version: $version}';
  }
}

class UserGroupDatumElement {
  var id;
  var name;
  var description;

  UserGroupDatumElement({
    required this.id,
    required this.name,
    required this.description,
  });

  factory UserGroupDatumElement.fromJson(Map<String, dynamic> json) => UserGroupDatumElement(
    id: json["id"],
    name: json["name"],
    description: json["description"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "description": description,
  };

  @override
  String toString() {
    return 'UserGroupDatumElement{id: $id, name: $name, description: $description}';
  }
}
