import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:smartbike_flutter/features/my_bikes/domain/bike_entity/state/bike_admin_state.dart';
import 'package:smartbike_flutter/features/my_bikes/domain/bike_entity/state/bike_list_state.dart';
import 'package:smartbike_flutter/features/service/app_service.dart';
import 'package:smartbike_flutter/widgets/toast.dart';






final bikeAdminController = StateNotifierProvider<BikeAdminController, BikeAdminState>((ref) => BikeAdminController(ref));

class BikeAdminController extends StateNotifier<BikeAdminState> {
  final Ref ref;

  BikeAdminController(this.ref) : super(BikeAdminState()) ;


  setBarcodeData(final Barcode? barcode) {
    state = state.copyWith(barcode: barcode);
  }

  setMobileScannerArguments(final MobileScannerArguments? mobileScannerArguments) {
    state = state.copyWith(mobileScannerArguments: mobileScannerArguments);
  }
  setBarcodeCapture(final BarcodeCapture? capture) {
    state = state.copyWith(capture: capture);
  }

  setErrorBox(final bool isErrorBox) {
    state = state.copyWith(isErrorBox: isErrorBox);
  }

  setButtonColor(final bool buttonColor) {
    state = state.copyWith(buttonColor: buttonColor);
  }


  /*=======================================search sbm ==================================*/

  Future <BikeList?> searchSBM(String vehicleSbmKeyFobNames)  async{
    try{
      var response = await  ref.read(applicationService).searchSBM(vehicleSbmKeyFobNames);
      if(response != null){
        return response;
      }
      else{
        setErrorBox(true);
        return null;
      }
    }catch(e){
      showToast(e.toString(),warning: true,duration: true);
      setErrorBox(false);
      return null;
    }
  }

}
