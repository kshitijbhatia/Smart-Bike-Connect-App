import 'package:dio/dio.dart';

abstract class UserManagement{

  Future<Response> getUsers({required String pathParam , required Map<String, dynamic> body});

  Future<Response> searchUser({required String pathParam , required Map<String, dynamic> body});

  Future<Response> createUser({required String pathParam , required Map<String, dynamic> body , required  Map<String, dynamic> queryParam});

  Future<Response> vehicleUserMapping({required String pathParam ,  required List<Map<String, dynamic>> body});

  Future<Response> deleteUserMapping({required String pathParam ,   required Map<String, dynamic> queryParam});

}

