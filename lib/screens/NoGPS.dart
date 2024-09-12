
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as loc;
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';

import 'PunchInOut.dart';


class NoGPS extends StatefulWidget {
  const NoGPS({Key? key}) : super(key: key);

  @override
  State<NoGPS> createState() => _NoGPSState();
}

class _NoGPSState extends State<NoGPS> {
  var loading_location = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Exit the app
        SystemNavigator.pop();
        // Return false to prevent default back navigation behavior
        return false;
      },
      child: Scaffold(
          body: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 30,
                ),
                Container(
                  width: 300,
                  child: Text(
                    "We need access to your location to provide specific feature.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: "Inter",
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black),
                  ),
                ),
                Lottie.asset(
                  'assets/animations/locationdenied.json',
                  height: 350,
                  width: 250,
                ),
                Center(
                  child: Text(
                    "Location Disabled",
                    style: TextStyle(
                        fontFamily: "Inter",
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Look's like you've not enabled\n your location",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: "Inter",
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xffBABECF)),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          bottomNavigationBar: Padding(
            padding: EdgeInsets.only(bottom: 50),
            child: TextButton(
              onPressed: () {
                setState(() {
                  loading_location = true;
                });
                getLocationPermissions();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
              ),
              child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                      color: Color(0xffF6821F),
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  child: Center(
                      child: (loading_location)
                          ? CircularProgressIndicator(
                        color:Colors.white,
                      )
                          : Text("Enable Location",
                          style: TextStyle(
                              fontFamily: "Inter",
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.bold)))),
            ),
          )),
    );
  }

  Future<void> requestGpsPermission() async {
    final loc.Location location = loc.Location();
    bool serviceEnabled;
    serviceEnabled = await location.serviceEnabled();
    try {
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          serviceEnabled = await location.requestService();
        } else {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => Punching()));
        }
      } else {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => Punching()));
      }
    } catch (e, s) {

    }
  }


  Future<void> getLocationPermissions() async {
    // Check if location services are enabled
    bool isLocationEnabled = await Geolocator.isLocationServiceEnabled();
    LocationPermission permission = await Geolocator.checkPermission();
    bool hasLocationPermission = permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
    try {
      if (!isLocationEnabled || !hasLocationPermission) {
        // Location services or permissions are not enabled, request permission
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.always &&
            permission != LocationPermission.whileInUse) {
          // Permission not granted, handle accordingly
          // Show a message to the user indicating that location permission is needed
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: Text(
                  'It look like you have turned off permissions required for this feature.It can be enabled under phone Settings > Apps > Medchoice > Permissions',
                  style: TextStyle(
                    fontFamily: "Inter",
                    fontSize: 15,
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.white),
                      overlayColor: MaterialStateProperty.all(Colors.white),
                    ),
                    onPressed: () async {
                      await openAppSettings();
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Go To Settings',
                      style: TextStyle(
                          fontFamily: "Inter",
                          fontSize: 15,
                          color: Colors.cyan),
                    ),
                  ),
                ],
              );
            },
          );
          return;
        } else {
          setState(() {
            loading_location = false;
          });
          requestGpsPermission();
        }
      } else {
        setState(() {
          loading_location = false;
        });
        requestGpsPermission();
      }
    } catch (e, s) {
    }
  }
}