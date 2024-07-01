
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartbike_flutter/app_utils/app_utils.dart';
import 'package:smartbike_flutter/constants/strings.dart';
import 'package:smartbike_flutter/features/service/usecase/user_perm_model.dart';

final userPermController = StateNotifierProvider<UserPermController, UserPermModel>((ref) => UserPermController(ref));

class UserPermController extends StateNotifier<UserPermModel> {

  UserPermController(this.ref) : super(const UserPermModelState());

  final Ref ref;

   Future<bool> initPermMapping() async{

     if (await AppUtils.containsKey( key :Constants.USER_ID)) {
       Constants.GLOBAL_USER_ID = (await AppUtils.getInt(key : Constants.USER_ID))!;
     }

    if(await _checkForSuperAdmin()){
      return true;
    }else if(await _checkForDealerAdmin()){
      return true;
    }else if(await _checkForDealerUser()){
      return true;
    }
     _assignAccess(isSmartness: false, isLearnMode: false, isAPrimary: false, isCURDSecondary: false, isCURDSBM: false,
         isBikeAdmin: false,isDealerAdmin: false,isDealerUser: false,isSuperAdmin: false);
    return false;
  }

  Future<bool> _checkForSuperAdmin() async{

    final result = await AppUtils.getBool(key: Constants.SUPER_ADMIN);
    if(await AppUtils.containsKey(key: Constants.SUPER_ADMIN) && result!){
      _assignAccess(isSmartness: true, isLearnMode: true, isAPrimary: true, isCURDSecondary: true, isCURDSBM: true,
                        isBikeAdmin: true,isSuperAdmin: true, isDealerUser: true, isDealerAdmin: true);
      return true;
    }else{
      return false;
    }
  }

  Future<bool> _checkForDealerAdmin() async{

    final result = await AppUtils.getBool(key: Constants.DEALERSHIP_ADMIN);
    if(await AppUtils.containsKey(key: Constants.DEALERSHIP_ADMIN) && result!){
      _assignAccess(isSmartness: true, isLearnMode: true, isAPrimary: true, isCURDSecondary: true, isCURDSBM: true,
                 isBikeAdmin: true,isDealerAdmin: true, isDealerUser: false, isSuperAdmin: false);
    return true;
    }else{
    return false;
    }
  }

  Future<bool> _checkForDealerUser() async{

    final result = await AppUtils.getBool(key: Constants.DEALERSHIP_USER);
    if(await AppUtils.containsKey(key: Constants.DEALERSHIP_USER) && result!){
      _assignAccess(isSmartness: true, isLearnMode: true, isAPrimary: false, isCURDSecondary: true, isCURDSBM: true,
          isBikeAdmin: true,isSuperAdmin: false, isDealerUser: true, isDealerAdmin: false);
      return true;
    }else{
      return false;
    }
  }

  void _assignAccess({required isSmartness, required isLearnMode, required isAPrimary, required isCURDSecondary,
                            required isCURDSBM, required isBikeAdmin,required isSuperAdmin, required isDealerAdmin, required isDealerUser}){

   state = state.copyWith(isSmartnessControl: isSmartness);
   state = state.copyWith(isLearnModeAllowed: isLearnMode);
   state = state.copyWith(isAPrimaryUserAllowed: isAPrimary);
   state = state.copyWith(isCURDSecondaryUserAllowed: isCURDSecondary);
   state = state.copyWith(isCURDSBMAllowed: isCURDSBM);
   state = state.copyWith(isBikeAdminViewAllowed: isBikeAdmin);
   state = state.copyWith(isSuperAdmin: isSuperAdmin);
   state = state.copyWith(isDealerAdmin: isDealerAdmin);
   state = state.copyWith(isDealerUser: isDealerUser);
  }

}