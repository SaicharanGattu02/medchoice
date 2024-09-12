import 'package:fieldsenses/screens/Treatment.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:page_transition/page_transition.dart';
import 'package:fieldsenses/services/UserApi.dart';
import 'package:fieldsenses/screens/home.dart';

import '../Model/AssignmentModel.dart';
import '../others/appbar.dart';
import 'Billing.dart';

class Assignments extends StatefulWidget {
  const Assignments({super.key});

  @override
  State<Assignments> createState() => _AssignmentsState();
}

class _AssignmentsState extends State<Assignments> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    GetAssignments();
  }
  List<Data> assignments = [];
  Future<void> GetAssignments() async {
    final data = await Userapi.GetCustomerDataApi();
    if (data != null) {
      setState(() {
        if (data.settings?.success == 1) {
          assignments = data.data ?? [];
          _loading = false;
        }
      });
    } else {
      print("data is Not Fetching");
      _loading = false;
    }
  }

  Future<void> _refreshData() async {
    setState(() {
    });
    await GetAssignments();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: CustomAppBar(
        title: "Assignments",
      ),
      body: _loading
          ? Center(
          child: CircularProgressIndicator(
            color: Color(0xFFF6821F),
          ))
          :
        RefreshIndicator(
          color: Color(0xffF6821F),
          onRefresh: _refreshData,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 15),
            if( assignments.length!=0)...[
              Expanded(
                child: ListView.builder(
                  itemCount: assignments.length,
                  itemBuilder: (context, index) {
                    final assignment = assignments[index];
                    return
                      InkResponse(
                        onTap: () async {
                          if(assignment.status=="start" || assignment.status=="In Progress"){
                            var res = await Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Treatments(
                                    uid: "${assignment.uid}",
                                  )),
                            );
                            if(res==true){
                              _loading=true;
                              GetAssignments();
                            }
                          }else if(assignment.status!="Bill Paid" && assignment.status=="Completed"){
                            var res = await Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Billing(uid1:assignment.uid??"",)),
                            );
                            if(res==true){
                              _loading=true;
                              GetAssignments();
                            }
                          }

                        },
                        child: Container(
                          padding: EdgeInsets.only(left: 10,right: 10,top: 10,bottom: 10),
                          margin: EdgeInsets.only(bottom: 5, top: 10),
                          width: width,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Color(0xFFFFFFFF),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFFE1E7FD),
                                blurRadius: 1,
                                spreadRadius: 1,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: width * 0.62,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Customer Name: ${assignment.patientName}",
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: TextStyle(
                                        color: Color(0xFF32657B),
                                        fontSize: 18,
                                        fontFamily: "Inter",
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      "Treatment for ${assignment.treatment}",
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                      style: TextStyle(
                                        color: Color(0xFF32657B),
                                        fontSize: 15,
                                        fontFamily: "Inter",
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.location_on_outlined,
                                          size: 20,
                                          color: Color(0xFFF6821F),
                                        ),
                                        SizedBox(width: 4),
                                        Container(
                                          width: width * 0.55,
                                          child: Text(
                                            "${assignment.address??""}",
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            style: TextStyle(
                                              color: Color(0xFF32657B),
                                              fontSize: 14,
                                              fontFamily: "Inter",
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Spacer(),
                              Container(
                                height: 30,
                                width: width * 0.23,
                                padding: EdgeInsets.only(left: 3,right: 3),
                                decoration: BoxDecoration(
                                  color: Color(0xFF4BA8FE),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Center(
                                  child: Text(
                                    assignment.status??"",
                                    style: TextStyle(
                                      color: Color(0xFFFFFFFF),
                                      fontFamily: "Inter",
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                  },
                ),
              ),
              ]else...[
              SizedBox(height: height*0.17,),
              Center(
                child: Lottie.asset(
                  'assets/animations/nodata1.json',
                  height: 360,
                  width: 360,
                ),
              ),
            ]
            ],
          ),
        ),
      ),
    );
  }
}