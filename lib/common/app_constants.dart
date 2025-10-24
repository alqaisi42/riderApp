// ignore_for_file: file_names

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:restart_tagxi/db/app_database.dart';

import '../features/language/domain/models/language_listing_model.dart';
import 'dart:io';

class AppConstants {
  static const String title = 'Taxi App';
  static const String baseUrl = 'https://srv897275.hstgr.cloud/';

  static String firbaseApiKey = (Platform.isAndroid)
      ? "AIzaSyBdEmxhJdFNvE7IqSImjK1p98vqSb-W_Xg"
      : "AIzaSyCT0Pi-J8o34y8bAdPn-V53j5pmG1czLuA";

  static String firebaseAppId = (Platform.isAndroid)
      ? "1:884073976105:android:3f3597e9b0b873ff87a738"
      : "1:884073976105:ios:27d1cdb621d6f22f87a738";

  static String firebasemessagingSenderId = Platform.isAndroid
      ? "884073976105"
      : "884073976105";

  static String firebaseProjectId = Platform.isAndroid
      ? "taxi-24082"
      : "taxi-24082";

  static String mapKey =
      (Platform.isAndroid) ? 'AIzaSyA43eqgWmAYiXeK4HOryBq7z3RLRvD4elU' : 'AIzaSyA43eqgWmAYiXeK4HOryBq7z3RLRvD4elU';
  static const String privacyPolicy = 'your privacy policy url';
  static const String termsCondition = 'your terms and condition url';

  static const String stripPublishKey = '';

  static List<LocaleLanguageList> languageList = [
    LocaleLanguageList(name: 'English', lang: 'en'),
    LocaleLanguageList(name: 'Arabic', lang: 'ar'),
    LocaleLanguageList(name: 'Azerbaijani', lang: 'az'),
    LocaleLanguageList(name: 'French', lang: 'fr'),
    LocaleLanguageList(name: 'Spanish', lang: 'es'),
  ];

  static LatLng currentLocations = const LatLng(0, 0);
}

AppDatabase db = AppDatabase();
bool isAppMapChange = false;
