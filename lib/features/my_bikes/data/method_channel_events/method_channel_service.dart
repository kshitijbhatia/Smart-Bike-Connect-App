



abstract class MethodChannelService {

  void onBleStateChange(final bool newState);

  void onSBMConnected();

  void onSBMDisconnected();

  void onButtonStateChange(String newButtonState);

  void onBikeStateChange(String newBikeState);

  void onBikeVicinityChange(String bikeRange);

  void onLastParkedLocationChange(dynamic lastParkedLocationData);

  void onCurrentLocationChange(dynamic currentLocationData);

  void onSendLearnModeChange(bool result);

  void onSmartnessChange(String result);

  void onFirmwareVersionReceived(String firmwareVersion);

  void onSasTokenExpired();

  void onDfuProgress(int percentage);

  void onFailedToAdvertise(bool warningState);


}
