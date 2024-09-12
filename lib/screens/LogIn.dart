import 'package:fieldsenses/screens/NoGPS.dart';
import 'package:fieldsenses/screens/PunchInOut.dart';
import 'package:fieldsenses/screens/home.dart';
import 'package:fieldsenses/services/UserApi.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../preferences.dart';
import '../services/otherservices.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  final FocusNode _focusNodeEmail = FocusNode();
  final FocusNode _focusNodePassword = FocusNode();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _loading = false;
  bool _isPasswordVisible = false;
  DateTime? _lastPressedAt;
  final Duration _exitTime = Duration(seconds: 2);
  int denialCount = 0;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _focusNodeEmail.dispose();
    _focusNodePassword.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    getLocationPermissions();
  }

  Future<void> GetPuchInStatus() async {
    final Response = await Userapi.GetPuchInStatusApi();
    if(Response != null){
      setState(() {
        if (Response.settings?.success == 1) {
          var status=Response?.status??"";
          if(status=="Punch in" || status=="Punch out"){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
          }else{
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Punching()));
          }
        }
      });
    } else {

    }
  }

  bool permissions_granted = false;
  bool serviceEnabled = false;

  Future<void> getLocationPermissions() async {
    // Check if location services are enabled
    bool isLocationEnabled = await Geolocator.isLocationServiceEnabled();
    // Check if the app has been granted location permission
    LocationPermission permission = await Geolocator.checkPermission();
    bool hasLocationPermission = permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;

    try {
      if (!isLocationEnabled || !hasLocationPermission) {
        // Location services or permissions are not enabled, request permission
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.always &&
            permission != LocationPermission.whileInUse) {
          denialCount++;
          if (denialCount >= 2) {
            // Redirect user to app settings after denying twice
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  content: Text(
                    'You have denied location permission twice. Please enable it in your app settings.',
                    style: TextStyle(
                      fontFamily: "Inter",
                      fontSize: 15,
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.white),
                        overlayColor: MaterialStateProperty.all(Colors.white),
                      ),
                      onPressed: () async {
                        Navigator.pop(context);
                        openAppSettings(); // Redirect to app settings
                      },
                      child: Text(
                        'Open Settings',
                        style: TextStyle(
                          fontFamily: "Inter",
                          fontSize: 15,
                          color: Colors.cyan,
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          } else {
            // Show retry dialog if not reached the limit
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  content: Text(
                    'Medchoice uses this permission to detect your current location. Please enable your location permission.',
                    style: TextStyle(
                      fontFamily: "Inter",
                      fontSize: 15,
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.white),
                        overlayColor: MaterialStateProperty.all(Colors.white),
                      ),
                      onPressed: () async {
                        Navigator.pop(context);
                        await getLocationPermissions();
                      },
                      child: Text(
                        'Retry',
                        style: TextStyle(
                          fontFamily: "Inter",
                          fontSize: 15,
                          color: Colors.cyan,
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          }
          return;
        } else {
          // Request GPS permission if granted
          requestGpsPermission();
        }
      } else {
        // Request GPS permission if location services and permission are enabled
        requestGpsPermission();
      }
    } catch (e, s) {
      // Handle exception here
      print('Error: $e\n$s');
    }
  }

  Future<void> requestGpsPermission() async {
// Check if the app has been granted location permission
    final loc.Location location = loc.Location();
    bool serviceEnabled;
    serviceEnabled = await location.serviceEnabled();
    try {
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          serviceEnabled = await location.requestService();
        } else {}
      } else {}
    } catch (e, s) {}
  }

  Future<void> logIn() async {
    String email = _emailController.text;
    String pwd = _passwordController.text;

    setState(() {
      _loading = true;
    });

    final loginResponse = await Userapi.PostLogin(email, pwd);
    if (loginResponse != null) {
      if (loginResponse.settings?.success == 1) {
        PreferenceService().saveString("token", (loginResponse.data?.access).toString());
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token',  (loginResponse.data?.access).toString());
        if (!(await checkGPSstatus())) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => NoGPS()));
        } else {
          GetPuchInStatus();
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            "You're logged in successfully!",
            style: TextStyle(color: Color(0xFFFFFFFF),
            fontFamily: "Inter"
            ),
          ),
          duration: Duration(seconds: 1),
          backgroundColor:  Color(0xFFF6821F),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            "${loginResponse.settings?.message}",
            style: TextStyle(color: Color(0xFFFFFFFF),
                fontFamily: "Inter"
            ),
          ),
          duration: Duration(seconds: 1),
          backgroundColor:  Color(0xFFF6821F),
        ));
      }
    } else {
      print("Login failed.");
    }

    setState(() {
      _loading = false;
    });
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
    SystemNavigator.pop();
    return Future.value(true); // Exit the app
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: height * 0.3,
                width: width,
                child: Image.asset(
                  "assets/signin.png",
                  fit: BoxFit.fill,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Let's Login to Your Account",
                        style: TextStyle(
                          color: Color(0xFF32657B),
                          fontFamily: "Inter",
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Email",
                        style: TextStyle(
                          color: Color(0xFF32657B),
                          fontFamily: "Inter",
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      TextFormField(
                        controller: _emailController,
                        cursorColor: Colors.black,
                        focusNode: _focusNodeEmail,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: "Enter Your Email",
                          hintStyle: TextStyle(
                            fontSize: 15,
                            letterSpacing: 0,
                            height: 1.2,
                            color: Color(0xffAFAFAF),
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                          ),
                          filled: true,
                          fillColor: Color(0xffffffff),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            borderSide:
                                BorderSide(width: 1, color: Color(0xffCDE2FB)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            borderSide:
                                BorderSide(width: 1, color: Color(0xffCDE2FB)),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            borderSide: BorderSide(width: 1, color: Colors.red),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            borderSide: BorderSide(width: 1, color: Colors.red),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Password",
                        style: TextStyle(
                          color: Color(0xFF32657B),
                          fontFamily: "Inter",
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      TextFormField(
                        controller: _passwordController,
                        cursorColor: Colors.black,
                        focusNode: _focusNodePassword,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          hintText: "Enter Your Password",
                          hintStyle: TextStyle(
                            fontSize: 15,
                            letterSpacing: 0,
                            height: 1.2,
                            color: Color(0xffAFAFAF),
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                          ),
                          filled: true,
                          fillColor: Color(0xffffffff),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            borderSide:
                                BorderSide(width: 1, color: Color(0xffCDE2FB)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            borderSide:
                                BorderSide(width: 1, color: Color(0xffCDE2FB)),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            borderSide: BorderSide(width: 1, color: Colors.red),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            borderSide: BorderSide(width: 1, color: Colors.red),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Color(0xffAFAFAF),
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: height * 0.1),
                      InkWell(
                        onTap: () async {
                          if (_formKey.currentState?.validate() ?? false) {
                            logIn();
                          }
                        },
                        child: Container(
                          width: width,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Color(0xFFF6821F),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Center(
                            child: _loading
                                ? CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : Text(
                                    "Log In",
                                    style: TextStyle(
                                      color: Color(0xFFFFFFFF),
                                      fontFamily: "Inter",
                                      fontWeight: FontWeight.w700,
                                      fontSize: 20,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
