// import 'package:background_location/background_location.dart';
// import 'package:flutter/material.dart';
//
//
// class LocationTracking extends StatefulWidget {
//   @override
//   _LocationTrackingState createState() => _LocationTrackingState();
// }
//
// class _LocationTrackingState extends State<LocationTracking> {
//   String latitude = 'waiting...';
//   String longitude = 'waiting...';
//   String altitude = 'waiting...';
//   String accuracy = 'waiting...';
//   String bearing = 'waiting...';
//   String speed = 'waiting...';
//   String time = 'waiting...';
//   bool? serviceRunning = null;
//
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text('Background Location Service'),
//         ),
//         body: Center(
//           child: ListView(
//             children: <Widget>[
//               locationData('Latitude: ' + latitude),
//               locationData('Longitude: ' + longitude),
//               locationData('Altitude: ' + altitude),
//               locationData('Accuracy: ' + accuracy),
//               locationData('Bearing: ' + bearing),
//               locationData('Speed: ' + speed),
//               locationData('Time: ' + time),
//               locationData('IsServiceRunning: ' + serviceRunning.toString()),
//               ElevatedButton(
//                 onPressed: () async {
//                   await BackgroundLocation.setAndroidNotification(
//                     title: 'Background service is running',
//                     message: 'Background location in progress',
//                     icon: '@mipmap/ic_launcher',
//                   );
//
//                   // Set the desired interval for location updates (e.g., 10 seconds)
//                   await BackgroundLocation.setAndroidConfiguration(10000); // 10 seconds
//
//                   await BackgroundLocation.startLocationService();
//                   BackgroundLocation.getLocationUpdates((location) {
//                     setState(() {
//                       latitude = location.latitude.toString();
//                       longitude = location.longitude.toString();
//                       accuracy = location.accuracy.toString();
//                       altitude = location.altitude.toString();
//                       bearing = location.bearing.toString();
//                       speed = location.speed.toString();
//                       time = DateTime.fromMillisecondsSinceEpoch(
//                           location.time!.toInt())
//                           .toString();
//                     });
//                     print('''\n
//                       Latitude:  $latitude
//                       Longitude: $longitude
//                       Altitude: $altitude
//                       Accuracy: $accuracy
//                       Bearing:  $bearing
//                       Speed: $speed
//                       Time: $time
//                       IsServiceRunning: $serviceRunning
//                     ''');
//                   });
//                 },
//                 child: Text('Start Location Service'),
//               ),
//               ElevatedButton(
//                 onPressed: () {
//                   BackgroundLocation.stopLocationService();
//                 },
//                 child: Text('Stop Location Service'),
//               ),
//               ElevatedButton(
//                 onPressed: () {
//                   BackgroundLocation.isServiceRunning().then((value) {
//                     setState(() {
//                       serviceRunning = value;
//                     });
//                     print("Is Running: $value");
//                   });
//                 },
//                 child: Text('Check service'),
//               ),
//               ElevatedButton(
//                 onPressed: () {
//                   getCurrentLocation();
//                 },
//                 child: Text('Get Current Location'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget locationData(String data) {
//     return Text(
//       data,
//       style: TextStyle(
//         fontWeight: FontWeight.bold,
//         fontSize: 18,
//       ),
//       textAlign: TextAlign.center,
//     );
//   }
//
//   void getCurrentLocation() {
//     BackgroundLocation().getCurrentLocation().then((location) {
//       print('This is current Location ' + location.toMap().toString());
//     });
//   }
//
// }