import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartbike_flutter/features/authentication/domain/state/field.dart';
import 'package:smartbike_flutter/features/authentication/domain/state/login_entity.dart';
import 'package:smartbike_flutter/features/authentication/domain/state/login_form.dart';
import 'package:smartbike_flutter/features/service/app_service.dart';
import 'package:smartbike_flutter/features/user_management/domain/state/user_list_state.dart';
import 'package:smartbike_flutter/features/user_management/domain/user_management_entity/search_user_model.dart';
import 'package:smartbike_flutter/widgets/toast.dart';

final userListProvider = StateNotifierProvider.family.autoDispose<UserProviderClass, AsyncValue<UsersList>, List<int>>((ref, userIds) {
  return UserProviderClass(ref, userIds);
});

bool isApiCallTracker = false;

class UserProviderClass extends StateNotifier<AsyncValue<UsersList>> {
  final Ref _ref;
  final List<int> _userIdList;

  UserProviderClass(this._ref, this._userIdList) : super(const AsyncValue.loading()) {
    if (!isApiCallTracker) {
      isApiCallTracker = true;
      getAllUsers(_userIdList);
    }
  }

  getAllUsers(List<int> userIdList) async {
    try{
      //log('userIdList ${_userIdList}');
      if (_userIdList.length == 0) {
        //state = await AsyncValue.loading();
        state = await AsyncValue.data(UsersList(values: []));
        //log('users_list_is_cleared');
      } else {
        try {
          // state = await AsyncValue.data(UsersList(values: []));
          state = await AsyncValue.loading();
          final usersData = await _ref.read(applicationService).getAllUsers(userIds: userIdList);
          if (mounted) {
            state = await AsyncValue.data(UsersList(values: usersData));
            //log('user_list_provider_mounted');
          } else {
            //log('user_list_provider_not_mounted');
          }

          //log('returnedUserListData $usersData');
        } catch (e, stacktrace) {
            log('user_list_exc ${e.toString()}',stackTrace: stacktrace);
          state = AsyncValue.error(e, stacktrace);
        }
      }
    }catch(e,stacktrace){
      log('user_list_exc ${e.toString()}',stackTrace: stacktrace);
    }
  }

  @override
  void dispose() {
    //log('user_list_controller_disposed******************************************************************************************************');
    super.dispose();
    isApiCallTracker = false;
  }
}

final userProvider = StateNotifierProvider<UserController, LoginForm>(
    (ref) => UserController(ref));

class UserController extends StateNotifier<LoginForm> {
  final Ref ref;
  UserController(this.ref) : super(LoginForm(LoginEntity.empty()));

  late LoginEntity _form;
  List<SearchData> searchList = [];

  /*=========================================search User===================================*/

  Future<List<SearchData>?> searchUser(
      {required String phoneNumber, required String countryCode}) async {
    try {
      searchList.clear();
      var response = await ref.read(applicationService).searchUser(phoneNumber: phoneNumber, countryCode: countryCode);
      searchList = response!;
      return searchList;
    } catch (e) {
      showToast(e.toString(), warning: true, duration: true);
      return null;
    }
  }

  /*=========================================create User===================================*/

  Future<int?> createUser({required String phoneNumber, required String countryCode, required String userName, required String email, required bool isPrimary}) async {
    try {
      int? userId = await ref.read(applicationService).createUser(phoneNumber: phoneNumber, countryCode: countryCode, email: email, userName: userName, isPrimary: isPrimary);
      return userId;
    } catch (e) {
      showToast(e.toString(), warning: true, duration: true);
      return null;
    }
  }
  /*========================================vehicle User Mapping===================================*/

  Future<bool?> vehicleUserMapping({required int vehicleId, required String userType, required int userId, required String name}) async {
    try {
      bool? result = await ref.read(applicationService).vehicleUserMapping(name: name, userId: userId, userType: userType, vehicleId: vehicleId);
      return result;
    } catch (e) {
      showToast(e.toString(), warning: true, duration: true);
      return false;
    }
  }
  /*========================================delete User Mapping==================================*/

  Future<int?> deleteUserMapping({required int vehicleId, required int userId}) async {
    try {
      int? id = await ref.read(applicationService).deleteUserMapping(userId: userId, vehicleId: vehicleId);
      return id;
    } catch (e) {
      showToast(e.toString(), warning: true, duration: true);
      return null;
    }
  }
  /*==========================================form validation===================================*/

  setSearchUser(String phone,) {
    _form = state.formState.copyWith(phoneNumber: Field(value: phone));
    late Field phoneNumber;
    if (phone.trim().length < 6) {
      phoneNumber = _form.phoneNumber.copyWith(isColor: false, buttonColor: [Colors.grey, Colors.grey]);
    } else {
      phoneNumber = _form.phoneNumber.copyWith(isColor: true, buttonColor: [
        const Color.fromRGBO(47, 64, 126, 1.0),
        const Color.fromRGBO(109, 69, 194, 1.0)
      ]);
    }
    state = state.copyWith(formState: _form.copyWith(phoneNumber: phoneNumber));
  }

  setAddUser({String? phoneNumber, required String emailText, required String name}) {
    final isEmail = RegExp(r'^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$').hasMatch(emailText);
    _form = state.formState.copyWith(Email: Field(value: emailText,));
    late Field validateField;
    if (phoneNumber!.trim().length < 6 || isEmail == false || name.trim().isEmpty) {
      validateField = _form.Email.copyWith(isColor: false, buttonColor: [Colors.grey, Colors.grey]);
    } else {
      validateField = _form.Email.copyWith(isColor: true, buttonColor: [
        const Color.fromRGBO(47, 64, 126, 1.0),
        const Color.fromRGBO(109, 69, 194, 1.0)
      ]);
    }
    state = state.copyWith(formState: _form.copyWith(Email: validateField));
  }

  /*==========================================set Country Code===================================*/

  setCountryCode(String countryCode,) {
    _form = state.formState.copyWith(countryCode: Field(value: countryCode));
    late Field code;
    code = _form.countryCode.copyWith(countryCode: countryCode,);
    state = state.copyWith(formState: _form.copyWith(countryCode: code));
  }
}
