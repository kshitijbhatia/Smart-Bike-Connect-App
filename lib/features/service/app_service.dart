import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartbike_flutter/app_utils/app_utils.dart';
import 'package:smartbike_flutter/features/authentication/data/authentication_repo/authentication_repo.dart';
import 'package:smartbike_flutter/features/my_bikes/data/my_bike_repo/my_bike_repo.dart';
import 'package:smartbike_flutter/features/my_bikes/domain/bike_entity/bike_model/sbm_mapping_model.dart';
import 'package:smartbike_flutter/features/my_bikes/domain/bike_entity/state/bike_list_state.dart';
import 'package:smartbike_flutter/features/settings/data/settings_repo/settings_repo.dart';
import 'package:smartbike_flutter/features/user_management/data/user_management_repo/user_management_repo.dart';
import 'package:smartbike_flutter/features/user_management/domain/user_management_entity/search_user_model.dart';
import 'package:smartbike_flutter/features/user_management/domain/user_management_entity/users_list_model.dart';

import '../../constants/strings.dart';


final applicationService = Provider<ApplicationService>((ref) => ApplicationService(ref));

class ApplicationService {

  final Ref _ref;
  List <int> userIds = [];

  ApplicationService(this._ref);


  Future<BikeList> getAllBikes({ required int start ,required int limit,required String apiEndPoint}) async{
    userIds.add(await AppUtils.getInt(key:Constants.USER_ID) ?? 14);
    final responseList = await _ref.read(myBikeRepoProvider).getBike(userIds: userIds,limit: limit,start: start, apiEndPoint: apiEndPoint );
    return responseList;
  }

  Future<String?> generateOtp({ String? phoneNumber , String? countryCode, String? email}) async{
    final transactionId = await _ref.read(authenticationRepoProvider).generateOTP(phoneNumber: phoneNumber,countryCode: countryCode,email: email);
    return transactionId;
  }
  Future <bool?>  validateOtp({required String otp ,required String txnId}) async{
    final response = await _ref.read(authenticationRepoProvider).validateOtp(otp: otp,txnId: txnId);
    return response;
  }

  Future <List<Users>>  getAllUsers({ required List<int>  userIds}) async{
    final response = await _ref.read(usersRepoProvider).getAllUsers(userIds: userIds);
    return response;
  }

  Future <List<SearchData>>?  searchUser({ required String phoneNumber ,required String countryCode}) async{
    final response = await _ref.read(usersRepoProvider).searchUser(phoneNumber: phoneNumber , countryCode: countryCode);
    return response;
  }

  Future <int?>  createUser({required String phoneNumber ,required String countryCode ,required String userName, required String email,required bool isPrimary}) async{
    final response = await _ref.read(usersRepoProvider).createUser(phoneNumber: phoneNumber , countryCode: countryCode,email: email,userName: userName,isPrimary: isPrimary);
    return response;
  }
  Future <bool>?  vehicleUserMapping({required int vehicleId , required String userType ,required int userId, required String name}) async{
    final response = await _ref.read(usersRepoProvider).vehicleUserMapping(name: name,userId: userId , userType: userType,vehicleId: vehicleId);
    return response;
  }
  Future <int?>  deleteUserMapping({required int vehicleId ,required int userId}) async{
    final response = await _ref.read(usersRepoProvider).deleteUserMapping(userId: userId,vehicleId: vehicleId);
    return response;
  }

  Future  <bool?> logout() async{
    final response = await _ref.read(settingsRepoProvider).logout();
    return response;
  }
  Future<BikeList?>  searchSBM(String vehicleSbmKeyFobNames) async{
    final response = await _ref.read(myBikeRepoProvider).searchSBM(vehicleSbmKeyFobNames);
    return response;
  }
  Future<bool?>  deleteSBMVehicleMapping({required int vehicleId ,required int sbmId}) async{
    final response = await _ref.read(settingsRepoProvider).deleteSBMVehicleMapping(sbmId: sbmId,vehicleId: vehicleId);
    return response;
  }

  Future<bool> uploadFirmwareVersion({required int sbmId, required String firmwareVersion}) async{
    final response = await _ref.read(settingsRepoProvider).updateSBMFunctionality(sbm_id: sbmId,firmwareVersion: firmwareVersion,immobilisation: true);
    return response;
  }

  Future<bool> uploadSmartnessValue({required int sbmId, required bool  immobilisation}) async{
    final response = await _ref.read(settingsRepoProvider).updateSBMFunctionality(sbm_id: sbmId,immobilisation: immobilisation, firmwareVersion: '');
    return response;
  }

  Future  <List<SbmMapping>> getSBMId({required String barCode, required int vehicleId}) async{
    final response = await _ref.read(settingsRepoProvider).getSBMId(barCode: barCode ,vehicleId: vehicleId );
    return response;
  }
  Future <bool?>  editProfile({required String name, required String email ,required String phoneNumber, required int countryCode ,required int userId}) async{
    final response = await _ref.read(settingsRepoProvider).editProfile(name: name,email: email ,phoneNumber: phoneNumber ,countryCode: countryCode, userId: userId);
    return response;
  }
  Future<bool?> editBikeName({required int vehicleId ,required int userId , required String updatedBikeName}) async{
    final response = await _ref.read(settingsRepoProvider).editBikeName(vehicleId: vehicleId , userId: userId ,updatedBikeName: updatedBikeName);
    return response;
  }

  Future<bool> downloadZIPFile({required String fileName, required String filePath}) async{
    final response = await _ref.read(settingsRepoProvider).downloadZIP(fileName: fileName,filePath: filePath);
    return response;
  }


}

