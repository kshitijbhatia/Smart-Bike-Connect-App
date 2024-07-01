


import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smartbike_flutter/features/user_management/domain/user_management_entity/users_list_model.dart';

part 'user_list_state.freezed.dart';

@freezed
class UsersList with _$UsersList {
  const factory UsersList({
    required List<Users> values,
  }) = _UsersList;

  const UsersList._();

  operator [](final int index) => values[index];

  int get length => values.length;



}
