import 'dart:developer';

import 'package:connectivity/connectivity.dart';

class InternetConnectivity {

  static const String _loggerName = 'InternetConnectivity';

  static Future<bool> checkNetworkConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.mobile) {
      log("Connectivity: Connected to mobile", name: _loggerName);
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      log("Connectivity: Connected to wifi", name: _loggerName);
      return true;
    }
    return false;
  }
}