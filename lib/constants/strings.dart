

// ignore_for_file: constant_identifier_names

class Constants {

  static const Map<String,String> debugUrlCompName = {'url' :'https://sbm-staging.tagbox.co/external/','companyName' :  'tvs-sbm'};
  static const Map<String,String> prodUrlCompName  = {'url' :'https://api.tagbox.co/external/','companyName' :  'sbm-asean'};

  //Invoking Methods
  static const String APP_VERSION = "appVersion";
  static const String CHECK_APP_UPDATE = "checkAppVersion";
  static const String OPEN_APP_STORE = "openAppStore";
  static const String START_SERVICE = "startService";
  static const String DEVICE_ID = "deviceId";
  static const String CONNECT_TO_SBM = "connectToSBM";
  static const String DISCONNECT_FROM_SBM = "disconnectFromSBM";
  static const String CHANGE_STATE_OF_BIKE = "changeStateOfBike";
  static const String CHECK_STATUS_OF_SERVICE = "checkStatusOfService";
  static const String STOP_SERVICES = "stopServices";
  static const String CHECK_STATUS_OF_SBM = "statusOfSBM";
  static const String SEND_LEARN_MODE = "sendLearnMode";
  static const String CHANGE_SMARTNESS = "changeSmartness";
  static const String INITIATE_DFU = 'initiateDFU';
  static const String DEVICE_UUID = 'deviceUUID';
  static const String SEND_WHITELIST = "whiteList";

  //Receiving Methods
  static const String BLUETOOTH_STATE = "bluetoothState";
  static const String SBM_CONNECTED = "sbmConnected";
  static const String SBM_DISCONNECTED = "sbmDisconnected";
  static const String NEW_BIKE_STATE = "newBikeState";
  static const String NEW_BUTTON_STATE = "newButtonState";
  static const String LAST_PARK_LOCATION = "lastParkLocation";
  static const String BIKE_VICINITY = "bikeVicinity";
  static const String LEARN_MODE_RESPONSE = "learnModeResponse";
  static const String SMARTNESS_CHANGED = "smartnessChanged";
  static const String SBM_FIRMWARE_VERSION = "sbmFirmwareVersion";
  static const String DFU_PROGRESS = 'dfuProgress';
  static const String SAS_TOKEN_EXPIRED = "sasTokenExpired";
  static const String FAILED_TO_CHANGE_BIKE_STATE = "failedToChangeBikeState";
  static const String FAILED_TO_ADVERTISE = "failedToAdvertise";
  static const String SEND_LOCK = "SEND_LOCK";
  static const String SEND_UNLOCK = "SEND_UNLOCK";

  // SharedPref keys
  static const String SAS_TOKEN = "sasToken";
  static const String ACCESS_TOKEN = "accessToken";
  static const String USER_ID = "userId";
  static const String FIRST_TIME_INSTALL = "firstTimeInstall";
  static const String REFRESH_TOKEN = "refreshToken";
  static const String SELECTED_BIKE_META = "selectedBikeMeta";
  static const String USER_NAME = "userName";
  static const String USER_PHONE_NUMBER = "userPhoneNumber";
  static const String USER_COUNTRY_CODE = "countryCode";
  static const String USER_EMAIL = "userEmail";
  static const String ROLE = "role";

  static const String SUPER_ADMIN = "superAdmin";
  static const String DEALERSHIP_ADMIN = "dealershipAdmin";
  static const String DEALERSHIP_USER = "dealershipUser";
  static const String PRIMARY_USER = "primaryUser";
  static const String SECONDARY_USER = "secondaryUser";

  static const String SMARTNESS_ENABLE_TEXT = 'ENABLE';
  static const String SMARTNESS_DISABLE_TEXT = 'DISABLE';
  static const String SMARTNESS_FAILED = 'FAILED';

  static const String BIKE_ADMIN_VIEW = "Admin";
  static const String MY_BIKES_VIEW = "MyBikes";

  static int GLOBAL_USER_ID = -1; //TODO Use this throughout the app.

}

enum SBM_STATE {
  CONNECTED ,
  DISCONNECTED
}

enum BIKE_STATE{
  UNLOCKED,
  LOCKED
}


