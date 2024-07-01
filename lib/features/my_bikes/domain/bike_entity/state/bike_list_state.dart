import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smartbike_flutter/features/my_bikes/domain/bike_entity/bike_model/bike_model.dart';

part 'bike_list_state.freezed.dart';

@freezed
class BikeList with _$BikeList {
  const factory BikeList({
    required List<BikeData> values,
  }) = _BikeList;

  const BikeList._();

  operator [](final int index) => values[index];

  int get length => values.length;

}
