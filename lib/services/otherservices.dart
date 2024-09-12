import 'package:geolocator/geolocator.dart';

import '../preferences.dart';
import '../utils/constants.dart';

Future<Map<String, String>> getheader() async {
  final sessionid = await PreferenceService().getString("token");
  print(sessionid);
  String Token = "Bearer ${sessionid}";
  Map<String, String> headers = {
    'Authorization': Token,
    'Content-Type': 'application/json',
  };
  return headers;
}

Future<Map<String, String>> getheader1() async {
  final sessionid = await PreferenceService().getString("token");
  print(sessionid);
  String Token = "Bearer ${sessionid}";
  Map<String, String> headers = {
    'Content-Type': 'application/json',
  };
  return headers;
}

Future<bool> checkGPSstatus() async {
  bool isLocationEnabled = await Geolocator.isLocationServiceEnabled();
  LocationPermission permission = await Geolocator.checkPermission();
  bool hasLocationPermission = permission == LocationPermission.always ||
      permission == LocationPermission.whileInUse;
  if (!isLocationEnabled || !hasLocationPermission) {
    return false;
  } else {
    return true;
  }
}
