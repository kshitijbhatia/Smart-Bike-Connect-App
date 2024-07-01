import 'dart:async';
import 'dart:developer';

import 'package:country_picker/country_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smartbike_flutter/app_utils/app_utils.dart';
import 'package:smartbike_flutter/constants/app_colors.dart';
import 'package:smartbike_flutter/constants/assets.dart';
import 'package:smartbike_flutter/constants/strings.dart';
import 'package:smartbike_flutter/features/authentication/presentation/screens/login_screen.dart';
import 'package:smartbike_flutter/features/my_bikes/presentation/screens/my_bike_list_screen.dart';
import 'package:smartbike_flutter/features/settings/presentation/controllers/setting_controller.dart';
import 'package:smartbike_flutter/generated/locale_keys.g.dart';
import 'package:smartbike_flutter/widgets/ble_loc_listener.dart';
import 'package:smartbike_flutter/widgets/common_ui_methods.dart';
import 'package:smartbike_flutter/widgets/custom_loader_dialogs.dart';

import '../../../service/user_perm_controller.dart';
import '../../../user_management/presentation/controllers/user_management_controller.dart';

class AccountSettingScreen extends ConsumerStatefulWidget {

  final String appVersion;

  AccountSettingScreen(this.appVersion);

  @override
  ConsumerState<AccountSettingScreen> createState() => _AccountSettingScreenState();
}

class _AccountSettingScreenState extends ConsumerState<AccountSettingScreen> {

  List<String>? languageList = [ 'English', 'Français'];
  List<String>? roleList = [ LocaleKeys.keyBikeAdmin.tr() , LocaleKeys.keyMyBike.tr()];
  int? languageIndex = 0 ;
  String? languageText ;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController numberController = TextEditingController();


  @override
  void initState() {
    super.initState();
    _fetchDefaultView();
    _fetchUserData();
  }

  /*======================================fetch User Data==================================*/

  Future<void> _fetchUserData() async {
    if(await AppUtils.containsKey( key :Constants.USER_NAME)){
      String? name =   await AppUtils.getString(key:Constants.USER_NAME);
      ref.read(settingController.notifier).setUserName(name!);
    }
    if(await AppUtils.containsKey( key :Constants.USER_PHONE_NUMBER)){
      int? phoneNumber =   await AppUtils.getInt(key:Constants.USER_PHONE_NUMBER);
      ref.read(settingController.notifier).setPhoneNumber(phoneNumber!);
    }
    if(await AppUtils.containsKey( key :Constants.USER_COUNTRY_CODE)){
      int? countryCode =   await AppUtils.getInt(key:Constants.USER_COUNTRY_CODE);
      log('countryCode $countryCode');
      ref.read(settingController.notifier).setCountryCode(countryCode!);
    }
    if(await AppUtils.containsKey( key :Constants.USER_EMAIL)){
      String? email =   await AppUtils.getString(key:Constants.USER_EMAIL);
      ref.read(settingController.notifier).setUserEmail(email!);
    }
  }
  /*======================================fetch Default View from sharedPref==================================*/

  Future<void> _fetchDefaultView() async {
    if( await AppUtils.getString(key: Constants.ROLE) ==  Constants.BIKE_ADMIN_VIEW){
    ref.read(settingController.notifier).setRoleText(LocaleKeys.keyAdmin.tr());
    ref.read(settingController.notifier).setDefaultViewIndex(0);
    }
    else{
    ref.read(settingController.notifier).setRoleText(LocaleKeys.keyMyBike.tr());
    ref.read(settingController.notifier).setDefaultViewIndex(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
    body:  Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.only(top: 50.h, bottom: 20.h, left: 20.w, right: 20.w),
        decoration:  BoxDecoration(
            image: DecorationImage(image: AssetImage(icBg), fit: BoxFit.fill)),
        child: Column(
          children: [
            _titleHeadingBar(),
            Expanded(child: bodyView()),
          ],
        ),
      ),
    );
  }

