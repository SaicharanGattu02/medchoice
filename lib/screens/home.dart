import 'dart:io';

import 'package:fieldsenses/screens/Assignments.dart';
import 'package:fieldsenses/screens/Attendence.dart';
import 'package:fieldsenses/screens/Billing.dart';
import 'package:fieldsenses/screens/Billinghistory.dart';
import 'package:fieldsenses/screens/Expenses.dart';
import 'package:fieldsenses/screens/Leave.dart';
import 'package:fieldsenses/screens/Locationtracking.dart';
import 'package:fieldsenses/screens/LogIn.dart';
import 'package:fieldsenses/screens/PunchInOut.dart';
import 'package:fieldsenses/screens/calender.dart';
import 'package:fieldsenses/services/UserApi.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:page_transition/page_transition.dart';

import '../preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const platform = MethodChannel('com.pixl/location');
  bool onclick = false;
  String profile_image = "";
  String name = "User";
  String status="";

  File? _image;
  final picker = ImagePicker();

  DateTime? _lastPressedAt;
  final Duration _exitTime = Duration(seconds: 2);

  var image_picked = 0;

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        image_picked=1;
      } else {
        print('No image selected.');
      }
    });
  }

  @override
  void initState() {
    GetProfileData();
    GetPuchInStatus();
    super.initState();
  }

  void _startLocationService() async {
    try {
      await platform.invokeMethod('startService', {'message': 'Location Service Started'});
    } on PlatformException catch (e) {
      print("Failed to start service: '${e.message}'.");
    }
  }

  Future<void> GetProfileData() async {
    final data = await Userapi.GetProfile();
    if (data != null) {
      setState(() {
        if (data.settings?.success == 1) {
          name=data.data?.fullName ?? "";
          profile_image=data.data?.image??"";
        }
      });
    } else {
      print("data is Not Fetching");
    }
  }

  Future<void> _submitProfile() async {
    if (_image == null) return;
    final response = await Userapi.UploadProfie(_image!);
    if (response != null && response.settings != null) {
      if( response.settings?.success==1){
        Navigator.pop(context,true);
        image_picked=0;
        GetProfileData();
      }
    }
    else {
      print("faild");
    }
  }

  Future<void> GetPuchInStatus() async {
    final Response = await Userapi.GetPuchInStatusApi();
    if(Response != null){
      setState(() {
        if (Response.settings?.success == 1) {
          status=Response?.status??"";
          if(status=="Punch in"){
            _startLocationService();
          }
        }
      });
    } else {
    }
  }

  Future<void> _refreshData() async {
    setState(() {
    });
    await GetProfileData();
  }


  Future<bool> _onWillPop() async {
    final DateTime now = DateTime.now();
    if (_lastPressedAt == null || now.difference(_lastPressedAt!) > _exitTime) {
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

  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    String nameInitial =
    (name.trim().isNotEmpty) ? name.trim()[0].toUpperCase() : "";
    return
      WillPopScope(
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
        drawer: Drawer(
          width: width * 0.85,
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              SizedBox(height: height * 0.05),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 15,
                      ),
                      Stack(
                        clipBehavior: Clip.none, // Ensure the Stack can handle overflow
                        children: [
                          if(image_picked==1)...[
                            CircleAvatar(
                              radius: 35,
                              backgroundColor: Color(0xff80C4E9),
                              backgroundImage:(_image != null ? FileImage(_image!) : null), // Fallback to null if no image is available
                              child: _image == null
                                  ? Text(
                                nameInitial,
                                style: const TextStyle(
                                  fontSize: 50,
                                  color: Color(0xffFFF6E9), // Optional: set color if needed
                                ),
                              )
                                  : null,
                            ),
                          ]else...[
                          CircleAvatar(
                            radius: 35,
                            backgroundColor: Color(0xff80C4E9),
                            backgroundImage: profile_image != null
                                ? NetworkImage(profile_image!) as ImageProvider<Object> // Network image
                                : null,
                            child: profile_image == ""
                                ? Text(
                              nameInitial,
                              style: const TextStyle(
                                fontSize: 50,
                                color: Color(0xffFFF6E9), // Optional: set color if needed
                              ),
                            )
                                : null,
                          ),
                          ],
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.grey,
                                child: Icon(
                                  Icons.edit,
                                  size: 15,
                                  color: Color(0xffffffff),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: width*0.5,
                              child:
                              Text(
                                "Hi ${name[0].toUpperCase()}${name.substring(1).toLowerCase()}",
                                maxLines: 1,
                                overflow:TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontFamily: "Inter",
                                    color: Color(0xFFF6821F),
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            if(image_picked==1)...[
                              InkResponse(
                                onTap: (){
                                  _submitProfile();
                                },
                                child: Text(
                                  "Upload Profile",
                                  style: TextStyle(
                                      fontFamily: "Inter",
                                      color: Color(0xFFF6821F),
                                      fontSize: 15,
                                      decoration: TextDecoration.underline,
                                      decorationColor: Color(0xffF6821F),
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ]
                          ],
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Divider(
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 30),
                ],
              ),
              InkWell(
                onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>Attendance()));
              },
                child: ListTile(
                  leading: Image.asset("assets/attendence.png",width: 20,height: 20,),
                  title: Text(
                    'Attendance',
                    style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF9C8F8F),
                        fontWeight: FontWeight.w400,
                        fontFamily: "Inter"),
                  ),
                ),
              ),
              InkWell(onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>Expenses()));
              },
                child:
                ListTile(
                  leading: Icon(Icons.account_balance_wallet_outlined,color: Color(0xFF9C8F8F),size: 20,),
                  title:
                  Text(
                    'Expenses',
                    style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF9C8F8F),
                        fontWeight: FontWeight.w400,
                        fontFamily: "Inter"),
                  ),
                ),
              ),
              InkWell(onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>Assignments()));
              },
                child:
                ListTile(
                  leading: Icon(Icons.assignment_outlined,color: Color(0xFF9C8F8F),size: 20,),
                  title: Text(
                    'Assignment',
                    style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF9C8F8F),
                        fontWeight: FontWeight.w400,
                        fontFamily: "Inter"),
                  ),
                ),),
              InkWell(onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>Leave()));
              },
                child: ListTile(
                  leading: Icon(Icons.calendar_month_outlined,color: Color(0xFF9C8F8F),size: 20,),
                  title: Text(
                    'Leave',
                    style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF9C8F8F),
                        fontWeight: FontWeight.w400,
                        fontFamily: "Inter"),
                  ),
                ),
              ),
              InkWell(
                onTap: (){
                  PreferenceService().remove('token');
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>LogIn()));
                },
                child: ListTile(
                  leading: Icon(Icons.logout,color: Color(0xFF9C8F8F),size: 20,),
                  title: Text(
                    'Logout',
                    style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF9C8F8F),
                        fontWeight: FontWeight.w400,
                        fontFamily: "Inter"),
                  ),
                ),
              ),
            ],
          ),
        ),
        body:
        RefreshIndicator(onRefresh: _refreshData,color: Color(0xFFF6821F),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Text(
                      //   "Essentials",
                      //   style: TextStyle(
                      //       color: Color(0xFF465761),
                      //       fontSize: 20,
                      //       fontFamily: "Inter",
                      //       fontWeight: FontWeight.w500),
                      // ),
                      // Spacer(),
                      // Icon(
                      //   Icons.access_time_rounded,
                      //   color: Color(0xFFF6821F),
                      //   size: 20,
                      // ),
                      // SizedBox(
                      //   width: 10,
                      // ),
                      // Column(
                      //   mainAxisAlignment: MainAxisAlignment.start,
                      //   crossAxisAlignment: CrossAxisAlignment.start,
                      //   children: [
                          SizedBox(
                            height: 13,
                          ),
                          // Text(
                          //   "10:30AM",
                          //   style: TextStyle(
                          //       color: Color(0xFFF6821F),
                          //       fontSize: 20,
                          //       fontFamily: "Inter",
                          //       fontWeight: FontWeight.w700),
                          // ),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  PageTransition(
                                      child: Punching(),
                                      type: PageTransitionType.rightToLeft,
                                      isIos: true,
                                      duration: Duration(milliseconds: 300)));
                            },
                            child: Container(
                              height: 35,
                              padding: EdgeInsets.only(left: 10,right: 10),
                              margin: EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(
                                color: Color(0xFFF6821F),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Center(
                                child: Text(status=="Punch in"?"Punch Out":"Punch In",
                                  style: TextStyle(
                                    color: Color(0xFFFFFFFF),
                                    fontFamily: "Inter",
                                    fontWeight: FontWeight.w600,
                                    fontSize: 17,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      //   ],
                      // ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              PageTransition(
                                  child: Assignments(),
                                  type: PageTransitionType.rightToLeft,
                                  isIos: true,
                                  duration: Duration(milliseconds: 300)));
                        },
                        child: Container(
                          width: width * 0.43,
                          height: 250,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Color(0xFFFFFFFF),
                            boxShadow: [
                              BoxShadow(
                                  color: Color(0xFFE1E7FD),
                                  blurRadius: 1.5,
                                  spreadRadius: 1.5,
                                  offset: Offset(0, 2) // changes position of shadow
                              )
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "My Assignments",
                                  style: TextStyle(
                                      color: Color(0xFf465761),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: "Inter"),
                                ),
                                Spacer(),
                                Lottie.asset(
                                  'assets/animations/assignment.json',
                                  height: 150,
                                  width: 150,
                                ),
                                Spacer(),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 30, right: 30, bottom: 20),
                                  child: Container(
                                    height: 35,
                                    decoration: BoxDecoration(
                                      color: Color(0xFF4BA8FE),
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "View",
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
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              PageTransition(
                                  child: BillHistory(),
                                  type: PageTransitionType.rightToLeft,
                                  isIos: true,
                                  duration: Duration(milliseconds: 300)));
                        },
                        child: Container(
                          width: width * 0.43,
                          height: 250,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Color(0xFFFFFFFF),
                            boxShadow: [
                              BoxShadow(
                                  color: Color(0xFFE1E7FD),
                                  blurRadius: 1.5,
                                  spreadRadius: 1.5,
                                  offset: Offset(0, 2) // changes position of shadow
                              )
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "My Billings",
                                  style: TextStyle(
                                      color: Color(0xFf465761),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: "Inter"),
                                ),
                                Spacer(),
                                Lottie.asset(
                                  'assets/animations/two.json',
                                  height: 100,
                                  width: 100,
                                ),
                                Spacer(),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 30, right: 30, bottom: 20),
                                  child: Container(
                                    height: 35,
                                    decoration: BoxDecoration(
                                      color: Color(0xFF4BA8FE),
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "View",
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
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              PageTransition(
                                  child: Attendance(),
                                  type: PageTransitionType.rightToLeft,
                                  isIos: true,
                                  duration: Duration(milliseconds: 300)));
                        },
                        child: Container(
                          width: width * 0.43,
                          height: 250,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Color(0xFFFFFFFF),
                            boxShadow: [
                              BoxShadow(
                                  color: Color(0xFFE1E7FD),
                                  blurRadius: 1.5,
                                  spreadRadius: 1.5,
                                  offset: Offset(0, 2) // changes position of shadow
                              )
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "My Attendance",
                                  style: TextStyle(
                                      color: Color(0xFf465761),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: "Inter"),
                                ),
                                Spacer(),
                                Lottie.asset(
                                  'assets/animations/one.json',
                                  height: 120,
                                  width: 120,
                                ),
                                Spacer(),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 30, right: 30, bottom: 20),
                                  child: Container(
                                    height: 35,
                                    decoration: BoxDecoration(
                                      color: Color(0xFF4BA8FE),
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "View",
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
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              PageTransition(
                                  child: Expenses(),
                                  type: PageTransitionType.rightToLeft,
                                  isIos: true,
                                  duration: Duration(milliseconds: 300)));
                        },
                        child: Container(
                          width: width * 0.43,
                          height: 250,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Color(0xFFFFFFFF),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFFE1E7FD),
                                blurRadius: 1.5,
                                spreadRadius: 1.5,
                                offset: Offset(0, 2), // changes position of shadow
                              )
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "My Expenses",
                                  style: TextStyle(
                                      color: Color(0xFf465761),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: "Inter"),
                                ),
                                Spacer(),
                                Lottie.asset(
                                  'assets/animations/wallet.json',
                                  height: 150,
                                  width: 150,
                                ),
                                Spacer(),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 30, right: 30, bottom: 20),
                                  child: Container(
                                    height: 35,
                                    decoration: BoxDecoration(
                                      color: Color(0xFF4BA8FE),
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "View",
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
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
            ),
      );
  }
}