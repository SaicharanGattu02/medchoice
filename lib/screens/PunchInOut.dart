import 'package:fieldsenses/screens/home.dart';
import 'package:fieldsenses/services/UserApi.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart' as geocoder;
import 'package:page_transition/page_transition.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class Punching extends StatefulWidget {
  const Punching({super.key});

  @override
  State<Punching> createState() => _PunchingState();
}

class _PunchingState extends State<Punching> {
  static const platform = MethodChannel('com.pixl/location');
  double lat = 0.0;
  double lng = 0.0;
  var latlngs = "";
  bool valid_address = true;
  bool punching = true;
  bool _loading = true;

  late String _locationName = "";
  late String _pinCode = "";
  final nonEditableAddressController = TextEditingController();

  Set<Marker> markers = {};
  Set<Circle> circles = {}; // To hold circle indicators

  late LatLng initialPosition = LatLng(17.4065, 78.4772);
  late GoogleMapController mapController;
  GoogleMapController? _controller;
  var address_loading = true;
  bool submit =false;

  String status = "";

  DateTime? _lastPressedAt;
  final Duration _exitTime = Duration(seconds: 2);

  String _location = 'Unknown';

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndFetchLocation();
    GetPuchInStatus();
  }

  void _startLocationService() async {
    try {
      await platform.invokeMethod('startService', {'message': 'Location Service Started'});
    } on PlatformException catch (e) {
      print("Failed to start service: '${e.message}'.");
    }
  }

  void _stopLocationService() async {
    try {
      await platform.invokeMethod('stopService');
    } on PlatformException catch (e) {
      print("Failed to stop service: '${e.message}'.");
    }
  }

  Future<void> _initLocationUpdates() async {
    platform.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        case "onLocationUpdate":
          final Map<dynamic, dynamic> location = call.arguments;
          setState(() {
            _location = 'Lat: ${location['latitude']}, Lon: ${location['longitude']}';
            print("location:${_location}");
          });
          break;
        default:
          print('Unknown method called');
      }
    });
  }

  Future<void> _checkPermissionsAndFetchLocation() async {
    var status = await Permission.locationWhenInUse.status;
    if (status.isGranted) {
      _getCurrentLocation();
    } else if (status.isDenied) {
      if (await Permission.locationWhenInUse.request().isGranted) {
        _getCurrentLocation();
      } else {
        setState(() {
          _locationName = "Location permission denied.";
        });
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
    );

    setState(() {
      lat = position.latitude;
      lng = position.longitude;
      latlngs = "${lat}, ${lng}";
      initialPosition = LatLng(lat, lng);
      // markers.add(Marker(
      //   markerId: MarkerId("user_location"),
      //   position: initialPosition,
      //   infoWindow: InfoWindow(title: "You are here"),
      //   icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      // ));
      circles.add(Circle(
        circleId: CircleId("user_location_circle"),
        center: initialPosition,
        radius: 100, // Radius in meters
        fillColor: Colors.blue.withOpacity(0.2),
        strokeColor: Colors.blue,
        strokeWidth: 1,
      ));
      _getAddress(lat, lng);
      _controller?.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: initialPosition, zoom: 17),
      ));
    });
  }

  Future<void> _getAddress(double? lat1, double? lng1) async {
    if (lat1 == null || lng1 == null) return;
    List<geocoder.Placemark> placemarks =
        await geocoder.placemarkFromCoordinates(lat1, lng1);

    geocoder.Placemark? validPlacemark;
    for (var placemark in placemarks) {
      if (placemark.country == 'India' &&
          placemark.isoCountryCode == 'IN' &&
          placemark.postalCode != null &&
          placemark.postalCode!.isNotEmpty) {
        validPlacemark = placemark;
        break;
      }
    }
    if (validPlacemark != null) {
      setState(() {
        _locationName =
            "${validPlacemark?.name},${validPlacemark?.subLocality},${validPlacemark?.subAdministrativeArea},"
                    "${validPlacemark?.administrativeArea},${validPlacemark?.postalCode}"
                .toString();
        _pinCode = validPlacemark!.postalCode.toString();
        address_loading = false;
        valid_address = true;
        _loading = false;
      });
    } else {
      // Handle case where no valid placemark is found
      setState(() {
        _locationName =
            "Whoa there, explorer! \nYou've reached a place we haven't. Our services are unavailable here. \nTry another location!";
        address_loading = false;
        valid_address = false;
        _loading = false;
      });
    }
  }

  void _onCameraMove(CameraPosition position) {
    setState(() {
      lat = position.target.latitude;
      lng = position.target.longitude;
      latlngs = "${lat}, ${lng}";
      address_loading = false;
    });
  }

  Future<void> GetPuchInStatus() async {
    final Response = await Userapi.GetPuchInStatusApi();
    if (Response != null) {
      setState(() {
        if (Response.settings?.success == 1) {
          status = Response?.status ?? "";
        }
      });
    } else {
      _loading = false;
    }
  }

  Future<void> PunchIn() async {
    String location = _locationName;
    String lattitudee = lat.toString();
    String longitudee = lng.toString();
    final punchingResponse =
        await Userapi.PostPunchInAPI(lattitudee, longitudee, location);
    if (punchingResponse != null) {
      setState(() {
        if (punchingResponse.settings?.success == 1) {
          _loading = false;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              "${punchingResponse?.settings?.message??""}",
              style: TextStyle(color: Color(0xFFFFFFFF),
                  fontFamily: "Inter"
              ),
            ),
            duration: Duration(seconds: 1),
            backgroundColor:  Color(0xFFF6821F),
          ));
          punching = !punching;
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.rightToLeft,
              isIos: true,
              child: HomeScreen(),
              duration: Duration(
                  milliseconds: 300), // Optional: Customize transition duration
            ),
          );
        }else{
          _loading = false;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              "${punchingResponse?.settings?.message??""}",
              style: TextStyle(color: Color(0xFFFFFFFF),
                  fontFamily: "Inter"
              ),
            ),
            duration: Duration(seconds: 1),
            backgroundColor:  Color(0xFFF6821F),
          ));
        }
      });
    }
  }

  Future<void> PunchOut() async {
    String location = _locationName;
    String lattitudee = lat.toString();
    String longitudee = lng.toString();
    final punchingResponse =
        await Userapi.PostPunchOutAPI(lattitudee, longitudee, location);
    if (punchingResponse != null) {
      setState(() {
        if (punchingResponse.settings?.success == 1) {
          submit=false;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              "${punchingResponse?.settings?.message??""}",
              style: TextStyle(color: Color(0xFFFFFFFF),
                  fontFamily: "Inter"
              ),
            ),
            duration: Duration(seconds: 1),
            backgroundColor:  Color(0xFFF6821F),
          ));
          punching = !punching;
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.rightToLeft,
              isIos: true,
              child: HomeScreen(),
              duration: Duration(
                  milliseconds: 300), // Optional: Customize transition duration
            ),
          );
        }else{
          submit=false;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              "${punchingResponse?.settings?.message??""}",
              style: TextStyle(color: Color(0xFFFFFFFF),
                  fontFamily: "Inter"
              ),
            ),
            duration: Duration(seconds: 1),
            backgroundColor:  Color(0xFFF6821F),
          ));
        }
      });
    }
  }


  Future<bool> _onWillPop() async {
    final DateTime now = DateTime.now();
    if (_lastPressedAt == null || now.difference(_lastPressedAt!) > _exitTime) {
      // Show toast message
      Fluttertoast.showToast(
        msg: "Press back again to exit",
        toastLength: Toast.LENGTH_SHORT,
      );
      _lastPressedAt = now;
      return Future.value(false); // Do not exit the app yet
    }
    return Future.value(true); // Exit the app
  }

  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Center(
                child: Image.asset(
                  'assets/medchoiceLogo.png',
                  fit: BoxFit.contain,
                  height: 50,
                  width: 200, // Adjust the height as needed
                ),
              ),
            ],
          ),
        ),
        body: _loading
            ? Center(
                child: CircularProgressIndicator(
                color: Color(0xFFF6821F),
              ))
            : Stack(
                children: [
                  GoogleMap(
                    mapType: MapType.normal,
                    initialCameraPosition: CameraPosition(
                      target: initialPosition,
                      zoom: 17.0,
                    ),
                    onMapCreated: (GoogleMapController controller) {
                      _controller = controller;
                    },
                    onCameraIdle: () {
                      // _getAddress(lat, lng); // Uncomment and implement if needed
                    },
                    markers: markers,
                    circles: circles,
                    myLocationEnabled: true,
                    zoomControlsEnabled: true,
                    myLocationButtonEnabled: false,
                    compassEnabled: false,
                    zoomGesturesEnabled: false,
                    scrollGesturesEnabled: false,
                    rotateGesturesEnabled: false,
                    tiltGesturesEnabled: false,
                    minMaxZoomPreference: MinMaxZoomPreference(16, null),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      width: width,
                      height: height * 0.23,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25),
                          topRight: Radius.circular(25),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, -1),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding:
                            const EdgeInsets.only(top: 24, left: 16, right: 16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Location",
                              style: TextStyle(
                                color: Color(0xFF465761),
                                fontFamily: "Inter",
                                fontWeight: FontWeight.w700,
                                fontSize: 24,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              "$_locationName",
                              style: TextStyle(
                                color: Color(0xFF465761),
                                fontFamily: "Inter",
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(height: height * 0.03),
                            InkWell(
                              onTap: () async {
                                if (status == "Punch in") {
                                  if(submit){

                                  }else{
                                    setState(() {
                                      submit=true;
                                      PunchOut();
                                      _stopLocationService();
                                    });
                                  }
                                } else {
                                  if(submit){

                                  }else{
                                    setState(() {
                                      submit=true;
                                      PunchIn();
                                      _startLocationService();
                                      _initLocationUpdates();
                                    });
                                  }
                                }
                              },
                              child: Container(
                                width: width,
                                height: 45,
                                decoration: BoxDecoration(
                                  color: Color(0xFFF6821F),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Center(
                                  child: (submit)?
                                      CircularProgressIndicator(
                                        strokeWidth: 1,
                                        color: Colors.white,
                                      ):
                                  Text(
                                    status == "Punch in"
                                        ? "Punch Out"
                                        : "Punch In",
                                    style: TextStyle(
                                      color: Color(0xFFFFFFFF),
                                      fontFamily: "Inter",
                                      fontWeight: FontWeight.w500,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: height * 0.24, // Adjust the position as needed
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.my_location, color: Color(0xFFF6821F)),
                            SizedBox(width: 8),
                            Text(
                              "Locate Me",
                              style: TextStyle(
                                color: Color(0xFF465761),
                                fontFamily: "Inter",
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