  /*=============================================title Heading Bar=======================================*/
  Widget _titleHeadingBar() {
    return Row(
      children: [
        InkWell(
          onTap: (){
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const MyBikeList()), (Route<dynamic> route) => false,);
          },
          child: Container(
            height: 25.h,
            width: 30.h,
            padding: EdgeInsets.symmetric(vertical: 2.h),
              child: Image.asset(icArrow,color: blueColor),
          ),
        ),
        15.pw,
        Expanded(child: text(title: LocaleKeys.keyAccountSetting.tr(), maxLines:1,fontSize: 20.sp, color: blueColor, fontWeight: FontWeight.w500)),
        BleLocListener(),
      ],
    );
  }


/*================================================= body View===============================================*/
  Widget bodyView(){
    return Container(
      padding: EdgeInsets.only(top: 20.h, left: 20.w, right: 20.w),
      margin: EdgeInsets.only(top: 20.h, bottom: 15.h,),
      decoration: BoxDecoration(
          color: Colors.white54,
          boxShadow: [
            BoxShadow(
                color: const Color.fromRGBO(232, 239, 251, 1.0).withOpacity(0.5),
                spreadRadius: 6,
                blurRadius: 2.0,
            ),
          ],
          borderRadius: BorderRadius.circular(10.r)),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          headingText(
              gradientColor: [
                Color.fromRGBO(47, 64, 126, 1.0),
                Color.fromRGBO(47, 64, 126, 1.0)
              ],
              title: LocaleKeys.keyPersonalDetails.tr(),
              fontWeight: FontWeight.w800),
          15.ph,
          Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
              final userName =  ref.watch(settingController.select((value) => value.userName));
              final phoneNumber =  ref.watch(settingController.select((value) => value.phoneNumber));
              final email =  ref.watch(settingController.select((value) => value.email));
              return userDetailsView(
                isIcon: true,
                child: InkWell(
                    onTap: (){
                      numberController.text = phoneNumber.toString();
                      nameController.text = userName;
                      emailController.text = email;
                      _fetchUserData();
                      ref.watch(settingController.notifier).setProfileUpdateErrorBox(false);
                      ref.watch(userProvider.notifier).setAddUser(
                          name: nameController.text.trim(),
                          phoneNumber: numberController.text.trim(),
                          emailText: emailController.text.trim());

                      _bottomSheetView(height:MediaQuery.of(context).size.height/ 1.h,title: LocaleKeys.keyEditDetail.tr(),
                          child: _editProfileView());
                    },
                    child: Padding(
                      padding: EdgeInsets.only(top: 4.h),
                      child: Image.asset(icEdit,scale: 3.h),
                    )),

                name: userName,
                phoneNumber: phoneNumber.toString(),
                email: email,
              );
            },
          ),
          15.ph,
          headingText(
              gradientColor: [
                Color.fromRGBO(47, 64, 126, 1.0),
                Color.fromRGBO(47, 64, 126, 1.0)
              ],
              title: LocaleKeys.keyApplicationSettings.tr(),
              fontWeight: FontWeight.w800),
          _defaultView(),
          15.ph,
          _languageView(),
          15.ph,
          // _appVersionView(),
          // 15.ph,
          _logoutView(),
          Spacer(),
          Align(
            alignment: Alignment.center,
            child: text(title: 'App Version v${widget.appVersion}', color: greyBoldColor,
                fontSize: 13.sp, fontWeight: FontWeight.w400),
          ),
          15.ph,
        ],
      ),
    );
  }
/*============================================default View=============================================*/

  Widget _defaultView(){
    return  Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child)  {
       final roleText = ref.watch(settingController.select((value) => value.roleName));
       final visibility = ref.watch(userPermController.select((value) => value.isBikeAdminViewAllowed));
        return Visibility(
          visible: visibility,
          child: Column(
            children: <Widget>[
              15.ph,
              listTileView(
                  margin : 0.0,
                  title: LocaleKeys.keyDefaultView.tr(),
                  leadingHeight: 2.8.h,
                  subTitle: roleText ,
                  leadingIcons: icDefault,
                  onTap: () {
                    _bottomSheetView(
                        title: LocaleKeys.keySelectDefault.tr(),
                        child: _roleSelectionView());
                  }),
            ],
          ),
        );
      },
    );
  }

