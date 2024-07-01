import 'dart:convert';
import 'dart:developer';

import 'package:country_picker/country_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartbike_flutter/constants/app_colors.dart';
import 'package:smartbike_flutter/constants/assets.dart';
import 'package:smartbike_flutter/constants/strings.dart';
import 'package:smartbike_flutter/features/my_bikes/domain/bike_entity/bike_model/bike_model.dart';
import 'package:smartbike_flutter/features/user_management/domain/state/user_list_state.dart';
import 'package:smartbike_flutter/features/user_management/domain/user_management_entity/search_user_model.dart';
import 'package:smartbike_flutter/features/user_management/domain/user_management_entity/users_list_model.dart';
import 'package:smartbike_flutter/features/user_management/presentation/controllers/user_management_controller.dart';
import 'package:smartbike_flutter/generated/locale_keys.g.dart';
import 'package:smartbike_flutter/widgets/common_ui_methods.dart';
import 'package:smartbike_flutter/widgets/custom_loader_dialogs.dart';
import 'package:smartbike_flutter/widgets/toast.dart';

import '../../../../main.dart';
import '../../../../widgets/circular_progress_indicatior.dart';
import '../../../service/user_perm_controller.dart';

class UsersListScreen extends ConsumerStatefulWidget {
  UsersListScreen();

  @override
  ConsumerState<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends ConsumerState<UsersListScreen> {
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController numberController = TextEditingController();
  String userType = '';
  List<int> userIdList = [];
  UserData? primaryUser;
  late BikeData bikeData;
  late SharedPreferences sharedPreferences;

  @override
  void initState() {
    super.initState();
    sharedPreferences = ref.read(sharedPreferencesProvider);
    _fetchUserType();
  }

  /*=================================================fetch User Type==============================================*/
  List<int> _fetchUserType() {
    userIdList = [];
    userType = '';
    bool userTypeAdded = false;
    String? data = sharedPreferences.getString(Constants.SELECTED_BIKE_META);
    bikeData = BikeData.fromJson(json.decode(data!));
    if (bikeData.userMappings.toString().isNotEmpty) {
      var keysList = ['primary', 'secondary', 'tertiary'];
      Map userMapping = jsonDecode(bikeData.userMappings);
      for (int i = 0; i < keysList.length; i++) {
        Map userTypeElement = userMapping[keysList[i]];
        if (userTypeElement['user_id'] != null) {
          userIdList.add(userTypeElement['user_id']);
        } else if (!userTypeAdded) {
          userType = keysList[i];
          userTypeAdded = true;
        }
      }
      log('user_ids ${userIdList} || ${userType}');
    }
    return userIdList;
  }

  List<int> _updateBikeMeta({required userId, required bool toAdd, String? userType}) {
    String? savedBikeMeta = sharedPreferences.getString(Constants.SELECTED_BIKE_META);
    BikeData bikeData = BikeData.fromJson(json.decode(savedBikeMeta!));
    Map userMapping = jsonDecode(bikeData.userMappings);
    Map userTypeElement = {};

    if(toAdd){

      userTypeElement = userMapping[userType];
      userTypeElement['user_id'] = userId;
      userMapping[userType] = userTypeElement;

    }else{

      for (final entry in userMapping.entries) {
        Map userTypeElement = entry.value;
        if(userId == userTypeElement['user_id']){
          userTypeElement['user_id'] = null;
          userMapping[entry.key] = userTypeElement;
          break;
        }
      }
    }

    BikeData updatedBikeData =  bikeData.copyWith(userMappings: jsonEncode(userMapping));
    sharedPreferences.setString(Constants.SELECTED_BIKE_META,json.encode(updatedBikeData));
    return  _fetchUserType();
  }

/*===============================================_extract Primary User===========================================*/

  UsersList _extractPrimaryUser(UsersList usersList){

    List<Users> secondaryUsersList = List.from(usersList.values);

    if (bikeData.userMappings.toString().isNotEmpty) {
      Map map = jsonDecode(bikeData.userMappings);
      Map userTypePrimary = map['primary'];

      for(int i = 0; i < secondaryUsersList.length ; i++){
        final Users users = secondaryUsersList[i];

        //TODO handle this if primary_user_id can be null.
        if(userTypePrimary['user_id'] == users.userData.elementAt(0).id){
          primaryUser = users.userData.elementAt(0);
          secondaryUsersList.removeAt(i);
          break;
        }
      }

      usersList = UsersList(values: secondaryUsersList);
    }
    return usersList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      body: bodyView(),
    );
  }

/*================================================= body View===============================================*/

