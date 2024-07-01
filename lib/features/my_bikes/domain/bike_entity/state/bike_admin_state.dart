import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

part 'bike_admin_state.freezed.dart';


@freezed
class BikeAdminState with _$BikeAdminState{

  const factory BikeAdminState({
    @Default(null) MobileScannerArguments? mobileScannerArguments,
    @Default(null) Barcode? barcode,
    @Default(null) BarcodeCapture? capture,
    @Default(false) bool isErrorBox,
    @Default(false) bool buttonColor,
  }) = _BikeAdminPageState;

  const BikeAdminState._();

}