/*===============================================language View==============================================*/

  Widget _languageView(){
    return  Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        if(EasyLocalization.of(context)!.locale.languageCode == 'fr') {
          languageText = 'Français';
        }
        else{
          languageText = 'English';
        }
        return listTileView(
            margin : 0.0,
            title: LocaleKeys.keyLanguage.tr(),
            subTitle: languageText,
            leadingIcons: icLanguage,
            onTap: () async {
             _bottomSheetView(
                  title: LocaleKeys.keySelectLanguage.tr(),
                  child: _languageListView());
            });
      },
    );
  }

  /*==============================================_app Version View============================================*/

  Widget _appVersionView(){
    return  Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        return listTileView(
            margin : 0.0,
            title: LocaleKeys.keyAppVersion.tr(),
            subTitle: widget.appVersion,
            leadingIcons: icAppVersion,
            trailingIcon: Container(),
            onTap: () async {
              _bottomSheetView(
                  title: LocaleKeys.keySelectLanguage.tr(),
                  child: _languageListView());
            });
      },
    );
  }


/*==============================================logout View============================================*/

  Widget _logoutView(){
    return   Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        final logoutController = ref.watch(settingController.notifier);
        return listTileView(
            margin : 2.0.h,
            title: LocaleKeys.keyLogout.tr(),
            subTitle: '',
            leadingIcons: icLogout,
            trailingIcon: Container(),
            leadingOnTap: () async {
              appCommonDialog(
                  context: context,
                  onTap: () async {
                Navigator.pop(context);
                CustomLoaderDialog.buildShowDialog(context);
                bool? result = await logoutController.logout();
                if (mounted) Navigator.pop(CustomLoaderDialog.dialogContext);
                if(result == true){
                  Navigator.pushAndRemoveUntil(this.context, MaterialPageRoute(builder: (context) =>  LoginScreen()), (Route<dynamic> route) => false);
                }
              });
            });
      },

    );
  }
  /*======================================================role Selection View==============================*/

  Widget _roleSelectionView() {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        final roleIndex = ref.watch(settingController.select((value) => value.selectedIndex));
        return Column(
          children: [
            Container(
              height: 120.h,
              child: CupertinoPicker.builder(
                diameterRatio: 6.0.h,
                scrollController: FixedExtentScrollController(
                    initialItem: roleIndex),
                childCount: roleList!.length,
                selectionOverlay: CupertinoPickerDefaultSelectionOverlay(
                  background: Colors.transparent,
                ),
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(bottom: 10.h),
                    child: text(
                        title: roleList![index],
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: blackColor),
                  );
                },
                itemExtent: 50.h,
                onSelectedItemChanged: (int value) {
                  ref.watch(settingController.notifier).setDefaultViewIndex(value);
                },
              ),
            ),
            10.ph,
            commonButton(
                onTap: () async {
                  if(roleIndex == 0){
                 await  AppUtils.setString(key: Constants.ROLE, value: Constants.BIKE_ADMIN_VIEW);
                  ref.watch(settingController.notifier).setRoleText(LocaleKeys.keyAdmin.tr());
                  ref.watch(settingController.notifier).setDefaultViewIndex(roleIndex);
                  }
                  else {
                    await AppUtils.setString(key: Constants.ROLE, value: Constants.MY_BIKES_VIEW);
                    ref.watch(settingController.notifier).setRoleText(LocaleKeys.keyMyBike.tr());
                    ref.watch(settingController.notifier).setDefaultViewIndex(roleIndex);
                  }
                  Navigator.pop(context,true);
                },
                buttonText: LocaleKeys.keySubmit.tr(),
                buttonColor: [
                  const Color.fromRGBO(47, 64, 126, 1.0),
                  const Color.fromRGBO(109, 69, 194, 1.0)
                ],
                fontWeight: FontWeight.w800),
          ],
        );
      },
    );
  }

  /*==========================================================language List View==============================*/

  Widget _languageListView() {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        final changeLanguage = ref.watch(localeNotifierProvider.notifier);
        if(EasyLocalization.of(context)!.locale.languageCode == 'fr') {
          languageIndex = 1;
        }
        else{
          languageIndex = 0;
        }
        return Column(
          children: [
            Container(
              height: 120.h,
              child: CupertinoPicker.builder(
                diameterRatio: 6.0.h,
                scrollController: FixedExtentScrollController(
                    initialItem: languageIndex!),
                childCount: languageList!.length,
                selectionOverlay: CupertinoPickerDefaultSelectionOverlay(
                  background: Colors.transparent,
                ),
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(bottom: 10.h),
                    child: text(
                        title: languageList![index],
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: blackColor),
                  );
                },
                itemExtent: 50.h,
                onSelectedItemChanged: (int value) {
                  languageIndex = value;
                },
              ),
            ),
            10.ph,
            commonButton(
                onTap: () async {
                  if(languageIndex == 0){
                    changeLanguage.setLocale( locale : const Locale('en'));
                  }else {
                    changeLanguage.setLocale(locale: const Locale('fr'));
                  }
                  Navigator.push(this.context, MaterialPageRoute(builder: (context) =>  AccountSettingScreen(widget.appVersion)));
                  //Navigator.pop(context);
                },
                buttonText: LocaleKeys.keySubmit.tr(),
                buttonColor: [
                  const Color.fromRGBO(47, 64, 126, 1.0),
                  const Color.fromRGBO(109, 69, 194, 1.0)
                ],
                fontWeight: FontWeight.w800),
          ],
        );
      },
    );
  }

  Widget _editProfileView() {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        final userController = ref.watch(userProvider.notifier);
        final countryCode =  ref.watch(settingController.select((value) => value.countryCode));
        final settingApiController =  ref.watch(settingController.notifier);
        return Column(
          children: [
            10.ph,
            textFormField(
              hintText: LocaleKeys.keyPhoneNumber.tr(),
              controller: numberController,
              maxLength: 12,
              suffixOnTab: (){
                numberController.clear();
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
              prefixIcon: InkWell(
                onTap: () {
                  showCountryPicker(
                    favorite: ['IN'],
                    context: context,
                    showPhoneCode: true,
                    onSelect: (Country country) {
                      ref.watch(settingController.notifier).setCountryCode(int.parse(country.phoneCode));
                    },
                  );
                },
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
                        child: VerticalDivider(color: greyEsColor,thickness: 2,indent: 4.h,endIndent: 4.h,)),
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
                onChanged: (value) {
                  userController.setAddUser(
                      name: nameController.text.trim(),
                      phoneNumber: numberController.text.trim(),
                      emailText: emailController.text.trim());
                },
                suffixOnTab: (){
                  nameController.clear();
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
                textInputAction : TextInputAction.done,
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
            10.ph,
            Consumer(
              builder: (BuildContext context, WidgetRef ref, Widget? child) {
                final visibility = ref.watch(settingController.select((value) => value.profileUpdateErrorBox));
                return Visibility(
                  visible: visibility,
                  child: Padding(
                    padding:  EdgeInsets.only(top: 2.0.h,bottom: 8.h),
                    child: errorWidget(subTitle: LocaleKeys.keyPhoneError.tr(), ),
                  ),
                );
              },
            ),10.ph,
            commonButton(
                onTap: ref.watch(userProvider.select((value) => value.formState.Email
                    .isColor == false))
                    ? () {} : () async {

                  FocusScope.of(context).requestFocus(FocusNode());
                  CustomLoaderDialog.buildShowDialog(context);
                  bool? result =  await settingApiController.editProfile(userId: Constants.GLOBAL_USER_ID,
                      email: emailController.text.trim(), phoneNumber: numberController.text.trim(),name: nameController.text.trim(),countryCode: countryCode);
                  if (mounted) Navigator.pop(CustomLoaderDialog.dialogContext);
                  if(result == true){
                    _fetchUserData();
                    Navigator.pop(context,true);
                  }
                },
                buttonText: LocaleKeys.keySubmit.tr(),
                buttonColor: ref.watch(userProvider.select((value) => value.formState.Email.buttonColor)),
                fontWeight: FontWeight.w800),
          ],
        );
      },
    );
  }

  /*=======================================bottom Sheet View================================================*/

 void  _bottomSheetView({Widget? child, String? title,double? height}) {
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
          padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
                      Flexible(
                        child: text(
                          maxLines: 2,
                            title: title,
                            fontWeight: FontWeight.w800,
                            fontSize: 20.sp,
                            color: Color.fromRGBO(47, 64, 126, 1.0)),
                      )
                    ],
                  ),
                  10.ph,
                  child ?? Container(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }


  @override
  dispose() {
    super.dispose();
  }
}


