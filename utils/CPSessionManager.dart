
import 'dart:collection';
import 'dart:convert';

import 'package:intl/intl.dart';

import 'PreferenceUtils.dart';


class CPSessionManager{
  //Auth Token
  final String AUTH_TOKEN = "user_auth_token";
  final String CUST_ID = "cust_id";
  final String ANDROID = "android";
  final String USER_NAME = "user_name";
  static const String USER_ID = "user_id";
  static const String TOKEN_ID = "token_id";
  static const String USER = "user";
  static const String IS_LOGIN = "is_Login";


  static final CPSessionManager _instance = CPSessionManager._internal();

  factory CPSessionManager() {
    return _instance;
  }

  CPSessionManager._internal();


  bool isLogins() {
    return PreferenceUtils.getBool(IS_LOGIN);
  }

  void setLogin(bool user_name) {
    PreferenceUtils.setBool(IS_LOGIN, user_name);
  }


}