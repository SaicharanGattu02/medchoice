import 'package:fieldsenses/others/appbar.dart';
import 'package:fieldsenses/screens/Billing.dart';
import 'package:fieldsenses/services/UserApi.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Model/AssignmentBill.dart';

class Treatments extends StatefulWidget {
  final String uid;
  const Treatments({super.key, required this.uid});

  @override
  State<Treatments> createState() => _TreatmentState();
}

class _TreatmentState extends State<Treatments> {
  bool _loading = true;
  Data? data;
  double latitude = 17.1116;
  double longitude = 78.7056;
  bool isSelected=false;

  String treatmentStart = "start";
  String treatmentEnd = "completed";
  String status="";

  @override
  void initState() {
    GetCustomer(widget.uid);
    super.initState();
  }

  Future<void> GetCustomer(String uid) async {
    final fetchedData = await Userapi.GetCustomerBill(uid);
    if (fetchedData != null && fetchedData.settings?.success == 1) {
      setState(() {
        data = fetchedData.data;
        status=fetchedData.data?.status??"";
        _loading = false;
        print("data is  Fetching");
      });
    } else {
      setState(() {
        _loading = false;
      });
      print("data is Not Fetching");
    }
  }

  // Future<void> ViewMap(double latitude, double longitude) async {
  //   final String googleMapsUrl =
  //       "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude";
  //   if (await canLaunch(googleMapsUrl)) {
  //     await launch(googleMapsUrl);
  //   } else {
  //     throw 'Could not open the map.';
  //   }
  // }

  Future<void> ViewMap(String address) async {
    // Encode the address to handle spaces and special characters
    final encodedAddress = Uri.encodeComponent(address);
    final String googleMapsUrl =
        "https://www.google.com/maps/search/?api=1&query=$encodedAddress";
    if (await canLaunch(googleMapsUrl)) {
      await launch(googleMapsUrl);
    } else {
      throw 'Could not open the map.';
    }
  }

  Future<void> TreatmentStart(String uid) async {
    final data = await Userapi.PutTreatment(uid, treatmentStart);
    if (data != null) {
      setState(() {
        if(data.settings?.success==1){
          _loading = true;
          isSelected=true;
          GetCustomer(widget.uid);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                Text(data.settings!.message ?? "Treatment has Started")),
          );
        }else{
          _loading = false;
        }
      });
    } else {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> TreatmentEnd(String uid) async {
    final data = await Userapi.PutTreatment(uid, treatmentEnd);
    if (data != null) {
      setState(() {
        if(data.settings?.success==1){
          Navigator.pushReplacement(
              context,
              PageTransition(
                  child: Billing(uid1: uid),
                  type: PageTransitionType.rightToLeft,
                  isIos: true,
                  duration: Duration(milliseconds: 300)));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                Text(data.settings!.message ?? "Treatment has Ended")),
          );
        }else{

        }
      });
    } else {
      setState(() {
        _loading = false;
      });
      print("error");
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar:
      AppBar(
        backgroundColor: Color(0xFFF6821F),
        toolbarHeight: height * 0.056,
        leading: InkWell(
            onTap: () {
              Navigator.pop(context,true);
            },
            child: Icon(Icons.arrow_back,color: Color(0xFFFFFFFF),)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "Task ",
              style: TextStyle(
                  color: Color(0xFFFFFFFF),
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  fontFamily: "Inter"),
            ),
            // Spacer(),
            // Icon(Icons.access_time, size: 20, color: Color(0xFFFFFFFF)),
            // SizedBox(width: 10),
            // Container(
            //   width: 120,
            //   padding: EdgeInsets.only(top: 5, bottom: 5, right: 10, left: 10),
            //   decoration: BoxDecoration(
            //       borderRadius: BorderRadius.circular(5),
            //       border: Border.all(width: 1, color: Color(0xFFFFFFFF))),
            //   child: Text(
            //     "${data?.staffStartedTime ?? ""}",
            //     style: const TextStyle(
            //       color: Color(0xFFFFFFFF),
            //       fontSize: 16,
            //       fontFamily: "Inter",
            //       fontWeight: FontWeight.w500,
            //     ),
            //     overflow: TextOverflow.ellipsis,
            //   ),
            // ),
          ],
        ),
      ),

      body: _loading
          ? Center(
        child: CircularProgressIndicator(
          color: Color(0xFFF6821F),
        ),
      )
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  SizedBox(height: 12),
                  Card(
                    color: Color(0xFFF8FDFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 15, bottom: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: Text(
                              "Customer Details",
                              style: TextStyle(
                                color: Color(0xFF32657B),
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                fontFamily: "Inter",
                              ),
                            ),
                          ),
                          SizedBox(height: 12),
                          _buildDetailRow(width, "Customer Name",
                              data?.patient?.patientName ?? ""),
                          SizedBox(height: 8),
                          _buildDetailRow(width, "Contact Number",
                              data?.patient?.mobile ?? ""),
                          SizedBox(height: 8),
                          _buildDetailRow(
                              width, "Location", data?.patient?.address ?? ""),
                          SizedBox(height: 8),
                          _buildDetailRow(
                              width, "Landmark", data?.patient?.address ?? ""),
                          SizedBox(height: 8),
                          _buildDetailRow(
                              width, "Service", data?.treatment.toString() ??""),
                          SizedBox(height: 8),
                          _buildDetailRow(width, "Price",
                              data?.amount?.toString() ?? ""),
                          SizedBox(height:25),
                          Center(
                            child: InkWell(
                              onTap: () {
                                ViewMap(data?.patient?.address??"");
                              },
                              child: Container(
                                width: width * 0.3,
                                height: 35,
                                decoration: BoxDecoration(
                                  color: Color(0xFF4BA8FE),
                                  borderRadius:
                                  BorderRadius.circular(100),
                                ),
                                child: Center(
                                  child: Text(
                                    "View Map",
                                    style: TextStyle(
                                      color: Color(0xFFFFFFFF),
                                      fontFamily: "Inter",
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.2),
                    if(status=="start")...[
                      InkWell(
                        onTap: () {
                          TreatmentStart(widget.uid);
                          isSelected=true;
                        },
                        child: Container(
                          width: width,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Color(0xFF4BA8FE),
                            borderRadius:
                            BorderRadius.circular(100),
                          ),
                          child: Center(
                            child: Text(
                              "Start Treatment",
                              style: TextStyle(
                                color: Color(0xFFFFFFFF),
                                fontFamily: "Inter",
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ]else if(status=="In Progress")...[
                      InkWell(
                        onTap: () {
                          TreatmentEnd(widget.uid);
                          _loading = true;
                        },
                        child: Container(
                          width: width,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Color(0xFF4BA8FE),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Center(
                            child: Text(
                              "Task Done",
                              style: TextStyle(
                                color: Color(0xFFFFFFFF),
                                fontFamily: "Inter",
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ]else...[

                    ]
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(double width, String label, String value) {
    return Container(
      width: width,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(color: Color(0xFFFFFFFF), boxShadow: [
        BoxShadow(
          color: Color(0xFFE1E7FD),
          blurRadius: 5.0,
          spreadRadius: 5.0,
          offset: Offset(0, 3),
        )
      ]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: width * 0.4,
            child: Text(
              label,
              style: TextStyle(
                color: Color(0xFFF6821F),
                fontSize: 16,
                fontFamily: "Inter",
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            ":",
            style: TextStyle(
              color: Color(0xFF000000),
              fontSize: 20,
              fontFamily: "Inter",
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "${value}",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Color(0xFF0573DA),
                fontSize: 13,
                fontFamily: "Inter",
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}