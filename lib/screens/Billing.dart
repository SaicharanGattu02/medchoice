import 'dart:io';

import 'package:fieldsenses/screens/Billinghistory.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import '../Model/AssignmentBill.dart';
import '../others/appbar.dart';
import '../services/UserApi.dart';




class Billing extends StatefulWidget {
  final String uid1;
  const Billing({super.key,required this.uid1});

  @override
  State<Billing> createState() => _BillingState();
}

class _BillingState extends State<Billing> {
  String clicked = 'online'; // Initial selected value
  final String online = 'online';
  final String cash = 'cash';
  Data? data;
  bool _loading = true;
  File? _selectedImage=null;
  String filename="";
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    GetCustomer(widget.uid1);
    super.initState();
  }

  Future<void> GetCustomer(String uid) async {
    final fetchedData = await Userapi.GetCustomerBill(uid);
    if (fetchedData != null && fetchedData.settings?.success == 1) {

      setState(() {
        data = fetchedData.data;
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

  Future<void> AddBill(patient_id,service_id,total_amount) async {
    final punchingResponse = await Userapi.AddbillApi(patient_id,service_id,total_amount,clicked,null,widget.uid1);
    if (punchingResponse != null) {
      setState(() {
        if (punchingResponse.settings?.success == 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>BillHistory()),
          );
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              "Bill Paided successfully!",
              style: TextStyle(color: Color(0xff000000)),
            ),
            duration: Duration(seconds: 1),
            backgroundColor: Color(0xFFCDE2FB),
          ));
        }else{
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              punchingResponse.settings?.message??"",
              style: TextStyle(color: Color(0xff000000)),
            ),
            duration: Duration(seconds: 1),
            backgroundColor: Color(0xFFCDE2FB),
          ));
        }
      });
    } else {

    }
  }

  Future<void> _pickImageFromGallery(ImageSource source,patient_id,service_id,total_amount) async {
    final pickedFile = await _picker.pickImage(source:source);
    if (pickedFile != null) {
      setState(() async {
        _selectedImage = File(pickedFile.path);
        filename= p.basename(pickedFile.path!);
        final punchingResponse  = await Userapi.AddbillApi(patient_id,service_id,total_amount,clicked,File(pickedFile!.path),widget.uid1);
        setState(() {
          if (punchingResponse != null && punchingResponse.settings?.success == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) =>BillHistory()),
            );
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                "Bill Paided successfully!",
                style: TextStyle(color: Color(0xff000000)),
              ),
              duration: Duration(seconds: 1),
              backgroundColor: Color(0xFFCDE2FB),
            ));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                "${punchingResponse?.settings?.message}",
                style: TextStyle(color: Color(0xff000000)),
              ),
              duration: Duration(seconds: 1),
              backgroundColor: Color(0xFFCDE2FB),
            ));
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: CustomAppBar(
        title: "Bill",
      ),
      body: _loading
          ? Center(
        child: CircularProgressIndicator(
          color: Color(0xFFF6821F),
        ),
      ) :
      SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                        _buildDetailRow(width, "Customer Name",data?.patient?.patientName ?? ""),
                        SizedBox(height: 8),
                        _buildDetailRow(width, "Service", data?.treatment.toString() ?? ""),
                        SizedBox(height: 8),
                        _buildDetailRow(width, "Payment", data?.amount?.toString() ?? ""),
                        SizedBox(height: 8),
                        _buildDetailRow(width, "Time", data?.timeTaken?? ""),
                        SizedBox(height: 8),
                        _buildDetailRow(width, "Date", data?.dueDate?? ""),
                      ],
                    ),
                  ),
                ),
                // SizedBox(
                //   height: 20,
                // ),
                Container(
                  margin: EdgeInsets.only(top: 20),
                 padding: EdgeInsets.only(bottom: 20),
                  // height: height * 0.4,
                  width: width,
                  decoration: BoxDecoration(
                      color: Color(0xFFF6821F),
                      borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/bill.png",
                        width: 160,
                        height: 80,
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Container(
                        width: width,
                        height: 1,
                        decoration: BoxDecoration(color: Color(0xFFFFFFFF)),
                      ),
        
                      Align(
                        alignment: Alignment.topLeft,
                        child:
        
                        Padding(
                          padding: const EdgeInsets.only(top: 15,left: 10),
                          child: Text(
                            "Select Any process to Pay",
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontFamily: "Inter",
                                fontSize: 18,
                                color: Color(0xFFFFFFFF)),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.all(12),
                        padding: EdgeInsets.all(12),
                        width: width,
                        height: 45,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Color(0xFFFFFFFF),
                        ),
                        child: Row(
                          children: [
                            Text(
                              "Online",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Color(0xFFF6821F),
                              ),
                            ),
                            Spacer(),
                            Radio(
                              value: online,
                              groupValue: clicked,
                              onChanged: (value) {
                                setState(() {
                                  clicked = value as String;
                                });
                              },
                              activeColor: Color(0xFFF6821F),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.all(12),
                        padding: EdgeInsets.all(12),
                        width: width,
                        height: 45,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Color(0xFFFFFFFF),
                        ),
                        child: Row(
                          children: [
                            Text(
                              "Cash",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Color(0xFFF6821F),
                              ),
                            ),
                            Spacer(),
                            Radio(
                              value: cash,
                              groupValue: clicked,
                              onChanged: (value) {
                                setState(() {
                                  clicked = value as String; // Update selected value
                                });
                              },
                              activeColor: Color(0xFFF6821F),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: (){
                          if(clicked=="online"){
                            showModalBottomSheet(
                              context: context,
                              builder: (BuildContext context) {
                                return SafeArea(
                                  child: Wrap(
                                    children: <Widget>[
                                      ListTile(
                                        leading: Icon(Icons.camera_alt),
                                        title: Text('Take a photo'),
                                        onTap: () {
                                          _pickImageFromGallery(ImageSource.camera,data?.patientId,data?.treatmentId,data?.amount);
                                          Navigator.pop(context);
                                        },
                                      ),
                                      ListTile(
                                        leading: Icon(Icons.photo_library),
                                        title: Text('Choose from gallery'),
                                        onTap: () {
                                          _pickImageFromGallery(ImageSource.gallery,data?.patientId,data?.treatmentId,data?.amount);
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          }else{
                            AddBill(data?.patientId,data?.treatmentId,data?.amount);
                          }
                        },
                        child: Container(
                          width: width * 0.3,
                          height: 35,
                          decoration: BoxDecoration(
                            color: Color(0xFFE46C06),
                            borderRadius:
                            BorderRadius.circular(100),
                          ),
                          child: Center(
                            child: Text(
                              "Pay Bill",
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
                    ],
                  ),
                ),
                SizedBox(height: 20,),
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
          blurRadius: 1,
          spreadRadius: 1,
          offset: Offset(0, 1,),
        )
      ]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: width * 0.25,
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
              value,
              maxLines: 1,
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
