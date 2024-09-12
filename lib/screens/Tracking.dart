import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _controller;
  final LatLng _initialPosition = LatLng(17.4875, 78.3953); // Example initial position
  final Set<Marker> _markers = {};
  List<LatLng> _routeCoordinates = [];
  LatLng newPosition = LatLng(17.379950997251388, 78.48784199358906);
  BitmapDescriptor deliveryBoyLocationIcon = BitmapDescriptor.defaultMarker;

  @override
  void initState() {
    super.initState();
    // FirebaseAnalytics.instance.logScreenView(screenName: "Order Tracking");
    addCustomIcon(); // Load custom icon
    // fetchLoc();
  }

  void getReadyToFetchLoc() {
    Future.delayed(const Duration(seconds: 35), () {
      // fetchLoc();
    });
  }

  // Future<void> fetchLoc() async {
  //   try {
  //     final data = await UserApi.fetchPorterDeliveryLoc();
  //     if (data != null && data.error == "0") {
  //       setState(() {
  //         var loc = data.loc!.split(', ');
  //         newPosition = LatLng(double.parse(loc[0]), double.parse(loc[1]));
  //         _markers.clear();
  //         _markers.add(Marker(
  //           markerId: const MarkerId('deliveryPartner'),
  //           position: newPosition,
  //           infoWindow: const InfoWindow(title: 'Delivery Partner'),
  //           icon: deliveryBoyLocationIcon,
  //         ));
  //         _updateRoute(newPosition);
  //       });
  //     }
  //     getReadyToFetchLoc();
  //   } catch (e) {
  //     toast(context, "Something went wrong, Please try again...");
  //   }
  // }

  Future<void> _updateRoute(LatLng destination) async {
    String googleApiKey = "YOUR_API_KEY";
    final response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json?origin=${_initialPosition.latitude},${_initialPosition.longitude}&destination=${destination.latitude},${destination.longitude}&key=$googleApiKey'));

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List<LatLng> points =
      _decodePolyline(decoded['routes'][0]['overview_polyline']['points']);
      setState(() {
        _routeCoordinates = points;
      });
    }
  }

  void addCustomIcon() {
    BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(2, 2)),
      "assets/images/currentLocation.png",
    ).then(
          (icon) {
        setState(() {
          deliveryBoyLocationIcon = icon;
        });
      },
    );
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      double latLngLatitude = lat / 1E5;
      double latLngLongitude = lng / 1E5;
      points.add(LatLng(latLngLatitude, latLngLongitude));
    }
    return points;
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Order Tracking"),
      ),
      body: Container(
        height: 250,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _initialPosition,
            zoom: 14.0,
          ),
          markers: _markers,
          polylines: {
            Polyline(
              polylineId: const PolylineId('route'),
              points: _routeCoordinates,
              color: Colors.black,
              width: 2,
            )
          },
          onMapCreated: (GoogleMapController controller) {
            _controller = controller;
          },
        ),
      ),
    );
  }
}