  Widget bodyView() {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        final _isCurdSBMAllowed = ref.watch(userPermController.select((value) => value.isCURDSBMAllowed));
        log('build_users_list');
        if(userIdList.isEmpty){
          ref.watch(userListProvider(userIdList));
          return _subBodyView(isCurdSBMAllowed: _isCurdSBMAllowed, usersList: UsersList(values: []),modifiedUsersList: UsersList(values: []));
        }else {
          return ref.watch(userListProvider(userIdList)).when(
            skipLoadingOnRefresh: false,
            loading: () => _loadingState(),
            error: (error, _) => buildErrorWidget(error),
            data: (usersList) {
              if (usersList.length == 0) {
                return _loadingState();
              } else {
                final _modifiedUsersList = _extractPrimaryUser(usersList);
                return _subBodyView(isCurdSBMAllowed: _isCurdSBMAllowed, usersList: usersList,modifiedUsersList: _modifiedUsersList);
              }
            },
          );
        }
      },
    );
  }

  /*===========================================loading State========================================*/


  Widget _subBodyView({required bool isCurdSBMAllowed, required UsersList usersList, required UsersList modifiedUsersList}){
    return Container(
      padding: EdgeInsets.only(top: 20.h, left: 20.w, right: 20.w),
      margin: EdgeInsets.only(
          top: 20.h, bottom: 15.h, left: 20.h, right: 20.w),
      decoration: BoxDecoration(
          color: Colors.white54,
          boxShadow: [
            BoxShadow(color: const Color.fromRGBO(232, 239, 251, 1.0).withOpacity(0.5), spreadRadius: 6, blurRadius: 2.0),],
          borderRadius: BorderRadius.circular(10.r)),
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          headingText(gradientColor: [
            Color.fromRGBO(47, 64, 126, 1.0),
            Color.fromRGBO(47, 64, 126, 1.0)
          ],
              title: LocaleKeys.keyUsers.tr(),
              fontWeight: FontWeight.w800),
          Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
              return primaryUser != null ? _primaryUser(primaryUser!)
                  : Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    10.ph,
                    Align(
                      alignment: Alignment.topLeft,
                      child: headingText(
                          fontSize: 16.sp,
                          gradientColor: [
                            Color.fromRGBO(91, 68, 174, 1.0),
                            Color.fromRGBO(49, 222, 149, 1.0)
                          ],
                          title: LocaleKeys.keyPrimaryUser.tr()),
                    ),
                  15.ph,
                    Visibility(
                        visible: isCurdSBMAllowed,
                        replacement: noUserAssignedText(),
                        child: addPrimaryUserButton()),
                    15.ph,
                    Divider(
                      color: greyBoldColor,
                      thickness: 0.5.h,
                    ),
                ],
              );
            },
          ),
          Visibility(
            visible: modifiedUsersList.length != 0,
            child: Flexible(
              child: Consumer(
                builder: (BuildContext context, WidgetRef ref,
                    Widget? child) {
                  final userController = ref.watch(userProvider.notifier);
                  final curdSecondaryAllowed = ref.watch(userPermController.select((value) => value.isCURDSecondaryUserAllowed));
                  return Theme(
                    data: Theme.of(context).copyWith(
                        dividerColor: Colors.transparent),
                    child: ListTileTheme(
                      dense: true,
                      child: ExpansionTile(
                        initiallyExpanded: true,
                        childrenPadding: EdgeInsets.zero,
                        tilePadding: EdgeInsets.zero,
                        title: headingText(
                            fontSize: 16.sp,
                            gradientColor: [
                              Color.fromRGBO(111, 145, 178, 1.0),
                              Color.fromRGBO(57, 79, 98, 1.0)
                            ],
                            title: LocaleKeys.keySecondaryUsers.tr()),
                        trailing: Image.asset(icDownArrow, scale: 2.4.h,),
                        children: <Widget>[
                          ListView.builder(
                            padding: EdgeInsets.zero,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: modifiedUsersList.length,
                            shrinkWrap: true,
                            itemBuilder: (BuildContext context, int innerIndex) {
                              Users user = modifiedUsersList[innerIndex];
                              return secondaryUsersList(
                                  userData: user.userData.elementAt(0),
                                  visibility: curdSecondaryAllowed || (primaryUser != null && primaryUser?.id == Constants.GLOBAL_USER_ID),
                                  onTap: () async {
                                    appCommonDialog(
                                        context: context, title: LocaleKeys.keyDelete.tr(),
                                        descriptionText: LocaleKeys.keyDeleteUserDes.tr(),
                                        onTap: () async {
                                          Navigator.pop(context);
                                          CustomLoaderDialog.buildShowDialog(context);
                                          int? userId = await userController.deleteUserMapping(vehicleId: bikeData.id, userId: user.userData.elementAt(0).id);
                                          if (mounted) Navigator.pop(CustomLoaderDialog.dialogContext);
                                          if (userId != null) {
                                            final _updatedList = _updateBikeMeta(userId: userId, toAdd: false);
                                            ref.invalidate(userListProvider);
                                            //ref.refresh(userListProvider(_updatedList));
                                            ref.watch(userListProvider(_updatedList));
                                            //await ref.watch(userListProvider( _updatedList).notifier).getAllUsers(userIdList);
                                          }
                                        });
                                  });
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          15.ph,
          addUserButton(usersList),
          15.ph,
        ],
      ),
    );
  }


  Widget _loadingState(){
    return Container(
      alignment: Alignment.center,
      height: MediaQuery.of(context).size.height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const ProgressIndicatorView(),
          10.ph,
          text(title: LocaleKeys.keyLoadingUsers.tr() ,textAlign: TextAlign.center, fontSize: 20.sp, fontWeight: FontWeight.w500, color: blueColor)
        ],
      ),
    );
  }

  /*==============================================add Primary User Button=======================================*/

  Widget addPrimaryUserButton() {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        final userController = ref.watch(userProvider.notifier);
        return commonButton(
            buttonText: LocaleKeys.keyAddPrimaryUser.tr(),
            onTap: () {
              phoneNumberController.clear();
              nameController.clear();
              emailController.clear();
              numberController.clear();
              userController.setSearchUser('');
              userController.setCountryCode('91');
              userController.setAddUser(name: '', phoneNumber: '', emailText: '');
              addUserBottomSheetView(child: checkStatusView(isPrimaryUser: true), height: MediaQuery.of(context).size.height / 1.4.h, buttonText: true);
            },
            buttonColor: [
              const Color.fromRGBO(47, 64, 126, 1.0),
              const Color.fromRGBO(109, 69, 194, 1.0)
            ],
            isIconButton: true,
            buttonImage: icPlus,
            fontWeight: FontWeight.w800);
      },
    );
  }

  /*===============================================no User Assigned Text===========================================*/

  Widget noUserAssignedText(){
    return text(title: LocaleKeys.keyNoPrimaryUser.tr(),fontSize: 16.sp, fontWeight: FontWeight.w500,color: blackColor);
  }

  /*============================================_primary User=========================================*/

  Widget _primaryUser(UserData userData) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        final _isCurdSBMAllowed = ref.watch(userPermController.select((value) => value.isCURDSBMAllowed));
        return Column(
          children: <Widget>[
            7.ph,
            Align(
              alignment: Alignment.topLeft,
              child: headingText(
                  fontSize: 16.sp,
                  gradientColor: [
                    Color.fromRGBO(91, 68, 174, 1.0),
                    Color.fromRGBO(49, 222, 149, 1.0)
                  ],
                  title: LocaleKeys.keyPrimaryUser.tr()),
            ),
            5.ph,
            userDetailsView(
              isIcon: true,
              child: Visibility(
                  visible: _isCurdSBMAllowed,
                  child: InkWell(
                      onTap: () async {
                        appCommonDialog(
                            context: context,
                            title: LocaleKeys.keyDelete.tr(),
                            descriptionText: LocaleKeys.keyDeleteUserDes.tr(),
                            onTap: () async {
                              Navigator.pop(context);
                              CustomLoaderDialog.buildShowDialog(context);
                              int? userId = await ref.watch(userProvider.notifier).deleteUserMapping(vehicleId: bikeData.id, userId: primaryUser!.id);
                              if (mounted) Navigator.pop(CustomLoaderDialog.dialogContext);
                              if (userId != null) {
                                final _updatedList = _updateBikeMeta(userId: userId, toAdd: false);
                                primaryUser = null;
                                ref.invalidate(userListProvider);
                                await ref.watch(userListProvider(_updatedList));
                              }
                            });
                      },
                      child: Padding(
                        padding: EdgeInsets.only(top: 4.h),
                        child: Image.asset(icDelete, scale: 3.h),
                      ))),
              name: '${userData.firstName} ${userData.lastName}',
              phoneNumber: '${userData.contactNumber}',
              email: '${userData.email}',
            ),
          ],
        );
      },
    );
  }

  /*==============================================secondary User List========================================*/

  Widget secondaryUsersList({required UserData userData ,Function? onTap, bool? visibility}) {
    return userDetailsView(
      isIcon: true,
      child: Visibility(
          visible: visibility!,
          child: InkWell(
              onTap: (){
                if(onTap != null){
                  onTap();
                }
              },
              child: Padding(
                padding: EdgeInsets.only(top: 4.h),
                child: Image.asset(icDelete,scale: 3.h),
              ))),
      isDivider: false,
      name: '${userData.firstName} ${userData.lastName}',
      phoneNumber: '${userData.contactNumber}',
      email: '${userData.email}',
    );
  }

  /*===============================================add User Button==============================================*/

  Widget addUserButton(UsersList userData) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        final userController = ref.watch(userProvider.notifier);
        final curdSecondaryAllowed = ref.watch(userPermController.select((value) => value.isCURDSecondaryUserAllowed));
        log('addUserButton $curdSecondaryAllowed | ${primaryUser?.id} | ${Constants.GLOBAL_USER_ID} | ${userData.length} | $userType');
        return Visibility(
          visible:  (((curdSecondaryAllowed || primaryUser?.id == Constants.GLOBAL_USER_ID) && userData.length < 3 ) && userType != '' && primaryUser != null),
          child: commonButton(
              buttonText: LocaleKeys.keyAddUser.tr(),
              onTap: () {
                phoneNumberController.clear();
                nameController.clear();
                emailController.clear();
                numberController.clear();
                userController.setSearchUser('');
                userController.setCountryCode('91');
                userController.setAddUser(name: '', phoneNumber: '', emailText: '');
                 addUserBottomSheetView(child: checkStatusView(),height: MediaQuery.of(context).size.height/1.4.h);
              },
              buttonColor: [
                const Color.fromRGBO(47, 64, 126, 1.0),
                const Color.fromRGBO(109, 69, 194, 1.0)
              ],
              isIconButton: true,
              buttonImage: icPlus,
              fontWeight: FontWeight.w800),
        );
      },
    );
  }

  /*=========================================check status view================================================*/

  Widget checkStatusView({bool isPrimaryUser = false}) {
    return Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) {
      final userController = ref.watch(userProvider.notifier);
      var countryCode = ref.watch(userProvider
          .select((value) => value.formState.countryCode.countryCode));
      return Column(
        children: [
          textFormField(
            textInputAction: TextInputAction.done,
            hintText: LocaleKeys.keyEnterPhone.tr(),
            controller: phoneNumberController,
            maxLength: 12,
            suffixOnTab: (){
              phoneNumberController.clear();
              userController.setSearchUser('');
            },
            onChanged: (value) {
              userController.setSearchUser(value);
            },
            prefixIcon: InkWell(
              onTap: () {
                showCountryPicker(
                  favorite: ['IN'],
                  context: context,
                  showPhoneCode: true,
                  onSelect: (Country country) {
                    userController.setCountryCode(country.phoneCode);
                  },
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  10.pw,
                  Padding(
                    padding: EdgeInsets.only(top: 2.h),
                    child: text(
                        title: '+$countryCode',
                        color: blackColor,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400),
                  ),
                  6.pw,
                  Container(
                      height: 40.h,
                      width: 3.h,
                      child: VerticalDivider(
                        color: greyEsColor,
                        thickness: 2,
                        indent: 4.h,
                        endIndent: 4.h,
                      )),
                  6.pw,
                ],
              ),
            ),
          ),
          20.ph,
          commonButton(
              fontWeight: FontWeight.w800,
              buttonColor: ref.watch(userProvider.select((value) => value.formState.phoneNumber.buttonColor)),
              buttonText: LocaleKeys.keyCheckStatus.tr(),
              onTap: ref.watch(userProvider.select((value) => value.formState.phoneNumber.isColor == false)) ? () {}
                  : () async {
                      FocusScope.of(context).requestFocus(FocusNode());
                      CustomLoaderDialog.buildShowDialog(context);
                      var response = await userController.searchUser(phoneNumber: phoneNumberController.text.trim(), countryCode: countryCode);
                      if (mounted)
                        Navigator.pop(CustomLoaderDialog.dialogContext);
                        Navigator.pop(context);
                      if (userController.searchList.length != 0) {
                        if (userIdList.contains(userController.searchList[0].id)) {
                          showToast(LocaleKeys.toastUserAlreadyAdded.tr());
                          return;
                        }
                      }
                      if (response != null) {
                        if (response.length == 0) {
                          numberController.text = phoneNumberController.text.trim();
                          addUserBottomSheetView(
                              child: userNotFoundView(isPrimaryUser: isPrimaryUser), height: MediaQuery.of(context).size.height / 1.h, buttonText: isPrimaryUser);
                        } else {
                          addUserBottomSheetView(
                              child: userFoundView(isPrimaryUser: isPrimaryUser), buttonText: isPrimaryUser);
                        }
                      }
                    })
        ],
      );
    });
  }

  /*=========================================user Found View================================================*/

  Widget userFoundView({bool isPrimaryUser = false}) {
    return Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) {
      final userMController = ref.watch(userProvider.notifier);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          headingText(
              fontSize: 16.sp,
              gradientColor: [
                Color.fromRGBO(111, 145, 178, 1.0),
                Color.fromRGBO(57, 79, 98, 1.0)
              ],
              title: LocaleKeys.keyUserFound.tr()),
          20.ph,
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: userMController.searchList.length,
            itemBuilder: (BuildContext context, int index) {
              SearchData searchData = userMController.searchList[index];
              return userDetailsView(
                isDivider: false,
                name: '${searchData.firstName} ${searchData.lastName}',
                phoneNumber: '${searchData.contactNumber}',
                email: '${searchData.email}',
              );
            },
          ),
          20.ph,
          commonButton(
              onTap: () async {
                userIdList.add(userMController.searchList[0].id);
                CustomLoaderDialog.buildShowDialog(context);
                bool? result = await userMController.vehicleUserMapping(
                    vehicleId: bikeData.id,
                    userId: userMController.searchList[0].id,
                    name: userMController.searchList[0].username,
                    userType: userType);
                if (mounted) Navigator.pop(CustomLoaderDialog.dialogContext);
                if (result == true) {
                  final _updatedList = _updateBikeMeta(userId: userMController.searchList[0].id, toAdd: true, userType: userType);
                  ref.invalidate(userListProvider);
                  ref.watch(userListProvider(_updatedList));

                  //ref.refresh(userListProvider(_updatedList));
                  //await ref.watch(userListProvider(_updatedList).notifier).getAllUsers(userIdList);
                }
                Navigator.pop(context);
              },
              buttonText: isPrimaryUser == true ? LocaleKeys.keyAddPrimaryUser.tr() : LocaleKeys.keyAddUser.tr(),
              buttonColor: [
                const Color.fromRGBO(47, 64, 126, 1.0),
                const Color.fromRGBO(109, 69, 194, 1.0)
              ],
              isIconButton: true,
              buttonImage: icPlus,
              fontWeight: FontWeight.w800),
        ],
      );
    });
  }

  /*=========================================user Not Found View===============================================*/

  Widget userNotFoundView({bool isPrimaryUser = false}) {
    return Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) {
      var countryCode = ref.watch(userProvider
          .select((value) => value.formState.countryCode.countryCode));
      final userController = ref.watch(userProvider.notifier);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          headingText(
              fontSize: 16.sp,
              gradientColor: [
                Color.fromRGBO(111, 145, 178, 1.0),
                Color.fromRGBO(57, 79, 98, 1.0)
              ],
              title: LocaleKeys.keyUserNotFound.tr()),
          20.ph,
          textFormField(
            readOnly: true,
            hintText: LocaleKeys.keyPhoneNumber.tr(),
            controller: numberController,
            maxLength: 12,
            suffixIcon: Container(width: 0.0,),
            onChanged: (value) {
              userController.setAddUser(
                  name: nameController.text.trim(),
                  phoneNumber: numberController.text.trim(),
                  emailText: emailController.text.trim());
            },
            prefixIcon: InkWell(
              onTap: () {},
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  10.pw,
                  text(
                      title: '+$countryCode',
                      color: blackColor,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400),
                  6.pw,
                  Container(
                      height: 40.h,
                      width: 3.h,
                      child: VerticalDivider(
                        color: greyEsColor,
                        thickness: 2,
                        indent: 4.h,
                        endIndent: 4.h,
                      )),
                  6.pw,
                ],
              ),
            ),
          ),
          10.ph,
          textFormField(
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp("[a-zA-Z ]")),
              ],
              keyboardType: TextInputType.text,
              hintText: LocaleKeys.keyName.tr(),
              controller: nameController,
              suffixOnTab: (){
                nameController.clear();
                userController.setAddUser(
                    name: nameController.text.trim(),
                    phoneNumber: numberController.text.trim(),
                    emailText: emailController.text.trim());
              },
              onChanged: (value) {
                userController.setAddUser(
                    name: nameController.text.trim(),
                    phoneNumber: numberController.text.trim(),
                    emailText: emailController.text.trim());
              },
              contentPadding: EdgeInsets.all(10.h),
              maxLength: 50),
          10.ph,
          textFormField(
              inputFormatters: [],
              keyboardType: TextInputType.emailAddress,
              hintText: LocaleKeys.keyEmail.tr(),
              textInputAction: TextInputAction.done,
              controller: emailController,
              suffixOnTab: (){
                emailController.clear();
                userController.setAddUser(
                    name: nameController.text.trim(),
                    phoneNumber: numberController.text.trim(),
                    emailText: emailController.text.trim());
              },
              onChanged: (value) {
                userController.setAddUser(
                    name: nameController.text.trim(),
                    phoneNumber: numberController.text.trim(),
                    emailText: emailController.text.trim());
              },
              contentPadding: EdgeInsets.all(10.h),
              maxLength: 255),
          20.ph,
          commonButton(
              isIconButton: true,
              buttonImage: icPlus,
              fontWeight: FontWeight.w800,
              buttonColor: ref.watch(userProvider
                  .select((value) => value.formState.Email.buttonColor)),
              buttonText:
                  "${LocaleKeys.keyCreate.tr()} ${isPrimaryUser == true ? LocaleKeys.keyAddPrimaryUser.tr() : LocaleKeys.keyAddUser.tr()}",
              onTap: ref.watch(userProvider.select(
                      (value) => value.formState.Email.isColor == false)) ? () {} : () async {

                      FocusScope.of(context).requestFocus(FocusNode());
                      CustomLoaderDialog.buildShowDialog(context);
                      var userId = await userController.createUser(
                          userName: nameController.text.trim(),
                          email: emailController.text.trim(),
                          phoneNumber: numberController.text.trim(),
                          countryCode: countryCode,
                          isPrimary: userType == 'primary' ? true : false
                      );
                      if (userId != null) {
                        userIdList.add(userId);
                        final result = await userController.vehicleUserMapping(vehicleId: bikeData.id, userId: userId, name: nameController.text.trim(), userType: userType);
                        if (mounted)
                          Navigator.pop(CustomLoaderDialog.dialogContext);
                        if (result == true) {
                          final _updatedList = _updateBikeMeta(userId: userId, toAdd: true, userType: userType);
                          ref.invalidate(userListProvider);
                          ref.watch(userListProvider(_updatedList));

                          //ref.refresh(userListProvider(_updatedList));
                          // await ref.read(userListProvider(_updatedList).notifier).getAllUsers(userIdList);
                        }
                      }
                      Navigator.pop(context);
                    })
        ],
      );
    });
  }

  /*========================================add User Bottom Sheet View================================================*/

  void addUserBottomSheetView({Widget? child, double? height, bool buttonText = false}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(15.r),
        ),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            height: height,
            padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 25.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color.fromRGBO(255, 255, 255, 1.0),
                    const Color.fromRGBO(227, 248, 255, 1.0),
                  ]),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Image.asset(
                          icArrow,
                          color: Color.fromRGBO(47, 64, 126, 1.0),
                          scale: 1.8.h,
                        ),
                      ),
                      10.pw,
                      text(title: buttonText == true ? LocaleKeys.keyAddPrimaryUser.tr() : LocaleKeys.keyAddUser.tr(),
                          fontWeight: FontWeight.w800,
                          fontSize: 20.sp,
                          color: Color.fromRGBO(47, 64, 126, 1.0))
                    ],
                  ),
                  20.ph,
                  child ?? Container(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
