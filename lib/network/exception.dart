import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:smartbike_flutter/generated/locale_keys.g.dart';
import 'package:smartbike_flutter/widgets/toast.dart';

class DataException implements Exception {

  String message = LocaleKeys.toastInconvenience.tr();

  DataException.fromDioError(DioError dioError) {

    switch (dioError.type) {
      case DioErrorType.cancel:
        message = LocaleKeys.toastRequestCancelled.tr();
        break;
      case DioErrorType.connectionTimeout:
        message = LocaleKeys.toastNetworkSlow.tr();
        break;
      case DioErrorType.receiveTimeout:
        message = LocaleKeys.toastReceiveTimeout.tr();
        break;
      case DioErrorType.sendTimeout:
        message = LocaleKeys.toastSendTimeout.tr();
        break;

      case DioErrorType.connectionError:
        message = LocaleKeys.toastCheckInternet.tr();
        break;

      case DioErrorType.unknown:

        if(dioError.error != null && dioError.error.toString().contains('SocketException')){
          message = LocaleKeys.toastCheckInternet.tr();
          showToast(LocaleKeys.toastInternetSlow.tr(),warning: true, duration: true);
          break;
        }
        message = LocaleKeys.toastGenericMsg.tr();
        break;

      default:  if(dioError.message == 'SocketException') {
        DataException.customException('noInternet');
      }
      break;
    }
  }

  DataException.customException(String errorMessage) {
    if(errorMessage == 'noInternet'){
      message = LocaleKeys.toastCheckInternet.tr();
    }else{
      message = errorMessage;
    }
  }



  @override
  String toString() => message;
}
